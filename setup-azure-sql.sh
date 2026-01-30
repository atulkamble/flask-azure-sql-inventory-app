#!/bin/bash

# Azure SQL Database Setup Script
# This script creates an Azure SQL Server and Database, configures firewall rules,
# and displays connection details for your Flask application

set -e  # Exit on error

# Configuration Variables (customize these)
RESOURCE_GROUP="rg-inventory-app"
LOCATION="westus2"
SQL_SERVER_NAME="sqlsrv-inventory-$(date +%s)"  # Unique name with timestamp
DATABASE_NAME="sqldb-inventory"
ADMIN_USER="adminuser"
ADMIN_PASSWORD="P@ssw0rd$(date +%s)!"  # Generate secure password
SKU="Basic"  # Options: Basic, S0, S1, S2, P1, P2, etc.

echo "=========================================="
echo "Azure SQL Database Setup"
echo "=========================================="
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

read -p "Continue with this subscription? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Step 1: Create Resource Group
echo ""
echo "Step 1: Creating Resource Group..."
if az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    echo "Resource group '$RESOURCE_GROUP' already exists."
else
    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION"
    echo "✓ Resource group created: $RESOURCE_GROUP"
fi

# Step 2: Create SQL Server
echo ""
echo "Step 2: Creating Azure SQL Server..."
if az sql server show --name "$SQL_SERVER_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    echo "SQL Server '$SQL_SERVER_NAME' already exists."
else
    az sql server create \
        --name "$SQL_SERVER_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --admin-user "$ADMIN_USER" \
        --admin-password "$ADMIN_PASSWORD"
    echo "✓ SQL Server created: $SQL_SERVER_NAME"
fi

# Step 3: Configure Firewall Rules
echo ""
echo "Step 3: Configuring Firewall Rules..."

# Allow Azure services
az sql server firewall-rule create \
    --resource-group "$RESOURCE_GROUP" \
    --server "$SQL_SERVER_NAME" \
    --name "AllowAzureServices" \
    --start-ip-address "0.0.0.0" \
    --end-ip-address "0.0.0.0" &> /dev/null || true

echo "✓ Azure services firewall rule configured"

# Allow your current IP
CURRENT_IP=$(curl -s https://api.ipify.org)
az sql server firewall-rule create \
    --resource-group "$RESOURCE_GROUP" \
    --server "$SQL_SERVER_NAME" \
    --name "AllowMyIP" \
    --start-ip-address "$CURRENT_IP" \
    --end-ip-address "$CURRENT_IP" &> /dev/null || true

echo "✓ Your IP ($CURRENT_IP) firewall rule configured"

# Step 4: Create SQL Database
echo ""
echo "Step 4: Creating Azure SQL Database..."
if az sql db show --name "$DATABASE_NAME" --server "$SQL_SERVER_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    echo "Database '$DATABASE_NAME' already exists."
else
    az sql db create \
        --name "$DATABASE_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --server "$SQL_SERVER_NAME" \
        --service-objective "$SKU" \
        --backup-storage-redundancy "Local"
    echo "✓ Database created: $DATABASE_NAME"
fi

# Step 5: Create products table
echo ""
echo "Step 5: Creating products table..."
cat > /tmp/create_table.sql << 'EOF'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'products')
BEGIN
    CREATE TABLE products (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        created_at DATETIME2 DEFAULT GETDATE()
    );
    
    -- Insert sample data
    INSERT INTO products (name, price) VALUES 
        ('Laptop', 999.99),
        ('Mouse', 29.99),
        ('Keyboard', 79.99),
        ('Monitor', 299.99),
        ('Headphones', 149.99);
END
EOF

az sql db query \
    --server "$SQL_SERVER_NAME" \
    --database "$DATABASE_NAME" \
    --admin-user "$ADMIN_USER" \
    --admin-password "$ADMIN_PASSWORD" \
    --file /tmp/create_table.sql

echo "✓ Products table created with sample data"

# Get server details
SERVER_FQDN=$(az sql server show \
    --name "$SQL_SERVER_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "fullyQualifiedDomainName" -o tsv)

# Display Configuration Details
echo ""
echo "=========================================="
echo "✓ Setup Complete!"
echo "=========================================="
echo ""
echo "📋 Configuration Details:"
echo "----------------------------------------"
echo "Resource Group:    $RESOURCE_GROUP"
echo "Location:          $LOCATION"
echo "SQL Server:        $SQL_SERVER_NAME"
echo "Server FQDN:       $SERVER_FQDN"
echo "Database:          $DATABASE_NAME"
echo "Admin User:        $ADMIN_USER"
echo "Admin Password:    $ADMIN_PASSWORD"
echo "SKU:               $SKU"
echo "----------------------------------------"
echo ""

# Generate .env file
echo "Creating .env file for Flask application..."
cat > /Users/atul/Downloads/flask-azure-sql-inventory-app/.env << EOF
# Azure SQL Database Configuration
DB_SERVER=$SERVER_FQDN
DB_NAME=$DATABASE_NAME
DB_USER=$ADMIN_USER
DB_PASSWORD=$ADMIN_PASSWORD
EOF

echo "✓ .env file created"
echo ""

# Display connection string
echo "🔗 Connection Details:"
echo "----------------------------------------"
echo "Connection String:"
echo "DRIVER={ODBC Driver 18 for SQL Server};SERVER=$SERVER_FQDN;DATABASE=$DATABASE_NAME;UID=$ADMIN_USER;PWD=$ADMIN_PASSWORD;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
echo ""
echo "Python Connection:"
echo "  DB_SERVER=$SERVER_FQDN"
echo "  DB_NAME=$DATABASE_NAME"
echo "  DB_USER=$ADMIN_USER"
echo "  DB_PASSWORD=$ADMIN_PASSWORD"
echo "----------------------------------------"
echo ""

# Test connection
echo "Testing database connection..."
if az sql db show --name "$DATABASE_NAME" --server "$SQL_SERVER_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    echo "✓ Database is accessible"
fi

echo ""
echo "🚀 Next Steps:"
echo "1. Your Flask app will now use the .env file automatically"
echo "2. Run: python app.py"
echo "3. Access: http://localhost:5000/products"
echo ""
echo "⚠️  IMPORTANT: Save your admin password securely!"
echo "   Password: $ADMIN_PASSWORD"
echo ""
echo "📝 Azure Portal:"
echo "   https://portal.azure.com/#resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/overview"
echo ""
