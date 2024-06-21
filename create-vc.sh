#!/bin/bash

# Create directories
mkdir -p vmware_vcenter_dashboard
cd vmware_vcenter_dashboard

# Create PowerCLI script files
cat << 'EOF' > check_health.ps1
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
EOF

cat << 'EOF' > suggest_sizing.ps1
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
EOF

cat << 'EOF' > clean_zombie_files.ps1
# Connect to vCenter
Connect-VIServer -Server "<cluster_vcenter_server>" -User "<username>" -Password "<password>"

# Identify and remove zombie files
$datastores = Get-Datastore
$zombieFiles = @()

foreach ($datastore in $datastores) {
    $files = Get-Datastore $datastore | Get-ChildItem -Recurse
    foreach ($file in $files) {
        if ($file.Name -match ".log$" -or $file.Name -match ".vswp$") {
            $zombieFiles += $file
            Remove-Item -Path $file -Confirm:$false
        }
    }
}

# Disconnect from vCenter
Disconnect-VIServer -Confirm:$false

# Export data to JSON
$zombieFiles | ConvertTo-Json | Out-File "/data/zombie_files.json"
EOF

cat << 'EOF' > monitor_resources.ps1
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
EOF

# Create Flask app
mkdir -p flask_app/templates

cat << 'EOF' > flask_app/app.py
from flask import Flask, render_template, jsonify, request
import json

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/health')
def health():
    with open('/data/health_status.json') as f:
        data = json.load(f)
    return jsonify(data)

@app.route('/events')
def events():
    with open('/data/events.json') as f):
        data = json.load(f)
    return jsonify(data)

@app.route('/recommendations')
def recommendations():
    with open('/data/vm_recommendations.json') as f:
        data = json.load(f)
    return jsonify(data)

@app.route('/resource_utilization')
def resource_utilization():
    with open('/data/resource_utilization.json') as f:
        data = json.load(f)
    return jsonify(data)

@app.route('/zombie_files')
def zombie_files():
    with open('/data/zombie_files.json') as f):
        data = json.load(f)
    return jsonify(data)

@app.route('/search')
def search():
    query = request.args.get('q')
    results = []
    with open('/data/vm_recommendations.json') as f:
        data = json.load(f)
        for item in data:
            if query.lower() in item['VMName'].lower():
                results.append(item['VMName'])
    return jsonify(results)

if __name__ == '__main__':
    app.run(debug=True)
EOF

cat << 'EOF' > flask_app/templates/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VMware vCenter Dashboard</title>
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-ui-autocomplete/1.12.1/jquery-ui.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jquery-ui/1.12.1/jquery-ui.min.css">
</head>
<body>
    <div class="container">
        <h1 class="mt-5">VMware vCenter Dashboard</h1>
        <div class="form-group mt-3">
            <label for="search">Search VMs</label>
            <input type="text" id="search" class="form-control" placeholder="Enter VM name">
        </div>
        <div class="mt-3">
            <button id="refresh" class="btn btn-primary">Refresh Data</button>
        </div>
        <div id="data-content" class="mt-5">
            <h2>Health Status</h2>
            <div id="health_status" class="card card-body bg-light"></div>
            <h2 class="mt-3">Events</h2>
            <div id="events" class="card card-body bg-light"></div>
            <h2 class="mt-3">VM Recommendations</h2>
            <div id="vm_recommendations" class="card card-body bg-light"></div>
            <h2 class="mt-3">Resource Utilization</h2>
            <div id="resource_utilization" class="card card-body bg-light"></div>
            <h2 class="mt-3">Zombie Files</h2>
            <div id="zombie_files" class="card card-body bg-light"></div>
        </div>
    </div>

    <script>
        function fetchData() {
            fetch('/health').then(response => response.json()).then(data => {
                $('#health_status').text(JSON.stringify(data, null, 2));
            });
            
            fetch('/events').then(response => response.json()).then(data => {
                $('#events').text(JSON.stringify(data, null, 2));
            });

            fetch('/recommendations').then(response => response.json()).then(data => {
                $('#vm_recommendations').text(JSON.stringify(data, null, 2));
            });

            fetch('/resource_utilization').then(response => response.json()).then(data => {
                $('#resource_utilization').text(JSON.stringify(data, null, 2));
});
        fetch('/zombie_files').then(response => response.json()).then(data => {
            $('#zombie_files').text(JSON.stringify(data, null, 2));
        });
    }

    $(document).ready(function() {
        fetchData();

        $('#refresh').click(function() {
            fetchData();
        });

        $('#search').autocomplete({
            source: function(request, response) {
                fetch('/search?q=' + request.term)
                    .then(response => response.json())
                    .then(data => {
                        response(data);
                    });
            },
            minLength: 2,
            select: function(event, ui) {
                $('#search').val(ui.item.label);
                return false;
            }
        });
    });
</script>
