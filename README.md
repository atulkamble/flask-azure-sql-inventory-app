# ✅ **Inventory Management App – Flask + Azure SQL**

A simple Python Flask API that retrieves product inventory from **Azure SQL Database** using **pyodbc**.

---

# 📁 **Project Structure**

```
inventory-app/
├── app.py
├── config.py
├── requirements.txt
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
