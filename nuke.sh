#!/bin/sh

# Get the absolute path to the directory containing this script
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Check if the .env file exists in the same directory as the script
if [ -f "$SCRIPT_DIR/.env" ]; then
    # Source the .env file using its absolute path
    source "$SCRIPT_DIR/.env"
    echo "Loaded environment variables from $SCRIPT_DIR/.env"
else
    echo ".env file not found in $SCRIPT_DIR"
    exit 1
fi

expected_user=$AZ_EMAIL

# Get the current account user's name and trim it
current_user=$(az account show --query "user.name" -o tsv | sed 's/\r$//')

# Check if the current user matches the expected user
if [ "$current_user" == "$expected_user" ]; then
    echo "$current_user matches the expected user. Proceeding with deletion..."
    
    # Get the list of resource group names
    resource_groups=$(az group list --query "[?name!=\`NetworkWatcherRG\`].name" -o tsv | sed 's/\r$//')
    
    # Loop through each resource group and delete it
    for group in $resource_groups
    do
        echo "Deleting resource group: $group"
        az group delete --name $group --yes --no-wait
    done
    
    echo "Deletion process completed."
else
    echo "\"$current_user\"";
    echo "Current $current_user does not match the expected user ($expected_user). Aborting deletion."
fi
