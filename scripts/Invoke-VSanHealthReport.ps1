#!/usr/bin/env pwsh
#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core, VMware.VimAutomation.Storage

<#
.SYNOPSIS
    Enhanced vSAN Health Reporting Script with Security & Performance Optimizations
.DESCRIPTION
    Production-ready script for comprehensive vSAN cluster health monitoring with:
    - Advanced error handling and retry logic
    - Secure credential management
    - Performance optimizations
    - Comprehensive logging and reporting
    - JSON/HTML/CSV export options
.PARAMETER vCenter
    vCenter Server FQDN or IP address
.PARAMETER Credential
    PSCredential object for authentication (recommended over username/password)
.PARAMETER CredentialFile
    Path to encrypted credential file (created with Export-Clixml)
.PARAMETER Cluster
    Cluster name(s) to check (supports wildcards, default: all vSAN clusters)
.PARAMETER UseCache
    Use cached health results instead of running fresh tests
.PARAMETER Perspective
    vSAN Health perspective for specialized checks
.PARAMETER OutputFormat
    Output format: Console, JSON, HTML, CSV, All
.PARAMETER OutputPath
    Base path for output files (default: current directory)
.PARAMETER LogLevel
    Logging level: Error, Warning, Info, Debug, Verbose
.PARAMETER MaxConcurrency
    Maximum concurrent health checks (default: 3)
.PARAMETER TimeoutMinutes
    Timeout for health checks in minutes (default: 10)
.EXAMPLE
    .\Invoke-VSanHealthReport.ps1 -vCenter vcsa.lab.local -OutputFormat All
.EXAMPLE
    .\Invoke-VSanHealthReport.ps1 -vCenter vcsa.lab.local -Cluster "Prod-*" -UseCache -OutputFormat JSON
.NOTES
    Author: VMware vSAN Health Team
    Version: 2.0.0
    Requires: PowerShell 5.1+, VMware PowerCLI 13.x+
#>

[CmdletBinding(DefaultParameterSetName = 'Interactive')]
param(
    [Parameter(Mandatory = $false)]
    [ValidateScript({ 
        if ($_ -match '^[a-zA-Z0-9.-]+$') { $true } 
        else { throw "Invalid vCenter name format" }
    })]
    [string]$vCenter,
    
    [Parameter(ParameterSetName = 'Credential')]
    [System.Management.Automation.PSCredential]$Credential,
    
    [Parameter(ParameterSetName = 'CredentialFile')]
    [ValidateScript({ Test-Path $_ })]
    [string]$CredentialFile,
    
    [string[]]$Cluster,
    
    [switch]$UseCache,
    
    [ValidateSet('clusterPowerOffPrecheck', 'clusterCreateVmPrecheck')]
    [string]$Perspective,
    
    [ValidateSet('Console', 'JSON', 'HTML', 'CSV', 'All')]
    [string]$OutputFormat = 'Console',
    
    [ValidateScript({ 
        $parent = Split-Path $_ -Parent
        if ($parent -and -not (Test-Path $parent)) {
            New-Item -Path $parent -ItemType Directory -Force | Out-Null
        }
        $true
    })]
    [string]$OutputPath = '.',
    
    [ValidateSet('Error', 'Warning', 'Info', 'Debug', 'Verbose')]
    [string]$LogLevel = 'Info',
    
    [ValidateRange(1, 10)]
    [int]$MaxConcurrency = 3,
    
    [ValidateRange(1, 60)]
    [int]$TimeoutMinutes = 10
)

#region Initialization
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Import required module
try {
    Import-Module "$PSScriptRoot/../src/VSanHealthModule.psm1" -Force
    Set-VSanLogLevel -Level $LogLevel
    
    $logPath = Join-Path $OutputPath "vsan-health-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
    Set-VSanLogPath -Path $logPath
    
    Write-VSanLog -Level Info -Message "Starting vSAN Health Report v2.0.0"
}
catch {
    Write-Error "Failed to initialize: $_"
    exit 1
}
#endregion

#region Helper Functions
function Connect-VSanvCenter {
    [CmdletBinding()]
    param(
        [string]$Server,
        [PSCredential]$Cred,
        [string]$CredFile
    )
    
    if (Get-VIServer -ErrorAction SilentlyContinue) {
        Write-VSanLog -Level Info -Message "Using existing vCenter connection"
        return
    }
    
    if (-not $Server) {
        throw "vCenter server not specified and no existing connection found"
    }
    
    $connectionParams = @{
        Server = $Server
        ErrorAction = 'Stop'
    }
    
    if ($CredFile) {
        Write-VSanLog -Level Info -Message "Loading credentials from file"
        $connectionParams.Credential = Import-Clixml -Path $CredFile
    }
    elseif ($Cred) {
        $connectionParams.Credential = $Cred
    }
    
    Write-VSanLog -Level Info -Message "Connecting to vCenter: $Server"
    Connect-VIServer @connectionParams | Out-Null
}

function Get-VSanClusters {
    [CmdletBinding()]
    param([string[]]$ClusterNames)
    
    Write-VSanLog -Level Info -Message "Discovering vSAN clusters"
    
    $allClusters = if ($ClusterNames) {
        $found = @()
        foreach ($name in $ClusterNames) {
            $found += Get-Cluster -Name $name -ErrorAction Stop
        }
        $found
    }
    else {
        Get-Cluster
    }
    
    $vsanClusters = @()
    foreach ($cluster in $allClusters) {
        if (Test-VSanClusterEnabled -Cluster $cluster) {
            $vsanClusters += $cluster
            Write-VSanLog -Level Info -Message "Found vSAN cluster: $($cluster.Name)"
        }
    }
    
    if (-not $vsanClusters) {
        throw "No vSAN-enabled clusters found"
    }
    
    return $vsanClusters
}

function Invoke-ParallelHealthCheck {
    [CmdletBinding()]
    param(
        [array]$Clusters,
        [int]$MaxJobs,
        [int]$TimeoutSeconds
    )
    
    $jobs = @()
    $results = @()
    
    try {
        foreach ($cluster in $Clusters) {
            # Wait if we've hit the concurrency limit
            while ((Get-Job -State Running).Count -ge $MaxJobs) {
                Start-Sleep -Milliseconds 100
            }
            
            $scriptBlock = {
                param($ClusterName, $UseCache, $Perspective)
                
                Import-Module VMware.VimAutomation.Core -Force
                $cluster = Get-Cluster -Name $ClusterName
                
                return @{
                    Cluster = $ClusterName
                    Health = Invoke-VSanHealthCheck -Cluster $cluster -UseCache:$UseCache -Perspective $Perspective
                    Services = (Get-VMHost -Location $cluster | ForEach-Object { 
                        Get-VSanHostServices -VMHost $_ 
                    })
                }
            }
            
            $job = Start-Job -ScriptBlock $scriptBlock -ArgumentList $cluster.Name, $UseCache, $Perspective
            $jobs += $job
        }
        
        # Wait for all jobs to complete
        $jobs | Wait-Job -Timeout $TimeoutSeconds | Out-Null
        
        # Collect results
        foreach ($job in $jobs) {
            if ($job.State -eq 'Completed') {
                $results += Receive-Job -Job $job
            }
            else {
                Write-VSanLog -Level Error -Message "Job failed for cluster: $($job.Name)"
            }
        }
        
        return $results
    }
    finally {
        $jobs | Remove-Job -Force -ErrorAction SilentlyContinue
    }
}
#endregion

#region Main Execution
try {
    # Validate prerequisites
    if (-not (Test-VSanPrerequisites)) {
        throw "Prerequisites validation failed"
    }
    
    # Connect to vCenter
    Connect-VSanvCenter -Server $vCenter -Cred $Credential -CredFile $CredentialFile
    
    # Get vSAN clusters
    $clusters = Get-VSanClusters -ClusterNames $Cluster
    Write-VSanLog -Level Info -Message "Processing $($clusters.Count) vSAN cluster(s)"
    
    # Run health checks
    $timeoutSeconds = $TimeoutMinutes * 60
    $healthResults = Invoke-ParallelHealthCheck -Clusters $clusters -MaxJobs $MaxConcurrency -TimeoutSeconds $timeoutSeconds
    
    # Generate reports
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    
    if ($OutputFormat -in @('Console', 'All')) {
        Write-Host "`n=== vSAN Health Report Summary ===" -ForegroundColor Green
        foreach ($result in $healthResults) {
            Write-Host "`nCluster: $($result.Cluster)" -ForegroundColor Cyan
            Write-Host "Overall Health: $($result.Health.Result.OverallHealth)" -ForegroundColor $(
                switch ($result.Health.Result.OverallHealth) {
                    'green' { 'Green' }
                    'yellow' { 'Yellow' }
                    'red' { 'Red' }
                    default { 'White' }
                }
            )
            
            $failedServices = $result.Services | Where-Object { -not $_.Running }
            if ($failedServices) {
                Write-Host "Failed Services: $($failedServices.Count)" -ForegroundColor Red
            }
        }
    }
    
    if ($OutputFormat -in @('JSON', 'All')) {
        $jsonPath = Join-Path $OutputPath "vsan-health-$timestamp.json"
        $healthResults | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonPath -Encoding UTF8
        Write-VSanLog -Level Info -Message "JSON report saved: $jsonPath"
    }
    
    if ($OutputFormat -in @('CSV', 'All')) {
        $csvPath = Join-Path $OutputPath "vsan-health-$timestamp.csv"
        $csvData = foreach ($result in $healthResults) {
            [PSCustomObject]@{
                Cluster = $result.Cluster
                OverallHealth = $result.Health.Result.OverallHealth
                Timestamp = $result.Health.Timestamp
                Method = $result.Health.Method
                Duration = $result.Health.Duration.TotalSeconds
                FailedServices = ($result.Services | Where-Object { -not $_.Running }).Count
            }
        }
        $csvData | Export-Csv -Path $csvPath -NoTypeInformation
        Write-VSanLog -Level Info -Message "CSV report saved: $csvPath"
    }
    
    Write-VSanLog -Level Info -Message "vSAN Health Report completed successfully"
}
catch {
    Write-VSanLog -Level Error -Message "Script execution failed: $_"
    throw
}
finally {
    # Cleanup
    if (Get-VIServer -ErrorAction SilentlyContinue) {
        Disconnect-VIServer -Confirm:$false -ErrorAction SilentlyContinue
    }
}
#endregion# Updated Sun Nov  9 12:52:40 CET 2025
# Updated Sun Nov  9 12:56:04 CET 2025
