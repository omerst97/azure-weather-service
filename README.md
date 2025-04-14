# Weather Data Service

A service that collects, stores, and analyzes weather data for cities around the world using Azure services.

## Overview

This project implements a weather data service that:
- Collects weather data for any city in the world using the free Open-Meteo API
- Stores the data in Azure SQL Database for future analysis
- Provides REST API endpoints to access the weather data and statistics
- Runs in Azure Kubernetes Service (AKS) using Docker containers

## Architecture

The service consists of the following components:

1. **Data Collection**:
   - Uses the Open-Meteo API (free, no API key required)
   - Collects weather data for the past 30 days
   - Stores data in Azure SQL Database

2. **Database**:
   - Azure SQL Database with three tables:
     - `cities`: Information about cities (name, country, coordinates)
     - `weather_data`: Daily weather data for each city
     - `weather_stats`: Aggregated weather statistics

3. **API Service**:
   - Flask web application providing REST API endpoints
   - Containerized using Docker
   - Deployed to Azure Kubernetes Service (AKS)

4. **Scheduled Data Collection**:
   - Kubernetes CronJob that runs daily to collect the latest weather data

## Prerequisites

- Azure subscription
- Azure CLI installed
- Docker installed
- kubectl installed
- PowerShell (for running the setup script)

## Setup Instructions

### Option 1: Automated Setup

Run the provided PowerShell script to set up the entire environment at once:

```powershell
./setup_azure.ps1
```

This script will:
1. Create or use an existing resource group
2. Create an Azure Container Registry (ACR)
3. Create an Azure Kubernetes Service (AKS) cluster
4. Build and push the Docker image to ACR
5. Deploy the application to AKS
6. Configure the scheduled data collection

### Option 2: Manual Setup

#### 1. Create Azure Resources

```bash
# Login to Azure
az login

# Create a resource group
az group create --name WeatherDataRG --location israelcentral

# Create an Azure SQL Database server (if not already created)
az sql server create --name weatherdb --resource-group WeatherDataRG --location israelcentral --admin-user <your-username> --admin-password <your-password>

# Create an Azure SQL Database
az sql db create --resource-group WeatherDataRG --server weatherdb --name WeatherData --service-objective Basic

# Create an Azure Container Registry
az acr create --resource-group WeatherDataRG --name weatherdataacr --sku Basic

# Create an Azure Kubernetes Service cluster
az aks create \
    --resource-group WeatherDataRG \
    --name weatherdataaks \
    --node-count 1 \
    --node-vm-size Standard_B2s \
    --enable-managed-identity \
    --generate-ssh-keys \
    --attach-acr weatherdataacr
```

#### 2. Set Up the Database

Run the following script to create the necessary tables and collect initial weather data:

```bash
python create_tables.py
python collect_weather_data.py
```

#### 3. Build and Deploy the Application

```bash
# Build the Docker image
docker build -t weatherdataacr.azurecr.io/weather-data-service:latest .

# Push the image to ACR
az acr login --name weatherdataacr
docker push weatherdataacr.azurecr.io/weather-data-service:latest

# Get AKS credentials
az aks get-credentials --resource-group WeatherDataRG --name weatherdataaks

# Deploy to Kubernetes
kubectl apply -f kubernetes/secret.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/cronjob.yaml
```

## Running on a Different Azure Account

If you're receiving this project and need to run it on your own Azure account, the process is simple:

### 1. Prerequisites

Ensure you have the following installed:
- Azure CLI
- Docker
- PowerShell

### 2. Uncomment the Azure Login Line

In `setup_azure.ps1`, uncomment the Azure login line:

```powershell
# Login to Azure
az login
```

### 3. Run the Setup Script

```powershell
./setup_azure.ps1
```

This will:
- Prompt you to log in to your Azure account
- Create all necessary Azure resources
- Build and push the Docker image
- Deploy the application to Azure Kubernetes Service

The script is designed to handle the entire setup process automatically. If you encounter any issues with regional availability or quotas, you can modify the region parameter in the script:

```powershell
[string]$location = "israelcentral"  # Change to your preferred region
```

## API Endpoints

Once deployed, the service provides the following API endpoints:

- `GET /`: API documentation
- `GET /cities`: List all cities
- `GET /cities/{city_id}`: Get city details
- `GET /weather/{city_id}`: Get weather data for a city
- `GET /stats/{city_id}`: Get weather statistics for a city
- `GET /hottest`: Get the hottest city
- `GET /coldest`: Get the coldest city
- `GET /windiest`: Get the windiest city

## Project Structure

```
weather-data-azure/
├── app.py                  # Flask web application
├── collect_weather_data.py # Script to collect weather data
├── create_tables.py        # Script to create database tables
├── Dockerfile              # Docker configuration
├── requirements.txt        # Python dependencies
├── setup_azure.ps1         # Setup script for Azure
├── kubernetes/             # Kubernetes configuration files
│   ├── deployment.yaml     # Deployment configuration
│   ├── service.yaml        # Service configuration
│   ├── secret.yaml         # Secret configuration for database credentials
│   └── cronjob.yaml        # CronJob for scheduled data collection
└── README.md               # Project documentation
```

## Security Considerations

- Database credentials are stored in Kubernetes secrets
- Azure SQL Database firewall is configured to allow connections from AKS
- The application uses environment variables for configuration

## Maintenance and Support

### Updating the Application

1. Make changes to the code
2. Build and push a new Docker image
3. Update the Kubernetes deployment

```bash
docker build -t weatherdataacr.azurecr.io/weather-data-service:latest .
docker push weatherdataacr.azurecr.io/weather-data-service:latest
kubectl rollout restart deployment/weather-data-service
```

### Monitoring

- Use Azure Monitor for monitoring the AKS cluster
- Use Azure SQL Database monitoring for database performance

### Troubleshooting

- Check Kubernetes pod logs: `kubectl logs deployment/weather-data-service`
- Check Kubernetes pod status: `kubectl get pods`
- Check Azure SQL Database connection: `python query_weather_data.py`

## License

This project is licensed under the MIT License - see the LICENSE file for details.
