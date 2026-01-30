#!/bin/bash

# Azure SQL Database Cleanup Script
# This script safely removes Azure SQL Database resources
# Use with caution - deletions are permanent!

set -e  # Exit on error

# Configuration - Update these if you used custom names
RESOURCE_GROUP="rg-inventory-app"
SQL_SERVER_NAME=""  # Will prompt if not set
DATABASE_NAME="sqldb-inventory"

echo "=========================================="
echo "Azure SQL Database Cleanup Script"
echo "=========================================="
echo ""
echo "⚠️  WARNING: This will DELETE Azure resources!"
echo "⚠️  This action is IRREVERSIBLE!"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI is not installed."
    echo "Install it from: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in
echo "Checking Azure CLI authentication..."
if ! az account show &> /dev/null; then
    echo "Not logged in. Running 'az login'..."
    az login
fi

echo ""
echo "Current Azure Subscription:"
az account show --query "{Name:name, ID:id, TenantID:tenantId}" -o table
echo ""

# Check if resource group exists
if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    echo "Resource group '$RESOURCE_GROUP' does not exist."
    echo "Nothing to delete."
    exit 0
fi

# List all SQL servers in the resource group
echo "Finding SQL Servers in resource group '$RESOURCE_GROUP'..."
SQL_SERVERS=$(az sql server list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)

if [ -z "$SQL_SERVERS" ]; then
    echo "No SQL servers found in resource group '$RESOURCE_GROUP'."
    echo ""
    read -p "Do you want to delete the empty resource group? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        az group delete --name "$RESOURCE_GROUP" --yes --no-wait
        echo "✓ Resource group deletion initiated (running in background)"
    fi
    exit 0
fi

echo ""
echo "SQL Servers found:"
echo "$SQL_SERVERS"
echo ""

# If SQL_SERVER_NAME is not set, prompt user
if [ -z "$SQL_SERVER_NAME" ]; then
    echo "Enter the SQL Server name to delete (or press Enter to see options):"
    read -r SQL_SERVER_NAME
    
    if [ -z "$SQL_SERVER_NAME" ]; then
        echo ""
        echo "Available SQL Servers:"
        select server in $SQL_SERVERS "Cancel"; do
            if [ "$server" = "Cancel" ]; then
                echo "Operation cancelled."
                exit 0
            elif [ -n "$server" ]; then
                SQL_SERVER_NAME="$server"
                break
            fi
        done
    fi
fi

# Verify server exists
if ! az sql server show --name "$SQL_SERVER_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    echo "Error: SQL Server '$SQL_SERVER_NAME' not found in resource group '$RESOURCE_GROUP'."
    exit 1
fi

# List databases in the server
echo ""
echo "Databases in server '$SQL_SERVER_NAME':"
az sql db list --server "$SQL_SERVER_NAME" --resource-group "$RESOURCE_GROUP" --query "[].{Name:name, Status:status, Size:maxSizeBytes}" -o table
echo ""

# Cleanup options
echo "What would you like to delete?"
echo ""
echo "1) Delete specific database only"
echo "2) Delete entire SQL Server (includes all databases)"
echo "3) Delete entire Resource Group (includes all resources)"
echo "4) Cancel"
echo ""
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        # Delete specific database
        echo ""
        read -p "Enter database name to delete [$DATABASE_NAME]: " db_input
        DB_TO_DELETE="${db_input:-$DATABASE_NAME}"
        
        echo ""
        echo "📋 Summary:"
        echo "  Resource Group: $RESOURCE_GROUP"
        echo "  SQL Server: $SQL_SERVER_NAME"
        echo "  Database: $DB_TO_DELETE"
        echo ""
        read -p "Are you sure you want to delete database '$DB_TO_DELETE'? (yes/no) " confirm
        
        if [ "$confirm" = "yes" ]; then
            echo ""
            echo "Deleting database '$DB_TO_DELETE'..."
            az sql db delete \
                --name "$DB_TO_DELETE" \
                --server "$SQL_SERVER_NAME" \
                --resource-group "$RESOURCE_GROUP" \
                --yes
            echo "✓ Database deleted successfully"
        else
            echo "Operation cancelled."
        fi
        ;;
        
    2)
        # Delete SQL Server
        echo ""
        echo "📋 Summary:"
        echo "  Resource Group: $RESOURCE_GROUP"
        echo "  SQL Server: $SQL_SERVER_NAME"
        echo "  This will delete ALL databases in this server!"
        echo ""
        read -p "Are you sure you want to delete SQL Server '$SQL_SERVER_NAME'? (yes/no) " confirm
        
        if [ "$confirm" = "yes" ]; then
            echo ""
            echo "Deleting SQL Server '$SQL_SERVER_NAME'..."
            az sql server delete \
                --name "$SQL_SERVER_NAME" \
                --resource-group "$RESOURCE_GROUP" \
                --yes
            echo "✓ SQL Server deleted successfully"
            
            # Ask about resource group
            echo ""
            read -p "Delete the resource group '$RESOURCE_GROUP' as well? (y/n) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                az group delete --name "$RESOURCE_GROUP" --yes --no-wait
                echo "✓ Resource group deletion initiated (running in background)"
            fi
        else
            echo "Operation cancelled."
        fi
        ;;
        
    3)
        # Delete entire resource group
        echo ""
        echo "📋 Summary:"
        echo "  Resource Group: $RESOURCE_GROUP"
        echo "  This will delete ALL resources in this group!"
        echo ""
        
        # Show all resources
        echo "Resources that will be deleted:"
        az resource list --resource-group "$RESOURCE_GROUP" --query "[].{Name:name, Type:type}" -o table
        echo ""
        
        read -p "Are you sure you want to delete Resource Group '$RESOURCE_GROUP'? (yes/no) " confirm
        
        if [ "$confirm" = "yes" ]; then
            echo ""
            echo "Deleting Resource Group '$RESOURCE_GROUP'..."
            az group delete --name "$RESOURCE_GROUP" --yes --no-wait
            echo "✓ Resource group deletion initiated (running in background)"
            echo ""
            echo "Note: Deletion may take several minutes to complete."
            echo "Check status with: az group show --name $RESOURCE_GROUP"
            
            # Clean up local .env file
            if [ -f ".env" ]; then
                read -p "Delete local .env file as well? (y/n) " -n 1 -r
                echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm .env
                    echo "✓ Local .env file deleted"
                fi
            fi
        else
            echo "Operation cancelled."
        fi
        ;;
        
    4)
        echo "Operation cancelled."
        exit 0
        ;;
        
    *)
        echo "Invalid choice. Operation cancelled."
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Cleanup Complete"
echo "=========================================="
echo ""
echo "💰 Tip: Verify in Azure Portal that resources are deleted to avoid charges:"
echo "   https://portal.azure.com"
echo ""
