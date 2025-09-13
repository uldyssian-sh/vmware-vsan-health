#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installation script for VSanHealthModule
.DESCRIPTION
    Automated installation with dependency checking and validation
#>

[CmdletBinding()]
param(
    [ValidateSet('CurrentUser', 'AllUsers')]
    [string]$Scope = 'CurrentUser',
    
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Test-PowerShellVersion {
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        throw "PowerShell 5.1 or higher required. Current: $($PSVersionTable.PSVersion)"
    }
    Write-Host "✓ PowerShell version check passed" -ForegroundColor Green
}

function Install-Dependencies {
    $dependencies = @(
        @{ Name = 'VMware.PowerCLI'; MinVersion = '13.0.0' },
        @{ Name = 'Pester'; MinVersion = '5.0.0' },
        @{ Name = 'PSScriptAnalyzer'; MinVersion = '1.20.0' }
    )
    
    foreach ($dep in $dependencies) {
        $installed = Get-Module -ListAvailable -Name $dep.Name | 
            Where-Object { $_.Version -ge [version]$dep.MinVersion } | 
            Select-Object -First 1
            
        if (-not $installed) {
            Write-Host "Installing $($dep.Name)..." -ForegroundColor Yellow
            Install-Module -Name $dep.Name -Scope $Scope -Force:$Force -SkipPublisherCheck
        }
        Write-Host "✓ $($dep.Name) available" -ForegroundColor Green
    }
}

function Install-VSanModule {
    $modulePath = Join-Path $PSScriptRoot "../src/VSanHealthModule.psm1"
    
    if (-not (Test-Path $modulePath)) {
        throw "Module file not found: $modulePath"
    }
    
    # Test import
    Import-Module $modulePath -Force
    Write-Host "✓ VSanHealthModule imported successfully" -ForegroundColor Green
    
    # Run basic validation
    if (Get-Command -Module VSanHealthModule) {
        Write-Host "✓ Module functions available" -ForegroundColor Green
    }
}

try {
    Write-Host "Installing VSanHealthModule..." -ForegroundColor Cyan
    
    Test-PowerShellVersion
    Install-Dependencies
    Install-VSanModule
    
    Write-Host "`n✅ Installation completed successfully!" -ForegroundColor Green
    Write-Host "Usage: Import-Module ./src/VSanHealthModule.psm1" -ForegroundColor Cyan
}
catch {
    Write-Error "Installation failed: $_"
    exit 1
}