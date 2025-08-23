# vSAN Health Check Script (PowerCLI)

**Author:** LT  
**Version:** 1.0  
**Target:** VMware vSphere 7 / 8  

---

Disclaimer

This script is provided "as is", without any warranty of any kind.
Use it at your own risk. You are solely responsible for reviewing, testing, and implementing it in your own environment.

---


## Overview

This script provides a **read-only** health check for VMware vSAN clusters on vSphere 7.x and 8.x.  
It is designed to run via **PowerCLI** and outputs a detailed report directly to the console, with an optional JSON export.  

The script:
- Runs vSAN health checks at the cluster level (using PowerCLI cmdlets or the vSAN Health API).
- Summarizes failing health groups and checks.
- Verifies the status of important ESXi services (e.g. `vpxa`, `vmware-fdm`, `vsanmgmt`).
- Reports optional resync activity (if available).
- **Does not change any configuration**. Safe to run with read-only permissions.

---

## Features

- ✅ Compatible with **vSphere 7.x and 8.x**  
- ✅ **Read-only**: no configuration changes  
- ✅ Clear **console output** (PowerCLI table format)  
- ✅ Optional **JSON export** for reporting/automation  
- ✅ Works with `Test-VsanClusterHealth` cmdlet or vSAN Health API fallback  

---

## Requirements

- **PowerShell** 5.1+ (Windows) or 7+ (cross-platform)  
- **VMware PowerCLI** modules:  
  - `VMware.VimAutomation.Core`  
  - `VMware.VimAutomation.Storage`  

Install PowerCLI if needed:
```powershell
Install-Module VMware.PowerCLI -Scope CurrentUser

---

Usage
1. Clone or download this repository.
2. Open a PowerShell or PowerCLI session.
3. (Optional) Allow script execution in the current session:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
4. Run the script:
Examples
Run against all vSAN clusters:
.\Invoke-VsanHealth.ps1 -vCenter vcsa.example.com
Run against specific clusters, using cached results:
.\Invoke-VsanHealth.ps1 -vCenter vcsa.example.com -Cluster 'Prod-*','DR-01' -UseCache
Run with a specific health perspective (vSAN 7.0 U3+):
.\Invoke-VsanHealth.ps1 -vCenter vcsa.example.com -Perspective 'clusterPowerOffPrecheck'
Export results to JSON:
.\Invoke-VsanHealth.ps1 -vCenter vcsa.example.com -ExportPath C:\Reports\vsan-health.json

---

Sample Output (console)

=== vSAN Health Report: Prod-Cluster ===
Timestamp         : 08/23/2025 14:22:31
OverallHealth     : green
HCL DB            : 2025-07-15
HealthEngine      : Cmdlet

Failing Groups: none

Host Services:
Host      ServiceKey   Running Policy
----      ----------   ------- ------
esx01     vpxa         True    on
esx01     vmware-fdm   True    on
esx01     vsanmgmt     True    on
...

---

Permissions
* Minimum recommended role: Read-Only at the cluster level.
* Some health checks may require additional read privileges (e.g. Global.Diagnostics).
* No write operations are performed.
