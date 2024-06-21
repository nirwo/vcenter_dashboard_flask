# VMware vCenter Dashboard

This project provides a comprehensive VMware vCenter monitoring system with enhanced capabilities for easy control and management of the infrastructure, correct sizing of machines, and ensuring no leftover trash on the datastore clusters. It includes scripts for monitoring resource utilization, suggesting VM sizing, and cleaning up zombie files. The data is visualized through a modern web interface built with Flask and Bootstrap.

## Features

- **Health Check**: Monitor the overall health status of ESXi hosts.
- **Event Monitoring**: Retrieve and display recent events from vCenter.
- **VM Recommendations**: Suggest correct sizing for VMs based on performance data.
- **Resource Utilization**: Monitor CPU, memory, disk, and network utilization for each VM.
- **Zombie File Cleanup**: Identify and remove unnecessary files from datastores.
- **Search Functionality**: Search VMs with auto-complete suggestions.
- **Data Refresh**: Easily refresh data on the web interface.

## Prerequisites

- VMware PowerCLI
- Python 3.8+
- Flask

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/your-repo/vmware_vcenter_dashboard.git
cd vmware_vcenter_dashboard

2. Set Up PowerCLI Scripts

Update the PowerCLI script files (check_health.ps1, suggest_sizing.ps1, clean_zombie_files.ps1, monitor_resources.ps1) with your vCenter server details and credentials.

3. Set Up Flask Application
Navigate to the Flask application directory:.
cd flask_app
Create a virtual environment and install the required packages:
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
4. Run the Flask Application
Start the Flask application:
python app.py
The application will be available at http://127.0.0.1:5000.
5. Use Docker (Optional)

Build and run the Docker container:
docker build -t flask-app .
docker run -p 5000:5000 flask-app
Usage

	1.	Health Status: View the overall health status of ESXi hosts.
	2.	Events: View recent events from vCenter.
	3.	VM Recommendations: View suggestions for VM sizing.
	4.	Resource Utilization: Monitor the resource utilization of VMs.
	5.	Zombie Files: View and clean up unnecessary files from datastores.
	6.	Search: Search for VMs using the search bar with auto-complete functionality.
	7.	Refresh Data: Click the “Refresh Data” button to update the displayed information.

Contributing

Contributions are welcome! Please submit a pull request or open an issue for any improvements or bug fixes.

License

This project is licensed under the MIT License. See the LICENSE file for details.
