# VMware vSAN Health Monitoring

<div align="center">

```
┌─────────────────────────────────────────────────────────────┐
│                  vSAN Health Monitoring                     │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │ vSAN        │────│ Health      │────│ Alert       │     │
│  │ Cluster     │    │ Monitor     │    │ Manager     │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│         │                   │                   │          │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │ Disk        │    │ Performance │    │ Predictive  │     │
│  │ Groups      │    │ Metrics     │    │ Analytics   │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
```
  
  [![vSAN](https://img.shields.io/badge/vSAN-8.0+-00A1C9.svg)](https://www.vmware.com/products/vsan.html)
  [![Health Check](https://img.shields.io/badge/Health-Monitoring-green.svg)](https://docs.vmware.com/en/VMware-vSAN/)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
</div>

## 🏥 Overview

Comprehensive health monitoring and alerting system for VMware vSAN clusters. Proactive monitoring, automated remediation, and detailed reporting for optimal vSAN performance.

## 🎯 Key Features

- **Real-time Health Monitoring**: 24/7 cluster health surveillance
- **Predictive Analytics**: Identify issues before they impact performance
- **Automated Remediation**: Self-healing capabilities for common issues
- **Performance Metrics**: Detailed IOPS, latency, and throughput analysis
- **Capacity Planning**: Growth projections and recommendations
- **Alert Management**: Multi-channel notifications (email, Slack, Teams)

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/uldyssian-sh/vmware-vsan-health.git
cd vmware-vsan-health

# Install dependencies
pip install -r requirements.txt

# Configure vCenter connection
cp config/config.example.yml config/config.yml
# Edit config.yml with your vCenter details

# Run health check
python vsan_health_monitor.py --cluster "Production-Cluster"
```

## 📚 Documentation

- [Installation Guide](https://github.com/uldyssian-sh/vmware-vsan-health/wiki/Installation)
- [Configuration Reference](https://github.com/uldyssian-sh/vmware-vsan-health/wiki/Configuration)
- [Health Checks Guide](https://github.com/uldyssian-sh/vmware-vsan-health/wiki/Health-Checks)

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.
