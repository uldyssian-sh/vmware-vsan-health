# VMware vSAN Health Monitor

[![PowerShell CI/CD](https://github.com/uldyssian-sh/vmware-vsan-health/actions/workflows/powershell-ci.yml/badge.svg)](https://github.com/uldyssian-sh/vmware-vsan-health/actions/workflows/powershell-ci.yml)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/VSanHealthModule)](https://www.powershellgallery.com/packages/VSanHealthModule)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Security Rating](https://img.shields.io/badge/Security-A-green)](docs/SECURITY.md)

**Version:** 2.0.0  
**Target:** VMware vSphere 7.x / 8.x  
**PowerShell:** 5.1+ / 7.x  

---

## License for This Repository
This repository’s own content (README, file list, structure) is licensed under the MIT License. See LICENSE for details.

---

Disclaimer

This script is provided "as is", without any warranty of any kind.
Use it at your own risk. You are solely responsible for reviewing, testing, and implementing it in your own environment.

---


## Overview

Enterprise-grade PowerShell module for comprehensive VMware vSAN cluster health monitoring. Designed for production environments with advanced security, performance optimizations, and extensive reporting capabilities.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           VMware vSphere Environment                           │
├─────────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                        vCenter Server                                  │    │
│  │                    • Management Interface                              │    │
│  │                    • API Endpoints                                     │    │
│  │                    • Configuration Database                            │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                       │                                         │
│                                       ▼                                         │
│  ┌─────────────────┬─────────────────┬─────────────────────────────────────┐    │
│  │   ESXi Host 1   │   ESXi Host 2   │   ESXi Host 3                       │    │
│  │                 │                 │                                     │    │
│  │ ┌─────────────┐ │ ┌─────────────┐ │ ┌─────────────┐                     │    │
│  │ │ Virtual     │ │ │ Virtual     │ │ │ Virtual     │                     │    │
│  │ │ Machines    │ │ │ Machines    │ │ │ Machines    │                     │    │
│  │ │             │ │ │             │ │ │             │                     │    │
│  │ │ • Security  │ │ │ • Security  │ │ │ • Security  │                     │    │
│  │ │ • Config    │ │ │ • Config    │ │ │ • Config    │                     │    │
│  │ │ • Compliance│ │ │ • Compliance│ │ │ • Compliance│                     │    │
│  │ └─────────────┘ │ └─────────────┘ │ └─────────────┘                     │    │
│  └─────────────────┴─────────────────┴─────────────────────────────────────┘    │
│                                       │                                         │
│                                       ▼                                         │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                      Audit & Compliance Engine                         │    │
│  │              • Security Checks • Configuration Validation              │    │
│  │              • Compliance Reports • Remediation Guidance               │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Author**: LT - [GitHub Profile](https://github.com/uldyssian-sh)

### Key Features

🔒 **Security First**
- Encrypted credential management
- Input validation and sanitization
- Secure logging (no sensitive data exposure)
- Role-based access control support

⚡ **Performance Optimized**
- Parallel health check processing
- Configurable concurrency limits
- Intelligent caching mechanisms
- Timeout and retry logic

📊 **Comprehensive Reporting**
- Multiple output formats (Console, JSON, HTML, CSV)
- Structured logging with configurable levels
- Historical trend analysis
- Integration-ready APIs

🛡️ **Production Ready**
- Extensive error handling
- Comprehensive test coverage
- CI/CD pipeline integration
- Monitoring and alerting support

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
