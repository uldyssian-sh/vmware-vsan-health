# API Documentation

## VSanHealthModule Functions

### Write-VSanLog
Writes structured log entries with configurable levels.

```powershell
Write-VSanLog -Level Info -Message "Operation completed" -Component "HealthCheck"
```

### Test-VSanPrerequisites
Validates system prerequisites and PowerCLI modules.

```powershell
$isReady = Test-VSanPrerequisites
```

### Invoke-VSanHealthCheck
Performs comprehensive vSAN cluster health assessment.

```powershell
$result = Invoke-VSanHealthCheck -Cluster $cluster -UseCache -TimeoutSeconds 300
```

### Get-VSanHostServices
Retrieves critical ESXi service status information.

```powershell
$services = Get-VSanHostServices -VMHost $host
```

## Return Objects

### Health Check Result
```json
{
  "Cluster": "string",
  "Method": "PowerCLI-Cmdlet|vSAN-API",
  "Duration": "TimeSpan",
  "Result": "object",
  "Timestamp": "DateTime"
}
```

### Service Status
```json
{
  "Host": "string",
  "ServiceKey": "string",
  "Running": "boolean",
  "Critical": "boolean",
  "Status": "OK|FAILED"
}
```