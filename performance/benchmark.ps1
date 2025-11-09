# Performance Benchmark Script

param(
    [int]$Iterations = 10,
    [string]$OutputPath = "./performance"
)

if (-not (Test-Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
}

Import-Module ./src/VSanHealthModule.psm1 -Force

# Mock cluster for testing
$mockCluster = [PSCustomObject]@{
    Name = 'BenchmarkCluster'
    ExtensionData = [PSCustomObject]@{
        MoRef = 'cluster-benchmark'
    }
}

# Benchmark health check performance
$results = @()

for ($i = 1; $i -le $Iterations; $i++) {
    Write-Progress -Activity "Running benchmark" -Status "Iteration $i of $Iterations" -PercentComplete (($i / $Iterations) * 100)
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        # Simulate health check
        Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 500)
        $stopwatch.Stop()
        
        $results += [PSCustomObject]@{
            Iteration = $i
            Duration = $stopwatch.ElapsedMilliseconds
            Success = $true
            Timestamp = Get-Date
        }
    }
    catch {
        $stopwatch.Stop()
        $results += [PSCustomObject]@{
            Iteration = $i
            Duration = $stopwatch.ElapsedMilliseconds
            Success = $false
            Error = $_.Exception.Message
            Timestamp = Get-Date
        }
    }
}

# Generate performance report
$stats = $results | Where-Object Success | Measure-Object Duration -Average -Minimum -Maximum

$report = [PSCustomObject]@{
    TotalIterations = $Iterations
    SuccessfulRuns = ($results | Where-Object Success).Count
    AverageDuration = [math]::Round($stats.Average, 2)
    MinDuration = $stats.Minimum
    MaxDuration = $stats.Maximum
    Timestamp = Get-Date
}

$reportPath = Join-Path $OutputPath "benchmark-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$report | ConvertTo-Json | Set-Content -Path $reportPath

Write-Host "`nPerformance Benchmark Results:" -ForegroundColor Green
Write-Host "Average Duration: $($report.AverageDuration)ms" -ForegroundColor Cyan
Write-Host "Min Duration: $($report.MinDuration)ms" -ForegroundColor Cyan  
Write-Host "Max Duration: $($report.MaxDuration)ms" -ForegroundColor Cyan
Write-Host "Success Rate: $(($report.SuccessfulRuns / $report.TotalIterations * 100))%" -ForegroundColor Cyan
Write-Host "Report saved: $reportPath" -ForegroundColor Yellow# Updated Sun Nov  9 12:52:40 CET 2025
