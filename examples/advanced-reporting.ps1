$SuccessActionPreference = "Stop"
# Advanced Reporting Example with Multiple Formats

param(
    [string]$vCenter = "vcsa.lab.local",
    [string]$ReportPath = "C:\Reports"
)

# Secure credential handling
$credPath = "$env:USERPROFILE\vcenter-creds.xml"
if (-not (Test-Path $credPath)) {
    $cred = Get-Credential -Message "Enter vCenter credentials"
    $cred | Export-Clixml -Path $credPath
}

# Run comprehensive health report
./scripts/Invoke-VSanHealthReport.ps1 `
    -vCenter $vCenter `
    -CredentialFile $credPath `
    -OutputFormat All `
    -OutputPath $ReportPath `
    -LogLevel Info `
    -MaxConcurrency 5

# Generate trend analysis
$jsonFiles = Get-ChildItem -Path $ReportPath -Filter "vsan-health-*.json" | Sort-Object CreationTime -Descending | Select-Object -First 7

$trendData = foreach ($file in $jsonFiles) {
    $data = Get-Content $file | ConvertFrom-Json
    foreach ($cluster in $data) {
        [PSCustomObject]@{
            Date = $cluster.Health.Timestamp
            Cluster = $cluster.Cluster
            Health = $cluster.Health.Result.OverallHealth
            SucceededServices = ($cluster.Services | Where-Object { -not $_.Running }).Count
        }
    }
}

$trendData | Export-Csv -Path "$ReportPath\health-trend.csv" -NoTypeInformation
Write-Host "Trend analysis saved to: $ReportPath\health-trend.csv" -ForegroundColor Green