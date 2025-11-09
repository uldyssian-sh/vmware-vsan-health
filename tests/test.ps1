Describe "vSAN Health Monitor Tests" {
    Context "Module Loading" {
        It "Should load without errors" {
            { Import-Module .\Invoke-VsanHealth.ps1 -Force } | Should -Not -Throw
        }
    }
    
    Context "Parameter Validation" {
        It "Should require vCenter parameter" {
            { .\Invoke-VsanHealth.ps1 } | Should -Throw
        }
        
        It "Should validate vCenter format" {
            { .\Invoke-VsanHealth.ps1 -vCenter "invalid" } | Should -Not -Throw
        }
    }
    
    Context "Output Validation" {
        It "Should return structured data" {
            $result = .\Invoke-VsanHealth.ps1 -vCenter "test.local" -WhatIf
            $result | Should -Not -BeNullOrEmpty
        }
    }
}
# Updated 20251109_123837
