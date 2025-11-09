$ErrorActionPreference = "Stop"
BeforeAll {
    Import-Module "$PSScriptRoot/../src/VSanHealthModule.psm1" -Force
}

Describe "VSanHealthModule" {
    Context "Logging Functions" {
        It "Should set log level correctly" {
            Set-VSanLogLevel -Level 'Debug'
            $script:LogLevel | Should -Be 'Debug'
        }
        
        It "Should create log directory when setting log path" {
            $testPath = Join-Path $TestDrive "logs/test.log"
            Set-VSanLogPath -Path $testPath
            Split-Path $testPath -Parent | Should -Exist
        }
        
        It "Should write log entries with proper format" {
            $testPath = Join-Path $TestDrive "test.log"
            Set-VSanLogPath -Path $testPath
            
            Write-VSanLog -Level 'Info' -Message 'Test message'
            
            $logContent = Get-Content $testPath
            $logContent | Should -Match '\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] \[Info\] \[VSanHealth\] Test message'
        }
    }
    
    Context "Validation Functions" {
        It "Should validate PowerShell version" {
            Mock Get-Module { @{ Name = 'VMware.VimAutomation.Core' }, @{ Name = 'VMware.VimAutomation.Storage' } }
            Mock Import-Module { }
            Mock Get-VIServer { @{ Name = 'test-vc' } }
            
            Test-VSanPrerequisites | Should -Be $true
        }
        
        It "Should fail when required modules are missing" {
            Mock Get-Module { $null }
            
            Test-VSanPrerequisites | Should -Be $false
        }
    }
    
    Context "Health Check Functions" {
        BeforeEach {
            $mockCluster = [PSCustomObject]@{
                Name = 'TestCluster'
                ExtensionData = [PSCustomObject]@{
                    MoRef = 'cluster-123'
                }
            }
        }
        
        It "Should return health check result with proper structure" {
            Mock Test-VsanClusterHealth { 
                [PSCustomObject]@{
                    OverallHealth = 'green'
                    Timestamp = Get-Date
                }
            }
            Mock Get-Command { @{ Name = 'Test-VsanClusterHealth' } }
            
            $result = Invoke-VSanHealthCheck -Cluster $mockCluster
            
            $result.Cluster | Should -Be 'TestCluster'
            $result.Method | Should -Be 'PowerCLI-Cmdlet'
            $result.Result | Should -Not -BeNullOrEmpty
        }
        
        It "Should handle cmdlet failures gracefully" {
            Mock Test-VsanClusterHealth { throw "Cmdlet failed" }
            Mock Get-Command { @{ Name = 'Test-VsanClusterHealth' } }
            Mock Get-VsanView { 
                [PSCustomObject]@{
                    VsanQueryVcClusterHealthSummary = { 
                        param($a,$b,$c,$d,$e,$f,$g,$h,$i)
                        return [PSCustomObject]@{ OverallHealth = 'yellow' }
                    }
                }
            }
            
            $result = Invoke-VSanHealthCheck -Cluster $mockCluster
            
            $result.Method | Should -Be 'vSAN-API'
        }
    }
    
    Context "Host Services" {
        It "Should return critical services with proper status" {
            $mockHost = [PSCustomObject]@{ Name = 'esx01.lab.local' }
            $mockServices = @(
                [PSCustomObject]@{ Key = 'vpxa'; Label = 'VMware vCenter Agent'; Running = $true; Policy = 'on' },
                [PSCustomObject]@{ Key = 'vsanmgmt'; Label = 'vSAN Management'; Running = $false; Policy = 'on' }
            )
            
            Mock Get-VMHostService { $mockServices }
            
            $result = Get-VSanHostServices -VMHost $mockHost
            
            $result | Should -HaveCount 2
            $result[0].Status | Should -Be 'OK'
            $result[1].Status | Should -Be 'FAILED'
            $result[0].Critical | Should -Be $true
        }
    }
}

Describe "Integration Tests" -Tag 'Integration' {
    It "Should handle module import without errors" {
        { Import-Module "$PSScriptRoot/../src/VSanHealthModule.psm1" -Force } | Should -Not -Throw
    }
    
    It "Should export all required functions" {
        $module = Get-Module VSanHealthModule
        $exportedFunctions = $module.ExportedFunctions.Keys
        
        $expectedFunctions = @(
            'Write-VSanLog', 'Set-VSanLogLevel', 'Set-VSanLogPath',
            'Test-VSanPrerequisites', 'Test-VSanClusterEnabled',
            'Invoke-VSanHealthCheck', 'Get-VSanHostServices'
        )
        
        foreach ($func in $expectedFunctions) {
            $exportedFunctions | Should -Contain $func
        }
    }
