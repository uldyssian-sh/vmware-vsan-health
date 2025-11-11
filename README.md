# VMware vSAN Health

[![License](https://img.shields.io/github/license/uldyssian-sh/vmware-vsan-health?style=flat-square)](LICENSE)
[![Status](https://img.shields.io/badge/status-active-brightgreen?style=flat-square)](#)
[![Languages](https://img.shields.io/github/languages/count/uldyssian-sh/vmware-vsan-health?style=flat-square)](#)
[![Size](https://img.shields.io/github/repo-size/uldyssian-sh/vmware-vsan-health?style=flat-square)](#)
[![Security Scan](https://img.shields.io/badge/security-scanned-green?style=flat-square)](#)
[![License](https://img.shields.io/github/license/uldyssian-sh/vmware-vsan-health?style=flat-square)](LICENSE)
[![Status](https://img.shields.io/badge/status-active-brightgreen?style=flat-square)](#)
[![Languages](https://img.shields.io/github/languages/count/uldyssian-sh/vmware-vsan-health?style=flat-square)](#)
[![Size](https://img.shields.io/github/repo-size/uldyssian-sh/vmware-vsan-health?style=flat-square)](#)
[![Security Scan](https://img.shields.io/badge/security-scanned-green?style=flat-square)](#)

[![GitHub license](https://img.shields.io/github/license/uldyssian-sh/vmware-vsan-health)](https://github.com/uldyssian-sh/vmware-vsan-health/blob/main/LICENSE)
[![CI](https://github.com/uldyssian-sh/vmware-vsan-health/workflows/CI/badge.svg)](https://github.com/uldyssian-sh/vmware-vsan-health/actions)

## 🚀 Overview

VMware vSAN health monitoring and diagnostic automation tool. Provides comprehensive health checks, performance monitoring, and proactive maintenance for vSAN clusters.

**Technology Stack:** PowerCLI, PowerShell, vSAN API, Performance Metrics

## ✨ Features

- 🏥 **Health Monitoring** - Comprehensive vSAN health checks
- 📊 **Performance Analytics** - Real-time performance metrics
- 🔍 **Proactive Diagnostics** - Early issue detection
- 📈 **Capacity Planning** - Storage capacity forecasting
- 🚨 **Alerting System** - Automated health alerts
- 📋 **Compliance Reporting** - Health compliance reports

## 🛠️ Prerequisites

- PowerCLI 12.0+
- PowerShell 5.1+
- vCenter Server with vSAN
- vSAN cluster access
- Performance monitoring permissions

## 🚀 Quick Start

```powershell
# Clone repository

[![License](https://img.shields.io/github/license/uldyssian-sh/vmware-vsan-health?style=flat-square)](LICENSE)
[![Status](https://img.shields.io/badge/status-active-brightgreen?style=flat-square)](#)
[![Languages](https://img.shields.io/github/languages/count/uldyssian-sh/vmware-vsan-health?style=flat-square)](#)
[![Size](https://img.shields.io/github/repo-size/uldyssian-sh/vmware-vsan-health?style=flat-square)](#)
[![Security Scan](https://img.shields.io/badge/security-scanned-green?style=flat-square)](#)

[![License](https://img.shields.io/github/license/uldyssian-sh/vmware-vsan-health?style=flat-square)](LICENSE)
[![Status](https://img.shields.io/badge/status-active-brightgreen?style=flat-square)](#)
[![Languages](https://img.shields.io/github/languages/count/uldyssian-sh/vmware-vsan-health?style=flat-square)](#)
[![Size](https://img.shields.io/github/repo-size/uldyssian-sh/vmware-vsan-health?style=flat-square)](#)
[![Security Scan](https://img.shields.io/badge/security-scanned-green?style=flat-square)](#)
git clone https://github.com/uldyssian-sh/vmware-vsan-health.git
cd vmware-vsan-health

# Import vSAN health module
Import-Module VMware.PowerCLI
Import-Module .\src\VSanHealthModule.psm1

# Connect to vCenter
Connect-VIServer -Server vcenter.domain.com

# Run health assessment
Invoke-vSANHealthCheck -Cluster "vSAN-Cluster"

# Generate health report
New-vSANHealthReport -Cluster "vSAN-Cluster" -OutputPath "C:\Reports\"
```

## 📋 Health Check Categories

### Hardware Health
- Disk health status
- Controller health
- Network adapter status
- Hardware compatibility
- Firmware versions

### Cluster Health
- Cluster configuration
- Network connectivity
- Storage policies
- Object health
- Resync operations

### Performance Health
- IOPS performance
- Latency metrics
- Throughput analysis
- Cache utilization
- Deduplication ratios

## 🔧 Available Functions

| Function | Description |
|----------|-------------|
| `Invoke-vSANHealthCheck` | Run comprehensive health check |
| `Get-vSANPerformance` | Collect performance metrics |
| `Test-vSANConnectivity` | Test network connectivity |
| `Get-vSANCapacity` | Analyze storage capacity |
| `Set-vSANAlert` | Configure health alerts |

## 📊 Monitoring Examples

```powershell
# Monitor cluster performance
Get-vSANPerformance -Cluster "vSAN-Cluster" -Duration 24 -Interval 5

# Check disk health
Test-vSANDiskHealth -Cluster "vSAN-Cluster" -IncludeDetails

# Analyze capacity trends
Get-vSANCapacityTrend -Cluster "vSAN-Cluster" -Days 30
```

## 🚨 Alerting & Notifications

- Email notifications
- SNMP trap integration
- Webhook support
- Custom alert thresholds
- Escalation procedures

## 📈 Reporting

- Executive dashboards
- Technical health reports
- Performance trend analysis
- Capacity planning reports
- Compliance documentation

## 📚 Documentation

- [API Reference](docs/API.md)
- [Configuration Guide](docs/CONFIGURATION.md)
- [Installation Guide](docs/INSTALLATION.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Contributing Guidelines](docs/CONTRIBUTING.md)

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.<!-- Deployment trigger Wed Sep 17 22:41:02 CEST 2025 -->
