# monitor_resources.ps1
param (
    [string]$vCenterServer,
    [string]$username,
    [string]$password
)

# Connect to vCenter
Connect-VIServer -Server $vCenterServer -User $username -Password $password

# Monitor resource utilization
$resourceUtilization = @()

$vms = Get-VM
foreach ($vm in $vms) {
    $stats = Get-Stat -Entity $vm -Stat cpu.usage.average,mem.usage.average,disk.usage.average,net.usage.average -Realtime -MaxSamples 10
    $cpuAvg = ($stats | Where-Object {$_.MetricId -eq "cpu.usage.average"}).Value | Measure-Object -Average | Select -ExpandProperty Average
    $memAvg = ($stats | Where-Object {$_.MetricId -eq "mem.usage.average"}).Value | Measure-Object -Average | Select -ExpandProperty Average
    $diskAvg = ($stats | Where-Object {$_.MetricId -eq "disk.usage.average"}).Value | Measure-Object -Average | Select -ExpandProperty Average
    $netAvg = ($stats | Where-Object {$_.MetricId -eq "net.usage.average"}).Value | Measure-Object -Average | Select -ExpandProperty Average
    
    $resourceUtilization += @{
        VMName = $vm.Name
        CPUUsage = [math]::Round($cpuAvg, 2)
        MemoryUsage = [math]::Round($memAvg, 2)
        DiskUsage = [math]::Round($diskAvg, 2)
        NetworkUsage = [math]::Round($netAvg, 2)
    }
}

# Disconnect from vCenter
Disconnect-VIServer -Confirm:$false

# Export data to JSON
$resourceUtilization | ConvertTo-Json | Out-File "/data/resource_utilization.json"