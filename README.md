# 📦 **Inventory Management System – Flask + Azure SQL**

A modern, full-featured inventory management web application built with Python Flask and Azure SQL Database. Features a beautiful UI with product management, database viewing, and RESTful API endpoints.

---

## ✨ **Features**

- 🎨 Modern, responsive web UI
- 📊 Product dashboard with statistics
- 🗄️ Detailed database table view
- ➕ Add, edit, and delete products
- 🔒 Secure Azure SQL Database integration
- 🚀 RESTful API endpoints
- 📱 Mobile-friendly design

---

## 🚀 **Quick Start**

The application uses environment variables for secure configuration:

```python
import os
from dotenv import load_dotenv

load_dotenv()  # Load from .env file

DB_SERVER = os.getenv("DB_SERVER")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
```

**Security Note:** Never commit `.env` file to version control. It's included in `.gitignore`.
### **2️⃣ Create Virtual Environment**

```bash
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

### **3️⃣ Install Python Dependencies**

```bash
pip install -r requirements.txt
```

### **4️⃣ Install ODBC Driver** {#install-odbc-driver}

**macOS:**
```bash
brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
brew update
HOMEBREW_ACCEPT_EULA=Y brew install msodbcsql18 mssql-tools18
```

**Linux (Ubuntu/Debian):**
```bash
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18
```

*# 🗄️ **Database Schema**

```sql
CREATE TABLE products (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE()
);
```

---

## 🛠️ **Development**

### **Project Dependencies**

```txt
Flask              # Web framework
pyodbc             # SQL Server database driver
python-dotenv      # Environment variable management
```

### **Running in Debug Mode**

The application runs in debug mode by default when started with `python app.py`. This enables:
- Auto-reload on code changes
- Detailed error messages
- Interactive debugger

### **Database Utilities**

**Initialize/Reset Database:**
```bash
python init_database.py
```

This will create the products table and insert sample data.

---

## 🚀 **Deployment**

### **Deploy to Azure App Service**

1. **Login to Azure:**
```bash
az login
```

2. **Create App Service:**
```bash
az webapp up --name your-app-name --resource-group rg-inventory-app --runtime "PYTHON:3.11"
```

3. **Configure Environment Variables:**
```bash
az webapp config appsettings set --name your-app-name --resource-group rg-inventory-app --settings \
    DB_SERVER=your-server.database.windows.net \
    DB_NAME=your-database \
    DB_USER=your-user \
    DB_PASSWORD=your-password
```

---

## 🔧 **Troubleshooting**

### **ODBC Driver Not Found**

If you see: `Can't open lib 'ODBC Driver 18 for SQL Server'`

**Solution:** Install ODBC Driver 18 for SQL Server (see installation section above)

### **Firewall Rules**

If you can't connect to Azure SQL:

```bash
# Add your IP to firewall
az sql server firewall-rule create \
    --resource-group rg-inventory-app \
    --server your-server-name \
    --name AllowMyIP \
    --start-ip-address YOUR_IP \
    --end-ip-address YOUR_IP
```

### **Port Already in Use**

If port 5000 is busy:

```bash
# Find and kill the process
lsof -ti:5000 | xargs kill -9

# Or run on different port
export FLASK_RUN_PORT=8000
python app.py
```

---

## 📝 **Environment Variables**

| Variable | Description | Example |
|----------|-------------|---------|
| `DB_SERVER` | Azure SQL Server FQDN | `sqlsrv-inventory-xxx.database.windows.net` |
| `DB_NAME` | Database name | `sqldb-inventory` |
| `DB_USER` | Admin username | `adminuser` |
| `DB_PASSWORD` | Admin password | `YourSecurePassword123!` |

---

## 🧪 **Testing**

### **Test Database Connection**

```bash
python init_database.py
```

### **Test API Endpoints**

```bash
# Test health endpoint
curl http://localhost:5000/

# Test products API
curl http://localhost:5000/api/products

# Add a product (via form or API)
# Delete a product
curl -X DELETE http://localhost:5000/api/products/1
```

---

## 📚 **Additional Resources**

- [Azure SQL Database Documentation](https://docs.microsoft.com/azure/azure-sql/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [pyodbc Documentation](https://github.com/mkleehammer/pyodbc/wiki)
- [ODBC Driver for SQL Server](https://docs.microsoft.com/sql/connect/odbc/)

---

## 🤝 **Contributing**

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 **License**

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍💻 **Author**

Built with ❤️ using Flask and Azure SQL Database

---

## 🆘 **Support**

If you encounter any issues or have questions:
1. Check the Troubleshooting section above
2. Review Azure SQL firewall rules
3. Verify ODBC driver installation
4. Check environment variables in `.env` file

---

**Happy Coding! 🚀**oduct:** http://localhost:5000/add

---

## 🌐 **API Endpoints**

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Products dashboard (Web UI) |
| GET | `/database` | Database table view (Web UI) |
| GET | `/add` | Add product form (Web UI) |
| GET | `/edit/:id` | Edit product form (Web UI) |
| GET | `/api/products` | Get all products (JSON) |
| DELETE | `/api/products/:id` | Delete a product |

**Example API Usage:**

```bash
# Get all products
curl http://localhost:5000/api/products

# Delete a product
curl -X DELETE http://localhost:5000/api/products/1
```

---

## 🎨 **Screenshots**

### Products Dashboard
Modern card-based interface with statistics showing total products, total value, and average price.

### Database View
Detailed table listing with all product information including timestamps and inline edit/delete actions.

---

## 🔐 **Configuration**

### **config.py

```
flask-azure-sql-inventory-app/
├── app.py                      # Flask application with routes
├── config.py                   # Database configuration
├── init_database.py            # Database initialization script
├── setup-azure-sql.sh          # Azure SQL setup automation
├── requirements.txt            # Python dependencies
├── .env                        # Environment variables (not in git)
├── templates/                  # HTML templates
│   ├── base.html
│   ├── index.html
│   ├── database.html
│   ├── add.html
│   └── edit.html
├── static/                     # CSS and static files
│   └── style.css
└── README.md
```

---

# 🔐 **config.py (Use Environment Variables – Secure)**

```python
import os

DB_SERVER = os.getenv("DB_SERVER", "sqlsrv-demo.database.windows.net")
DB_NAME = os.getenv("DB_NAME", "sqldb-demo")
DB_USER = os.getenv("DB_USER", "adminuser")
DB_PASSWORD = os.getenv("DB_PASSWORD", "Password123!")

CONN_STR = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={DB_SERVER};"
    f"DATABASE={DB_NAME};"
    f"UID={DB_USER};"
    f"PWD={DB_PASSWORD};"
    "Encrypt=yes;"
    "TrustServerCertificate=no;"
    "Connection Timeout=30;"
)
```

---

# 🐍 **app.py (Improved Flask Application)**

```python
from flask import Flask, jsonify
import pyodbc
from config import CONN_STR

app = Flask(__name__)

def get_db_connection():
    return pyodbc.connect(CONN_STR)

@app.route('/products', methods=['GET'])
def get_products():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, name, price FROM products;")
    data = cursor.fetchall()
    conn.close()

    output = [
        {"id": row[0], "name": row[1], "price": float(row[2])}
        for row in data
    ]
    return jsonify(output)

@app.route('/', methods=['GET'])
def home():
    return jsonify({"message": "Inventory API is running"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

---

# 📦 **requirements.txt**

```
Flask
pyodbc
python-dotenv
```

---

# ▶️ **Run Locally**

### **1️⃣ Install dependencies**

```
pip install -r requirements.txt
```

### **2️⃣ Set environment variables (recommended)**

Mac/Linux:

```
export DB_SERVER=sqlsrv-demo.database.windows.net
export DB_NAME=sqldb-demo
export DB_USER=adminuser
export DB_PASSWORD=Password123!
```

Windows CMD:

```
set DB_SERVER=sqlsrv-demo.database.windows.net
set DB_NAME=sqldb-demo
set DB_USER=adminuser
set DB_PASSWORD=Password123!
```

### **3️⃣ Run the Flask app**

```
python app.py
```

---

# 🌐 **Test API**

### **Get product list**

```
http://localhost:5000/products
```

Response example:

```json
[
  {
    "id": 1,
    "name": "Laptop",
    "price": 45000.0
  }
]
```

---

# 🗄️ **Sample Azure SQL Table**

Run inside Azure SQL Query Editor / SSMS:

```sql
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2)
);

INSERT INTO products VALUES
(1, 'Laptop', 45000),
(2, 'Mouse', 500),
(3, 'Keyboard', 1200);
```

---
