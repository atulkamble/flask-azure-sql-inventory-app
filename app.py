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
