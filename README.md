# VMware vSAN Health Monitor

![GitHub stars](https://img.shields.io/github/stars/uldyssian-sh/vmware-vsan-health)
![Tests](https://github.com/uldyssian-sh/vmware-vsan-health/actions/workflows/test.yml/badge.svg)![GitHub forks](https://img.shields.io/github/forks/uldyssian-sh/vmware-vsan-health)
![License](https://img.shields.io/github/license/uldyssian-sh/vmware-vsan-health)

**Version:** 2.0.0
**Target:** VMware vSphere 7.x / 8.x
**PowerShell:** 5.1+ / 7.x

## Overview

Enterprise-grade PowerShell module for comprehensive VMware vSAN cluster health monitoring.

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        VMware vSphere Environment                           │
├──────────────────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                      vCenter Server                                   │  │
│  │                  • Management Interface                               │  │
│  │                  • API Endpoints                                      │  │
│  │                  • Configuration Database                             │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌──────────────┬──────────────┬──────────────────────────────────────────┐  │
│  │ ESXi Host 1  │ ESXi Host 2  │ ESXi Host 3                              │  │
│  │              │              │                                          │  │
│  │ ┌──────────┐ │ ┌──────────┐ │ ┌──────────┐                             │  │
│  │ │ vSAN     │ │ │ vSAN     │ │ │ vSAN     │                             │  │
│  │ │ Storage  │ │ │ Storage  │ │ │ Storage  │                             │  │
│  │ │ • Health │ │ │ • Health │ │ │ • Health │                             │  │
│  │ │ • Metrics│ │ │ • Metrics│ │ │ • Metrics│                             │  │
│  │ └──────────┘ │ └──────────┘ │ └──────────┘                             │  │
│  └──────────────┴──────────────┴──────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                   Health Monitoring Engine                            │  │
│  │               • Real-time Monitoring                                  │  │
│  │               • Performance Metrics                                   │  │
│  │               • Health Reports                                        │  │
│  │               • Alert Management                                      │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Key Features

🔒 **Security First**
- Encrypted credential management
- Input validation and sanitization
- Secure logging (no sensitive data exposure)

⚡ **Performance Optimized**
- Parallel health check processing
- Configurable concurrency limits
- Intelligent caching mechanisms

📊 **Comprehensive Reporting**
- Multiple output formats (Console, JSON, HTML, CSV)
- Structured logging with configurable levels
- Historical trend analysis

## Requirements

- **PowerShell** 5.1+ (Windows) or 7+ (cross-platform)
- **VMware PowerCLI** modules:
  - `VMware.VimAutomation.Core`
  - `VMware.VimAutomation.Storage`

## Installation

```powershell
Install-Module VMware.PowerCLI -Scope CurrentUser
```

## Usage

```powershell
.\Invoke-VsanHealth.ps1 -vCenter vcsa.example.com
```

## Examples

Run against all vSAN clusters:
```powershell
.\Invoke-VsanHealth.ps1 -vCenter vcsa.example.com
```

Export results to JSON:
```powershell
.\Invoke-VsanHealth.ps1 -vCenter vcsa.example.com -ExportPath C:\Reports\vsan-health.json
```

## License

MIT License - See LICENSE file for details

## Contributing

Contributions welcome via pull requests and issues.
