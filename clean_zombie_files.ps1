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
