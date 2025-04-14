# Azure CLI Commands Used in the Project

This document lists all the Azure CLI commands used in the Weather Data Service project. These commands are used to create and manage the Azure resources required for the service.

## Resource Group Management

```bash
# Create a resource group
az group create --name WeatherDataRG --location israelcentral

# Check if a resource group exists
az group exists --name WeatherDataRG
```

## Azure SQL Database

```bash
# Create an Azure SQL Database server
az sql server create --name weatherdb --resource-group WeatherDataRG --location israelcentral --admin-user <your-username> --admin-password <your-password>

# Create an Azure SQL Database
az sql db create --resource-group WeatherDataRG --server weatherdb --name WeatherData --service-objective Basic

# Configure firewall rules to allow Azure services
az sql server firewall-rule create --resource-group WeatherDataRG --server weatherdb --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

# Configure firewall rules to allow your client IP
az sql server firewall-rule create --resource-group WeatherDataRG --server weatherdb --name ClientIPAddress --start-ip-address <your-ip> --end-ip-address <your-ip>
```

## Azure Container Registry (ACR)

```bash
# Create an Azure Container Registry
az acr create --resource-group WeatherDataRG --name weatherdataacr --sku Basic

# Log in to the Azure Container Registry
az acr login --name weatherdataacr

# Enable admin user for the Azure Container Registry
az acr update --name weatherdataacr --admin-enabled true

# Get credentials for the Azure Container Registry
az acr credential show --name weatherdataacr
```

## Azure Kubernetes Service (AKS)

```bash
# Create an Azure Kubernetes Service cluster
az aks create --resource-group WeatherDataRG --name weatherdataaks --node-count 1 --node-vm-size Standard_B2s --generate-ssh-keys --attach-acr weatherdataacr

# Get credentials for the Azure Kubernetes Service cluster
az aks get-credentials --resource-group WeatherDataRG --name weatherdataaks

# Register the Microsoft.Compute provider (if needed)
az provider register --namespace Microsoft.Compute
```

## Azure Container Instances (ACI)

```bash
# Create an Azure Container Instance
az container create --resource-group WeatherDataWE --name weather-data-service --image weatherdataweacr.azurecr.io/weather-data-service:latest --dns-name-label weather-data-service-omer --ports 5000 --os-type Linux --cpu 1 --memory 1.5 --environment-variables DB_SERVER=weatherdb.database.windows.net DB_NAME=WeatherData DB_USER=<your-username> DB_PASSWORD=<your-password> --registry-username weatherdataweacr --registry-password <your-registry-password>

# Delete an Azure Container Instance
az container delete --resource-group WeatherDataRG --name weather-data-collector --yes

# Show details of an Azure Container Instance
az container show --resource-group WeatherDataRG --name weather-data-collector
```

## Docker Commands

```bash
# Build a Docker image
docker build -t weather-data-service:latest .

# Tag a Docker image for Azure Container Registry
docker tag weather-data-service:latest weatherdataacr.azurecr.io/weather-data-service:latest

# Push a Docker image to Azure Container Registry
docker push weatherdataacr.azurecr.io/weather-data-service:latest

# Run a Docker container locally
docker run -d -p 5000:5000 --name weather-api weather-data-service:latest
```

## Kubernetes Commands

```bash
# Apply Kubernetes configuration files
kubectl apply -f kubernetes/secret.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/cronjob.yaml

# Get the external IP address of a service
kubectl get service weather-data-service

# Get the status of pods
kubectl get pods

# Get the status of deployments
kubectl get deployments

# Get the status of services
kubectl get services

# Get the status of cronjobs
kubectl get cronjobs
