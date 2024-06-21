# Connect to vCenter
Connect-VIServer -Server "<cluster_vcenter_server>" -User "<username>" -Password "<password>"

# Suggest correct sizing
$vms = Get-VM
$vmRecommendations = @()

foreach ($vm in $vms) {
    $stats = Get-Stat -Entity $vm -Stat cpu.usage.average,mem.usage.average -Realtime -MaxSamples 10
    $cpuAvg = ($stats | Where-Object {$_.MetricId -eq "cpu.usage.average"}).Value | Measure-Object -Average | Select -ExpandProperty Average
    $memAvg = ($stats | Where-Object {$_.MetricId -eq "mem.usage.average"}).Value | Measure-Object -Average | Select -ExpandProperty Average
    
    $recommendation = @{
        VMName = $vm.Name
        CPUUsage = [math]::Round($cpuAvg, 2)
        MemoryUsage = [math]::Round($memAvg, 2)
    }
    
    $vmRecommendations += $recommendation
}

# Disconnect from vCenter
Disconnect-VIServer -Confirm:$false

# Export data to JSON
$vmRecommendations | ConvertTo-Json | Out-File "/data/vm_recommendations.json"
