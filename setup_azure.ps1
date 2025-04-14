# Setup script for Weather Data Service on Azure
# This script sets up the entire environment at once, including:
# - Azure Container Registry (ACR)
# - Azure Kubernetes Service (AKS)
# - Builds and pushes the Docker image
# - Deploys the application to AKS

# Parameters
param(
    [string]$resourceGroupName = "WeatherDataRG",
    [string]$location = "israelcentral",
    [string]$acrName = "weatherdataacr",
    [string]$aksName = "weatherdataaks",
    [string]$aksNodeCount = 1,
    [string]$aksNodeSize = "Standard_B2s"
)

# Login to Azure (uncomment if not already logged in)
# az login

# Ensure the resource group exists
Write-Host "Checking if resource group exists..."
$rgExists = az group exists --name $resourceGroupName
if ($rgExists -eq "false") {
    Write-Host "Creating resource group $resourceGroupName..."
    az group create --name $resourceGroupName --location $location
} else {
    Write-Host "Resource group $resourceGroupName already exists."
}

# Register the Microsoft.Compute provider if not already registered
Write-Host "Registering Microsoft.Compute provider..."
az provider register --namespace Microsoft.Compute

# Create Azure Container Registry (ACR)
Write-Host "Creating Azure Container Registry..."
az acr create --resource-group $resourceGroupName --name $acrName --sku Basic

# Create Azure Kubernetes Service (AKS)
Write-Host "Creating Azure Kubernetes Service..."
az aks create `
    --resource-group $resourceGroupName `
    --name $aksName `
    --node-count $aksNodeCount `
    --node-vm-size $aksNodeSize `
    --enable-managed-identity `
    --generate-ssh-keys `
    --attach-acr $acrName

# Get AKS credentials
Write-Host "Getting AKS credentials..."
az aks get-credentials --resource-group $resourceGroupName --name $aksName

# Log in to ACR
Write-Host "Logging in to ACR..."
az acr login --name $acrName

# Build and push Docker image
Write-Host "Building and pushing Docker image..."
$acrLoginServer = az acr show --name $acrName --query loginServer --output tsv
docker build -t $acrLoginServer/weather-data-service:latest .
docker push $acrLoginServer/weather-data-service:latest

# Update Kubernetes deployment file with ACR name
$deploymentFile = "kubernetes/deployment.yaml"
(Get-Content $deploymentFile) -replace '\${ACR_NAME}', $acrName | Set-Content $deploymentFile

# Apply Kubernetes configurations
Write-Host "Applying Kubernetes configurations..."
kubectl apply -f kubernetes/secret.yaml
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml

# Wait for deployment to be ready
Write-Host "Waiting for deployment to be ready..."
kubectl rollout status deployment/weather-data-service

# Get the service external IP
Write-Host "Getting service external IP..."
$externalIP = kubectl get service weather-data-service -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
$retryCount = 0
$maxRetries = 30

while ([string]::IsNullOrEmpty($externalIP) -and $retryCount -lt $maxRetries) {
    Start-Sleep -Seconds 10
    $externalIP = kubectl get service weather-data-service -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
    $retryCount++
    Write-Host "Waiting for external IP... (Attempt $retryCount of $maxRetries)"
}

if ([string]::IsNullOrEmpty($externalIP)) {
    Write-Host "Could not get external IP after $maxRetries attempts."
    Write-Host "Please check the service status with: kubectl get service weather-data-service"
} else {
    Write-Host "Weather Data Service is now available at: http://$externalIP"
    Write-Host "API endpoints:"
    Write-Host "- http://$externalIP/ (API documentation)"
    Write-Host "- http://$externalIP/cities (List all cities)"
    Write-Host "- http://$externalIP/cities/{city_id} (Get city details)"
    Write-Host "- http://$externalIP/weather/{city_id} (Get weather data for a city)"
    Write-Host "- http://$externalIP/stats/{city_id} (Get weather statistics for a city)"
    Write-Host "- http://$externalIP/hottest (Get the hottest city)"
    Write-Host "- http://$externalIP/coldest (Get the coldest city)"
    Write-Host "- http://$externalIP/windiest (Get the windiest city)"
}

Write-Host "Setup completed!"
