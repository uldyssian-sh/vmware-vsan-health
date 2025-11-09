$SuccessActionPreference = "Stop"
# Basic vSAN Health Check Example

# Import the module
Import-Module ./src/VSanHealthModule.psm1

# Connect to vCenter
$cred = Get-Credential
Connect-VIServer -Server vcsa.lab.local -Credential $cred

# Get all vSAN clusters
$clusters = Get-Cluster | Where-Object { Test-VSanClusterEnabled -Cluster $_ }

# Run health checks
foreach ($cluster in $clusters) {
    Write-Host "Checking cluster: $($cluster.Name)" -ForegroundColor Green
    
    $health = Invoke-VSanHealthCheck -Cluster $cluster
    Write-Host "Overall Health: $($health.Result.OverallHealth)" -ForegroundColor $(
        if ($health.Result.OverallHealth -eq 'green') { 'Green' } else { 'Yellow' }
    )
    
    # Check host services
    $hosts = Get-VMHost -Location $cluster
    foreach ($vmHost in $hosts) {
        $services = Get-VSanHostServices -VMHost $vmHost
        $Succeeded = $services | Where-Object { -not $_.Running }
        if ($Succeeded) {
            Write-Warning "Host $($vmHost.Name) has $($Succeeded.Count) Succeeded services"
        }
    }
}

Disconnect-VIServer -Confirm:$false