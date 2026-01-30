from flask import Flask, render_template, request, redirect, url_for, jsonify
import pyodbc
from config import CONN_STR

app = Flask(__name__)

def get_db_connection():
    return pyodbc.connect(CONN_STR)

# Web UI Routes
@app.route('/')
def index():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, name, price FROM products;")
    data = cursor.fetchall()
    conn.close()

    products = [
        {"id": row[0], "name": row[1], "price": float(row[2])}
        for row in data
    ]
    
    # Calculate stats
    total_value = sum(p['price'] for p in products)
    avg_price = total_value / len(products) if products else 0
    
    return render_template('index.html', 
                         products=products, 
                         total_value=total_value,
                         avg_price=avg_price)

@app.route('/add', methods=['GET', 'POST'])
def add_product():
    if request.method == 'POST':
        name = request.form['name']
        price = float(request.form['price'])
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("INSERT INTO products (name, price) VALUES (?, ?)", (name, price))
        conn.commit()
        conn.close()
        
        return redirect(url_for('index'))
    
    return render_template('add.html')

@app.route('/database')
def database():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, name, price, created_at FROM products ORDER BY id;")
    data = cursor.fetchall()
    conn.close()

    products = [
        {"id": row[0], "name": row[1], "price": float(row[2]), "created_at": row[3]}
        for row in data
    ]
    
    # Calculate stats
    total_value = sum(p['price'] for p in products)
    avg_price = total_value / len(products) if products else 0
    max_price = max(p['price'] for p in products) if products else 0
    min_price = min(p['price'] for p in products) if products else 0
    
    # Get database name from config
    from config import DB_NAME
    
    return render_template('database.html', 
                         products=products,
                         db_name=DB_NAME,
                         total_value=total_value,
                         avg_price=avg_price,
                         max_price=max_price,
                         min_price=min_price)

@app.route('/edit/<int:product_id>', methods=['GET', 'POST'])
def edit_product(product_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    if request.method == 'POST':
        name = request.form['name']
        price = float(request.form['price'])
        
        cursor.execute("UPDATE products SET name = ?, price = ? WHERE id = ?", 
                      (name, price, product_id))
        conn.commit()
        conn.close()
        
        return redirect(url_for('index'))
    
    cursor.execute("SELECT id, name, price FROM products WHERE id = ?", (product_id,))
    row = cursor.fetchone()
    conn.close()
    
    if row:
        product = {"id": row[0], "name": row[1], "price": float(row[2])}
        return render_template('edit.html', product=product)
    
    return redirect(url_for('index'))

# API Routes
@app.route('/api/products', methods=['GET'])
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

@app.route('/api/products/<int:product_id>', methods=['DELETE'])
def delete_product(product_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM products WHERE id = ?", (product_id,))
    conn.commit()
    conn.close()
    
    return jsonify({"success": True})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
