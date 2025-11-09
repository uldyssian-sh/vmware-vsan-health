# Contributing to VMware vSAN Health Monitor

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code.

## How to Contribute

### Reporting Issues
- Use GitHub Issues to report bugs
- Include PowerShell version, PowerCLI version, and vSphere version
- Provide steps to reproduce the issue
- Include relevant log files (sanitized)

### Feature Requests
- Use GitHub Issues with the "enhancement" label
- Describe the use case and expected behavior
- Consider backward compatibility

### Pull Requests
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Update documentation
7. Commit your changes (`git commit -m 'Add amazing feature'`)
8. Push to the branch (`git push origin feature/amazing-feature`)
9. Open a Pull Request

## Development Setup

### Prerequisites
```powershell
# Install required modules
Install-Module VMware.PowerCLI -Scope CurrentUser
Install-Module Pester -Scope CurrentUser
Install-Module PSScriptAnalyzer -Scope CurrentUser
```

### Running Tests
```powershell
# Run all tests
Invoke-Pester

# Run with coverage
$config = New-PesterConfiguration
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = './src'
Invoke-Pester -Configuration $config
```

### Code Quality
```powershell
# Run PSScriptAnalyzer
Invoke-ScriptAnalyzer -Path . -Recurse
```

## Coding Standards

### PowerShell Style Guide
- Use approved verbs for function names
- Follow PascalCase for functions and parameters
- Use camelCase for variables
- Include comprehensive help documentation
- Use `[CmdletBinding()]` for advanced functions

### Error Handling
```powershell
# Good
try {
    $result = Get-SomeData -ErrorAction Stop
}
catch {
    Write-VSanLog -Level Error -Message "Operation failed: $_"
    throw
}

# Bad
$result = Get-SomeData
if (-not $result) {
    Write-Host "Failed"
}
```

### Logging
```powershell
# Use structured logging
Write-VSanLog -Level Info -Message "Starting operation" -Component "HealthCheck"

# Include context
Write-VSanLog -Level Error -Message "Failed to connect to cluster '$ClusterName': $_"
```

## Testing Guidelines

### Unit Tests
- Test all public functions
- Mock external dependencies
- Test error conditions
- Aim for >80% code coverage

### Integration Tests
- Test against real vSphere environments when possible
- Use test environments, never production
- Clean up test resources

### Test Structure
```powershell
Describe "Function-Name" {
    Context "When condition" {
        It "Should do something" {
            # Arrange
            $input = "test"

            # Act
            $result = Invoke-Function -Parameter $input

            # Assert
            $result | Should -Be "expected"
        }
    }
}
```

## Documentation

### Code Documentation
- Include comprehensive help for all functions
- Use proper PowerShell help syntax
- Include examples for complex functions

### README Updates
- Update README.md for new features
- Include usage examples
- Update version information

### API Documentation
- Document all parameters
- Include parameter validation rules
- Provide usage examples

## Release Process

### Versioning
- Follow Semantic Versioning (SemVer)
- Major: Breaking changes
- Minor: New features (backward compatible)
- Patch: Bug fixes

### Release Checklist
- [ ] All tests pass
- [ ] Documentation updated
- [ ] Version numbers updated
- [ ] CHANGELOG.md updated
- [ ] Security review completed

## Performance Guidelines

### Optimization
- Use pipeline processing where possible
- Minimize object creation in loops
- Use appropriate data structures
- Profile performance-critical code

### Scalability
- Support parallel processing
- Implement timeout mechanisms
- Handle large datasets efficiently
- Consider memory usage

## Security Considerations

### Secure Coding
- Validate all inputs
- Use secure credential handling
- Avoid logging sensitive data
- Follow principle of least privilege

### Dependencies
- Keep dependencies minimal
- Use only trusted modules
- Regular security updates
- Vulnerability scanning

## Questions?

If you have questions about contributing:
- Open a GitHub Discussion
- Check existing issues and PRs
- Review the documentation

Thank you for contributing!# Updated Sun Nov  9 12:49:22 CET 2025
# Updated Sun Nov  9 12:52:40 CET 2025
# Updated Sun Nov  9 12:56:04 CET 2025
