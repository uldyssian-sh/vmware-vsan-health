# VMware vSAN Health Monitor

![GitHub stars](https://img.shields.io/github/stars/uldyssian-sh/vmware-vsan-health)
![GitHub forks](https://img.shields.io/github/forks/uldyssian-sh/vmware-vsan-health)
![License](https://img.shields.io/github/license/uldyssian-sh/vmware-vsan-health)

**Version:** 2.0.0  
**Target:** VMware vSphere 7.x / 8.x  
**PowerShell:** 5.1+ / 7.x  

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
│  │ │ vSAN Storage│ │ │ vSAN Storage│ │ │ vSAN Storage│                     │    │
│  │ │ • Health    │ │ │ • Health    │ │ │ • Health    │                     │    │
│  │ │ • Capacity  │ │ │ • Capacity  │ │ │ • Capacity  │                     │    │
│  │ │ • Performance│ │ │ • Performance│ │ │ • Performance│                   │    │
│  │ └─────────────┘ │ └─────────────┘ │ └─────────────┘                     │    │
│  └─────────────────┴─────────────────┴─────────────────────────────────────┘    │
│                                       │                                         │
│                                       ▼                                         │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                      Health Monitoring Engine                          │    │
│  │              • Real-time Monitoring • Performance Metrics              │    │
│  │              • Health Reports • Alert Management                       │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────┘
```

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

## Requirements

- **PowerShell** 5.1+ (Windows) or 7+ (cross-platform)  
- **VMware PowerCLI** modules:  
  - `VMware.VimAutomation.Core`  
  - `VMware.VimAutomation.Storage`  

Install PowerCLI if needed:
```powershell
Install-Module VMware.PowerCLI -Scope CurrentUser
```

## Usage

1. Clone or download this repository
2. Open a PowerShell or PowerCLI session
3. (Optional) Allow script execution:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```
4. Run the script:
```powershell
.\Invoke-VsanHealth.ps1 -vCenter vcsa.example.com
```

## Examples

Run against all vSAN clusters:
```powershell
.\Invoke-VsanHealth.ps1 -vCenter vcsa.example.com
```

Run against specific clusters:
```powershell
.\Invoke-VsanHealth.ps1 -vCenter vcsa.example.com -Cluster "Prod-*","DR-01"
```

Export results to JSON:
```powershell
.\Invoke-VsanHealth.ps1 -vCenter vcsa.example.com -ExportPath C:\Reports\vsan-health.json
```

## License

MIT License - See LICENSE file for details

## Contributing

Contributions welcome via pull requests and issues.
