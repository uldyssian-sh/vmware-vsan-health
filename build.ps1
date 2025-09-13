#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build script for VMware vSAN Health Monitor
.DESCRIPTION
    Comprehensive build script that handles testing, validation, packaging, and deployment
.PARAMETER Task
    Build task to execute: Test, Build, Package, Deploy, All
.PARAMETER Configuration
    Build configuration: Debug, Release
.PARAMETER OutputPath
    Output directory for build artifacts
#>

[CmdletBinding()]
param(
    [ValidateSet('Test', 'Build', 'Package', 'Deploy', 'All')]
    [string]$Task = 'All',
    
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',
    
    [string]$OutputPath = './build'
)

$ErrorActionPreference = 'Stop'

# Build configuration
$script:Config = @{
    ModuleName = 'VSanHealthModule'
    Version = '2.0.0'
    OutputPath = $OutputPath
    SourcePath = './src'
    TestPath = './tests'
    DocsPath = './docs'
}

function Write-BuildLog {
    param([string]$Message, [string]$Level = 'Info')
    $timestamp = Get-Date -Format 'HH:mm:ss'
    $color = switch ($Level) {
        'Error' { 'Red' }
        'Warning' { 'Yellow' }
        'Success' { 'Green' }
        default { 'Cyan' }
    }
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
}

function Test-Prerequisites {
    Write-BuildLog "Checking prerequisites..."
    
    $required = @('Pester', 'PSScriptAnalyzer')
    foreach ($module in $required) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-BuildLog "Installing $module..." -Level Warning
            Install-Module -Name $module -Force -SkipPublisherCheck
        }
    }
    
    Write-BuildLog "Prerequisites OK" -Level Success
}

function Invoke-Tests {
    Write-BuildLog "Running tests..."
    
    $config = New-PesterConfiguration
    $config.Run.Path = $script:Config.TestPath
    $config.CodeCoverage.Enabled = $true
    $config.CodeCoverage.Path = $script:Config.SourcePath
    $config.TestResult.Enabled = $true
    $config.TestResult.OutputFormat = 'JUnitXml'
    $config.TestResult.OutputPath = Join-Path $script:Config.OutputPath 'test-results.xml'
    $config.CodeCoverage.OutputPath = Join-Path $script:Config.OutputPath 'coverage.xml'
    
    $result = Invoke-Pester -Configuration $config
    
    if ($result.FailedCount -gt 0) {
        throw "Tests failed: $($result.FailedCount) failed, $($result.PassedCount) passed"
    }
    
    Write-BuildLog "Tests passed: $($result.PassedCount)" -Level Success
}

function Invoke-CodeAnalysis {
    Write-BuildLog "Running code analysis..."
    
    $results = Invoke-ScriptAnalyzer -Path . -Recurse -ReportSummary
    
    if ($results) {
        $results | Format-Table -AutoSize
        $errors = $results | Where-Object Severity -eq 'Error'
        if ($errors) {
            throw "PSScriptAnalyzer found $($errors.Count) error(s)"
        }
        Write-BuildLog "Code analysis completed with $($results.Count) warning(s)" -Level Warning
    } else {
        Write-BuildLog "Code analysis passed" -Level Success
    }
}

function Build-Module {
    Write-BuildLog "Building module..."
    
    $buildPath = Join-Path $script:Config.OutputPath $script:Config.ModuleName
    
    if (Test-Path $buildPath) {
        Remove-Item $buildPath -Recurse -Force
    }
    New-Item -Path $buildPath -ItemType Directory -Force | Out-Null
    
    # Copy module files
    Copy-Item -Path "$($script:Config.SourcePath)/*" -Destination $buildPath -Recurse
    Copy-Item -Path "VSanHealthModule.psd1" -Destination $buildPath
    Copy-Item -Path "LICENSE" -Destination $buildPath
    Copy-Item -Path "README.md" -Destination $buildPath
    
    Write-BuildLog "Module built successfully" -Level Success
}

function New-Package {
    Write-BuildLog "Creating package..."
    
    $packagePath = Join-Path $script:Config.OutputPath 'packages'
    if (-not (Test-Path $packagePath)) {
        New-Item -Path $packagePath -ItemType Directory -Force | Out-Null
    }
    
    $modulePath = Join-Path $script:Config.OutputPath $script:Config.ModuleName
    $zipPath = Join-Path $packagePath "$($script:Config.ModuleName)-$($script:Config.Version).zip"
    
    Compress-Archive -Path "$modulePath/*" -DestinationPath $zipPath -Force
    
    Write-BuildLog "Package created: $zipPath" -Level Success
}

function Publish-Module {
    Write-BuildLog "Publishing module..."
    
    $modulePath = Join-Path $script:Config.OutputPath $script:Config.ModuleName
    
    if ($env:NUGET_API_KEY) {
        Publish-Module -Path $modulePath -NuGetApiKey $env:NUGET_API_KEY -Repository PSGallery
        Write-BuildLog "Module published to PowerShell Gallery" -Level Success
    } else {
        Write-BuildLog "NUGET_API_KEY not found, skipping publish" -Level Warning
    }
}

# Main execution
try {
    Write-BuildLog "Starting build process - Task: $Task, Configuration: $Configuration"
    
    if (-not (Test-Path $script:Config.OutputPath)) {
        New-Item -Path $script:Config.OutputPath -ItemType Directory -Force | Out-Null
    }
    
    Test-Prerequisites
    
    if ($Task -in @('Test', 'All')) {
        Invoke-Tests
        Invoke-CodeAnalysis
    }
    
    if ($Task -in @('Build', 'All')) {
        Build-Module
    }
    
    if ($Task -in @('Package', 'All')) {
        New-Package
    }
    
    if ($Task -eq 'Deploy') {
        Publish-Module
    }
    
    Write-BuildLog "Build completed successfully!" -Level Success
}
catch {
    Write-BuildLog "Build failed: $_" -Level Error
    exit 1
}