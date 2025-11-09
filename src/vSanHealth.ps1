$ErrorActionPreference = "Stop"
﻿<#
.SYNOPSIS
  Read-only vSAN health & ESXi service status check for vSphere 7/8 (PowerCLI).

.DESCRIPTION
  - Runs vSAN Health at the cluster level (fresh or from cache).
  - Summarizes failing groups/checks and key ESXi services.
  - Prints a clear, tabular report directly to the PowerCLI console.
  - Optionally exports a JSON report for further processing.

  The script is strictly read-only. It performs no configuration changes.

.PARAMETER vCenter
  vCenter FQDN/IP. If omitted and you are already connected, uses the current VIServer session.

.PARAMETER Credential
  PSCredential for vCenter. If omitted, an interactive prompt appears.

.PARAMETER Cluster
  One or more cluster names (supports wildcards). Default: all vSAN-enabled clusters.

.PARAMETER UseCache
  If set, returns cached vSAN health instead of running a new test.

.PARAMETER Perspective
  Optional vSAN Health "perspective" (e.g. 'clusterPowerOffPrecheck' on vSAN 7.0U3+).

.PARAMETER ExportPath
  Optional path for JSON export (e.g. 'C:\Reports\vsan-health.json').

.EXAMPLE
  .\Invoke-VsanHealth.ps1 -vCenter vcsa.lab.local -Cluster 'Prod-*' -UseCache -ExportPath C:\temp\vsan.json

.NOTES
  Requires: PowerShell 5.1+ or PowerShell 7+, VMware PowerCLI (Core + Storage modules).
  Recommended PowerCLI 13.x+
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)][string]$vCenter,
  [Parameter(Mandatory=$false)][System.Management.Automation.PSCredential]$Credential,
  [Parameter(Mandatory=$false)][string[]]$Cluster,
  [switch]$UseCache,
  [string]$Perspective,
  [string]$ExportPath
)

#---------------------------
# Helpers
#---------------------------

function Write-Info($msg){ Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Warn($msg){ Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Err ($msg){ Write-Host "[ERROR] $msg" -ForegroundColor Red   }

function Assert-Module {
  param([string[]]$Names)
  foreach($n in $Names){
    if(-not (Get-Module -ListAvailable -Name $n)){
      Write-Err "Missing module '$n'. Install VMware PowerCLI: Install-Module VMware.PowerCLI"
      throw "Required module missing: $n"
    }
    Import-Module $n -ErrorAction Stop | Out-Null
  }
}

# Determine if a cluster is vSAN-enabled (works across 7/8)
function Test-VsanEnabled {
  param([VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]$ClusterObj)
  try {
    $null = Get-VsanClusterConfiguration -Cluster $ClusterObj -ErrorAction Stop
    return $true
  } catch {
    return ($ClusterObj.ExtensionData.ConfigurationEx.VsanConfigInfo.Enabled -eq $true)
  }
}

# Collect ESXi service status (read-only)
function Get-EsxiServiceStatus {
  param([VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]$VMHost)

  $preferredKeys = @('vpxa','vmware-fdm','ntpd','vmsyslogd','vsanmgmt','vsanmgmtd')
  $svc = Get-VMHostService -VMHost $VMHost -ErrorAction SilentlyContinue
  if(-not $svc){ return @() }

  $vsanLike = $svc | Where-Object { $_.Key -match 'vsan' }
  $chosen   = @()

  foreach($k in $preferredKeys){
    $item = $svc | Where-Object { $_.Key -ieq $k }
    if($item){ $chosen += $item }
  }
  $chosen += $vsanLike | Where-Object { $preferredKeys -notcontains $_.Key }

  $chosen | Select-Object @{n='Host';e={$VMHost.Name}},
                         @{n='ServiceKey';e={$_.Key}},
                         @{n='Label';e={$_.Label}},
                         @{n='Running';e={$_.Running}},
                         @{n='Policy';e={$_.Policy}}
}

# Run vSAN Health via cmdlet if available; otherwise via vSAN API
function Invoke-VsanHealth {
  param(
    [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]$ClusterObj,
    [switch]$UseCache,
    [string]$Perspective
  )

  $result = $null
  $used   = $null

  if (Get-Command -Name Test-VsanClusterHealth -ErrorAction SilentlyContinue) {
    try {
      $params = @{ Cluster = $ClusterObj }
      if($UseCache){ $params.UseCache = $true }
      if($Perspective){ $params.Perspective = $Perspective }
      $result = Test-VsanClusterHealth @params -ErrorAction Stop
      $used = 'Cmdlet'
    } catch {
      Write-Warn "Test-VsanClusterHealth failed on cluster '$($ClusterObj.Name)'. Falling back to vSAN API. Details: $($_.Exception.Message)"
    }
  }

  if(-not $result){
    $vchs = Get-VsanView -Id "VsanVcClusterHealthSystem-vsan-cluster-health-system"
    $clusterMoRef = $ClusterObj.ExtensionData.MoRef
    $fields = @('clusterStatus','timestamp','overallHealth','overallHealthDescription','groups','networkHealth','physicalDisksHealth','diskBalance','hclInfo')

    $result = $vchs.VsanQueryVcClusterHealthSummary(
      $clusterMoRef,
      $null,       # vmCreateTimeout
      $null,       # objUuids
      $true,       # includeObjUuids
      $fields,     # fields
      [bool]$UseCache,
      ($Perspective ? $Perspective : $null),
      $null,       # hosts
      $null        # spec
    )
    $used = 'API'
  }

  [pscustomobject]@{
    Cluster = $ClusterObj.Name
    Raw     = $result
    Mode    = $used
  }
}

# Normalize health output into a summary object
function Convert-HealthToSummary {
  param($raw)

  $clusterName = $raw.Cluster
  $obj         = $raw.Raw
  $mode        = $raw.Mode

  $overall  = $null
  $overallD = $null
  $groups   = @()
  $networkS = $null
  $diskBal  = $null
  $hclAge   = $null
  $ts       = $null

  foreach($p in @('Timestamp','timestamp')){ if($obj.PSObject.Properties.Name -contains $p){ $ts = $obj.$p; break } }
  foreach($p in @('OverallHealth','overallHealth')){ if($obj.PSObject.Properties.Name -contains $p){ $overall = $obj.$p; break } }
  foreach($p in @('OverallHealthDescription','overallHealthDescription')){ if($obj.PSObject.Properties.Name -contains $p){ $overallD = $obj.$p; break } }
  foreach($p in @('Groups','groups')){ if($obj.PSObject.Properties.Name -contains $p){ $groups = @($obj.$p); break } }
  foreach($p in @('NetworkHealth','networkHealth')){ if($obj.PSObject.Properties.Name -contains $p){ $networkS = $obj.$p; break } }
  foreach($p in @('DiskBalance','diskBalance')){ if($obj.PSObject.Properties.Name -contains $p){ $diskBal = $obj.$p; break } }

  if($obj.PSObject.Properties.Name -contains 'hclInfo'){
    $hcl = $obj.hclInfo
    if($hcl -and $hcl.PSObject.Properties.Name -contains 'hclDbLastUpdate'){
      $hclAge = $hcl.hclDbLastUpdate
    } elseif($hcl -and $hcl.PSObject.Properties.Name -contains 'hclDbVersion'){
      $hclAge = $hcl.hclDbVersion
    }
  }

  $failingGroups = @()
  $failingChecks = @()
  foreach($g in $groups){
    $gState = $null
    foreach($p in @('overallHealth','overallHealthState','overall','state')){ if($g.PSObject.Properties.Name -contains $p){ $gState = $g.$p; break } }
    if($gState -and $gState -ne 'green'){
      $failingGroups += [pscustomobject]@{
        GroupId = ($g.groupId ? $g.groupId : $g.id)
        Name    = ($g.name    ? $g.name    : $g.groupName)
        Health  = $gState
      }
      if($g.PSObject.Properties.Name -contains 'tests'){
        foreach($t in $g.tests){
          $tState = $null
          foreach($p in @('health','overallHealth','state')){ if($t.PSObject.Properties.Name -contains $p){ $tState = $t.$p; break } }
          if($tState -and $tState -ne 'green'){
            $failingChecks += [pscustomobject]@{
              GroupId = ($g.groupId ? $g.groupId : $g.id)
              TestId  = ($t.testId  ? $t.testId  : $t.id)
              Name    = ($t.name    ? $t.name    : $t.testName)
              Health  = $tState
              Detail  = ($t.description ? $t.description : $t.problemDescription)
            }
          }
        }
      }
    }
  }

  [pscustomobject]@{
    Cluster            = $clusterName
    Timestamp          = $ts
    OverallHealth      = $overall
    OverallDescription = $overallD
    HclDatabaseInfo    = $hclAge
    NetworkSection     = $networkS
    DiskBalance        = $diskBal
    FailingGroups      = $failingGroups
    FailingChecks      = $failingChecks
    _Mode              = $mode
    _Raw               = $obj
  }
}

#---------------------------
# Main
#---------------------------

try {
  Assert-Module -Names @('VMware.VimAutomation.Core','VMware.VimAutomation.Storage')
} catch { throw }

if($vCenter){
  if($Credential){
    Write-Info "Connecting to vCenter '$vCenter' (with credential)…"
    Connect-VIServer -Server $vCenter -Credential $Credential -ErrorAction Stop | Out-Null
  } else {
    Write-Info "Connecting to vCenter '$vCenter'…"
    Connect-VIServer -Server $vCenter -ErrorAction Stop | Out-Null
  }
} else {
  if(-not (Get-VIServer)){ Write-Err "Not connected to any vCenter. Use -vCenter or Connect-VIServer first."; return }
}

Write-Info "Discovering clusters…"
$allClusters = if($Cluster){
  $tmp = @()
  foreach($name in $Cluster){ $tmp += Get-Cluster -Name $name -ErrorAction Stop }
  $tmp
} else {
  Get-Cluster
}

$vsanClusters = @()
foreach($c in $allClusters){
  if(Test-VsanEnabled -ClusterObj $c){ $vsanClusters += $c }
}

if(-not $vsanClusters){
  Write-Warn "No vSAN-enabled clusters found for the given filter."
  return
}

# Run health + host service checks
$report = @()

foreach($c in $vsanClusters){
  Write-Info "Running vSAN health on cluster '$($c.Name)' (cache=$($UseCache.IsPresent); perspective='$Perspective')…"
  $raw = Invoke-VsanHealth -ClusterObj $c -UseCache:$UseCache -Perspective $Perspective
  $summary = Convert-HealthToSummary -raw $raw

  Write-Info "Collecting ESXi service status for cluster '$($c.Name)'…"
  $hostSvcs = @()
  foreach($h in (Get-VMHost -Location $c | Sort-Object Name)){
    $hostSvcs += Get-EsxiServiceStatus -VMHost $h
  }

  # Optional resync overview (read-only, best-effort)
  $resync = $null
  if(Get-Command -Name Get-VsanResyncingOverview -ErrorAction SilentlyContinue){
    try { $resync = Get-VsanResyncingOverview -Cluster $c -ErrorAction Stop } catch { Write-Warning "Failed to get resync overview: $($_.Exception.Message)" }
  }

  $report += [pscustomobject]@{
    Cluster        = $c.Name
    Health         = $summary
    HostServices   = $hostSvcs
    ResyncOverview = $resync
  }
}

#---------------------------
# Console Output
#---------------------------

foreach($r in $report){
  $h = $r.Health
  Write-Host ""
  Write-Host "=== vSAN Health Report: $($h.Cluster) ===" -ForegroundColor Green
  "{0,-18}: {1}" -f "Timestamp",          ($h.Timestamp)
  "{0,-18}: {1}" -f "OverallHealth",      ($h.OverallHealth)
  "{0,-18}: {1}" -f "HCL DB",             ($h.HclDatabaseInfo)
  "{0,-18}: {1}" -f "HealthEngine",       ($h._Mode)

  if($h.FailingGroups.Count -gt 0){
    Write-Host "`nFailing Groups:" -ForegroundColor Yellow
    $h.FailingGroups | Select-Object Health,Name,GroupId | Format-Table -AutoSize
  } else {
    Write-Host "`nFailing Groups: none"
  }

  if($h.FailingChecks.Count -gt 0){
    Write-Host "`nFailing Checks:" -ForegroundColor Yellow
    $h.FailingChecks | Select-Object GroupId,Name,Health,Detail | Format-Table -AutoSize
  }

  if($r.HostServices -and $r.HostServices.Count -gt 0){
    Write-Host "`nHost Services:" -ForegroundColor Cyan
    $r.HostServices |
      Sort-Object Host, ServiceKey |
      Select-Object Host, ServiceKey, Running, Policy |
      Format-Table -AutoSize
  }

  if($r.ResyncOverview){
    $ov = $r.ResyncOverview
    "{0,-18}: {1}" -f "Resync Objects", ($ov.ObjectsCount)
    "{0,-18}: {1}" -f "Resync BytesGB", ($ov.TotalBytesToSyncGB)
  }
}

#---------------------------
# Optional Export
#---------------------------

if($ExportPath){
  try {
    $report | ConvertTo-Json -Depth 6 | Set-Content -Path $ExportPath -Encoding UTF8
    Write-Info "Report written to: $ExportPath"
  } catch {
    Write-Warn "Failed to write JSON report: $($_.Exception.Message)"
  }
}
