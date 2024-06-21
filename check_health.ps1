# Connect to vCenter
Connect-VIServer -Server "<cluster_vcenter_server>" -User "<username>" -Password "<password>"

# Check health
$healthStatus = Get-View -ViewType HostSystem | Select Name, @{Name="HealthStatus"; Expression={$_.Summary.OverallStatus}}

# Get events
$events = Get-VIEvent -MaxSamples 100

# Disconnect from vCenter
Disconnect-VIServer -Confirm:$false

# Export data to JSON
$healthStatus | ConvertTo-Json | Out-File "/data/health_status.json"
$events | ConvertTo-Json | Out-File "/data/events.json"
