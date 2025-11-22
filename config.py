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
