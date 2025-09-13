#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core, VMware.VimAutomation.Storage

<#
.SYNOPSIS
    Enhanced vSAN Health Monitoring Module for vSphere 7/8
.DESCRIPTION
    Production-ready PowerShell module for comprehensive vSAN cluster health monitoring
    with advanced error handling, logging, and security features.
.NOTES
    Author: VMware vSAN Health Team
    Version: 2.0.0
    Requires: PowerShell 5.1+, VMware PowerCLI 13.x+
#>

using namespace System.Management.Automation
using namespace VMware.VimAutomation.ViCore.Types.V1

# Module variables
$script:LogLevel = 'Info'
$script:LogPath = $null

#region Logging Functions
function Write-VSanLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Error', 'Warning', 'Info', 'Debug', 'Verbose')]
        [string]$Level,
        
        [Parameter(Mandatory)]
        [string]$Message,
        
        [string]$Component = 'VSanHealth'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] [$Component] $Message"
    
    switch ($Level) {
        'Error'   { Write-Error $Message; break }
        'Warning' { Write-Warning $Message; break }
        'Info'    { Write-Information $Message -InformationAction Continue; break }
        'Debug'   { Write-Debug $Message; break }
        'Verbose' { Write-Verbose $Message; break }
    }
    
    if ($script:LogPath) {
        try {
            Add-Content -Path $script:LogPath -Value $logEntry -ErrorAction Stop
        }
        catch {
            Write-Warning "Failed to write to log file: $_"
        }
    }
}

function Set-VSanLogLevel {
    [CmdletBinding()]
    param(
        [ValidateSet('Error', 'Warning', 'Info', 'Debug', 'Verbose')]
        [string]$Level = 'Info'
    )
    $script:LogLevel = $Level
}

function Set-VSanLogPath {
    [CmdletBinding()]
    param([string]$Path)
    
    if ($Path) {
        $directory = Split-Path -Path $Path -Parent
        if (-not (Test-Path -Path $directory)) {
            New-Item -Path $directory -ItemType Directory -Force | Out-Null
        }
    }
    $script:LogPath = $Path
}
#endregion

#region Validation Functions
function Test-VSanPrerequisites {
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    
    try {
        # Check PowerShell version
        if ($PSVersionTable.PSVersion.Major -lt 5) {
            throw "PowerShell 5.1 or higher required. Current: $($PSVersionTable.PSVersion)"
        }
        
        # Check required modules
        $requiredModules = @('VMware.VimAutomation.Core', 'VMware.VimAutomation.Storage')
        foreach ($module in $requiredModules) {
            if (-not (Get-Module -ListAvailable -Name $module)) {
                throw "Required module '$module' not found. Install VMware PowerCLI."
            }
            Import-Module $module -ErrorAction Stop
        }
        
        # Check vCenter connection
        if (-not (Get-VIServer -ErrorAction SilentlyContinue)) {
            Write-VSanLog -Level Warning -Message "No active vCenter connection found"
            return $false
        }
        
        Write-VSanLog -Level Info -Message "Prerequisites validation passed"
        return $true
    }
    catch {
        Write-VSanLog -Level Error -Message "Prerequisites validation failed: $_"
        return $false
    }
}

function Test-VSanClusterEnabled {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]$Cluster
    )
    
    try {
        $vsanConfig = Get-VsanClusterConfiguration -Cluster $Cluster -ErrorAction Stop
        return $vsanConfig.VsanEnabled
    }
    catch {
        # Fallback for older PowerCLI versions
        return $Cluster.ExtensionData.ConfigurationEx.VsanConfigInfo.Enabled -eq $true
    }
}
#endregion

#region Core Health Functions
function Invoke-VSanHealthCheck {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]$Cluster,
        
        [switch]$UseCache,
        
        [string]$Perspective,
        
        [int]$TimeoutSeconds = 300
    )
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        Write-VSanLog -Level Info -Message "Starting health check for cluster '$($Cluster.Name)'"
        
        $result = $null
        $method = $null
        
        # Try PowerCLI cmdlet first
        if (Get-Command -Name Test-VsanClusterHealth -ErrorAction SilentlyContinue) {
            try {
                $params = @{ 
                    Cluster = $Cluster
                    ErrorAction = 'Stop'
                }
                if ($UseCache) { $params.UseCache = $true }
                if ($Perspective) { $params.Perspective = $Perspective }
                
                $result = Test-VsanClusterHealth @params
                $method = 'PowerCLI-Cmdlet'
            }
            catch {
                Write-VSanLog -Level Warning -Message "PowerCLI cmdlet failed, falling back to API: $_"
            }
        }
        
        # Fallback to vSAN API
        if (-not $result) {
            $vchs = Get-VsanView -Id "VsanVcClusterHealthSystem-vsan-cluster-health-system"
            $clusterMoRef = $Cluster.ExtensionData.MoRef
            
            $fields = @(
                'clusterStatus', 'timestamp', 'overallHealth', 'overallHealthDescription',
                'groups', 'networkHealth', 'physicalDisksHealth', 'diskBalance', 'hclInfo'
            )
            
            $result = $vchs.VsanQueryVcClusterHealthSummary(
                $clusterMoRef,
                $null,
                $null,
                $true,
                $fields,
                [bool]$UseCache,
                ($Perspective ? $Perspective : $null),
                $null,
                $null
            )
            $method = 'vSAN-API'
        }
        
        $stopwatch.Stop()
        Write-VSanLog -Level Info -Message "Health check completed in $($stopwatch.ElapsedMilliseconds)ms using $method"
        
        return [PSCustomObject]@{
            Cluster = $Cluster.Name
            Method = $method
            Duration = $stopwatch.Elapsed
            Result = $result
            Timestamp = Get-Date
        }
    }
    catch {
        $stopwatch.Stop()
        Write-VSanLog -Level Error -Message "Health check failed for cluster '$($Cluster.Name)': $_"
        throw
    }
}

function Get-VSanHostServices {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]$VMHost
    )
    
    try {
        $criticalServices = @('vpxa', 'vmware-fdm', 'ntpd', 'vmsyslogd', 'vsanmgmt', 'vsanmgmtd')
        $services = Get-VMHostService -VMHost $VMHost -ErrorAction Stop
        
        $result = @()
        foreach ($service in $services) {
            if ($criticalServices -contains $service.Key -or $service.Key -match 'vsan') {
                $result += [PSCustomObject]@{
                    Host = $VMHost.Name
                    ServiceKey = $service.Key
                    Label = $service.Label
                    Running = $service.Running
                    Policy = $service.Policy
                    Critical = $criticalServices -contains $service.Key
                    Status = if ($service.Running) { 'OK' } else { 'FAILED' }
                }
            }
        }
        
        return $result
    }
    catch {
        Write-VSanLog -Level Error -Message "Failed to get services for host '$($VMHost.Name)': $_"
        throw
    }
}
#endregion

#region Export Functions
Export-ModuleMember -Function @(
    'Write-VSanLog',
    'Set-VSanLogLevel', 
    'Set-VSanLogPath',
    'Test-VSanPrerequisites',
    'Test-VSanClusterEnabled',
    'Invoke-VSanHealthCheck',
    'Get-VSanHostServices'
)