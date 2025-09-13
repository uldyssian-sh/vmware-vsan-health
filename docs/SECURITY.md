# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.0.x   | :white_check_mark: |
| 1.0.x   | :x:                |

## Security Features

### Credential Management
- **Encrypted Credential Files**: Use `Export-Clixml` to create encrypted credential files
- **PSCredential Objects**: Preferred method for passing credentials
- **No Plain Text**: Never store credentials in plain text

### Input Validation
- **Parameter Validation**: All inputs are validated using PowerShell validation attributes
- **Path Validation**: File paths are validated and sanitized
- **Network Validation**: vCenter names are validated against safe patterns

### Logging Security
- **Sensitive Data**: Credentials and sensitive information are never logged
- **Log Rotation**: Implement log rotation to prevent disk space issues
- **Access Control**: Ensure log files have appropriate permissions

## Reporting a Vulnerability

If you discover a security vulnerability, please report it by:

1. **Email**: Send details to security@example.com
2. **GitHub Security**: Use GitHub's private vulnerability reporting
3. **Response Time**: We aim to respond within 48 hours

### What to Include
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if available)

## Security Best Practices

### Deployment
```powershell
# Create encrypted credential file
$cred = Get-Credential
$cred | Export-Clixml -Path "C:\secure\vcenter-creds.xml"

# Use encrypted credentials
.\Invoke-VSanHealthReport.ps1 -vCenter vcsa.lab.local -CredentialFile "C:\secure\vcenter-creds.xml"
```

### Network Security
- Use HTTPS connections only
- Validate SSL certificates
- Implement network segmentation
- Use service accounts with minimal privileges

### Access Control
- Run with least privilege principle
- Use dedicated service accounts
- Implement role-based access control
- Regular credential rotation

### Monitoring
- Monitor script execution
- Log security events
- Implement alerting for failures
- Regular security audits

## Compliance

This project follows:
- PowerShell Security Best Practices
- VMware vSphere Security Guidelines
- Industry standard secure coding practices

## Updates

Security updates are released as needed and communicated through:
- GitHub Security Advisories
- Release notes
- Documentation updates