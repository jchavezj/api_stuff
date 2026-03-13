param (
    [bool]$DryRun = $false # Default is to not perform a dry run
)

# Define the API endpoints and headers
$toriiApiUrl = "https://api.torii.com/applications" # Replace with the correct Torii API endpoint
$freshServiceApiUrl = "https://your_domain.freshservice.com/api/v2/custom_objects/toriiapplication" # Replace with your Freshservice domain
$freshServiceApiKey = "your_freshservice_api_key" # Your Freshservice API Key
$toriiApiKey = "your_torii_api_key" # Your Torii API Key
$workspaceId = 2

# Function to get applications from Torii
function Get-ToriiApplications {
    $response = Invoke-RestMethod -Uri $toriiApiUrl -Method Get -Headers @{
        "Authorization" = "Bearer $toriiApiKey" # Use the Torii API Key
    }
    return $response
}

# Function to create a custom object in Freshservice
function Create-FreshserviceCustomObject {
    param (
        [string]$applicationName,
        [string]$toriiAppId
    )

    $body = @{
        "name" = $applicationName
        "toriiappid" = $toriiAppId
    } | ConvertTo-Json

    if ($DryRun) {
        # If it's a dry run, just output the information to the console
        Write-Host "Dry Run: Would create custom object with Name: '$applicationName' and Torii ID: '$toriiAppId'"
    } else {
        # Perform the actual API call
        Invoke-RestMethod -Uri $freshServiceApiUrl -Method Post -Headers @{
            "Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$freshServiceApiKey:X")) # Basic Auth
            "Content-Type" = "application/json"
        } -Body $body
        Write-Host "Created custom object for application: '$applicationName'."
    }
}

# Main script execution
$toriiApplications = Get-ToriiApplications

foreach ($app in $toriiApplications) {
    $applicationName = $app.name # Adjust based on the actual response structure
    $toriiAppId = $app.id # Adjust based on the actual response structure

    # Create the custom object in Freshservice
    Create-FreshserviceCustomObject -applicationName $applicationName -toriiAppId $toriiAppId
}

if (-not $DryRun) {
    Write-Host "All applications have been inserted into Freshservice."
} else {
    Write-Host "Dry run completed. No changes made."
}
