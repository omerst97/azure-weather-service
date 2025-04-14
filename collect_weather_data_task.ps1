# PowerShell script to run the weather data collection container
# This script can be scheduled using Azure Automation

# Set variables
$resourceGroup = "WeatherDataWE"
$containerName = "weather-data-collector"
$image = "weatherdataweacr.azurecr.io/weather-data-service:latest"
$registryUsername = "weatherdataweacr"
$registryPassword = "<YOUR_REGISTRY_PASSWORD>" # Replace with your actual password when running

# Create a container instance to run the data collection script
az container create `
    --resource-group $resourceGroup `
    --name $containerName `
    --image $image `
    --restart-policy Never `
    --os-type Linux `
    --cpu 1 `
    --memory 1.5 `
    --command-line "python collect_weather_data.py" `
    --environment-variables DB_SERVER=weatherdb.database.windows.net DB_NAME=WeatherData DB_USER=<your-username> DB_PASSWORD=<your-password> `
    --registry-username $registryUsername `
    --registry-password $registryPassword

# Wait for the container to complete
$status = ""
while ($status -ne "Terminated") {
    $containerInfo = az container show --resource-group $resourceGroup --name $containerName | ConvertFrom-Json
    $status = $containerInfo.instanceView.currentState.state
    Write-Output "Container status: $status"
    if ($status -ne "Terminated") {
        Start-Sleep -Seconds 10
    }
}

# Delete the container instance after it's done
az container delete --resource-group $resourceGroup --name $containerName --yes

Write-Output "Weather data collection completed successfully."
