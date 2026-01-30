#!/usr/bin/env python3
"""Initialize the database with products table and sample data."""

import pyodbc
from config import CONN_STR

def init_database():
    """Create products table and insert sample data."""
    print("Connecting to database...")
    
    try:
        conn = pyodbc.connect(CONN_STR)
        cursor = conn.cursor()
        
        print("Creating products table...")
        
        # Create table if it doesn't exist
        cursor.execute("""
            IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'products')
            BEGIN
                CREATE TABLE products (
                    id INT IDENTITY(1,1) PRIMARY KEY,
                    name NVARCHAR(100) NOT NULL,
                    price DECIMAL(10,2) NOT NULL,
                    created_at DATETIME2 DEFAULT GETDATE()
                );
            END
        """)
        conn.commit()
        print("✓ Products table created")
        
        # Check if table is empty
        cursor.execute("SELECT COUNT(*) FROM products")
        count = cursor.fetchone()[0]
        
        if count == 0:
            print("Inserting sample data...")
            sample_products = [
                ('Laptop', 999.99),
                ('Mouse', 29.99),
                ('Keyboard', 79.99),
                ('Monitor', 299.99),
                ('Headphones', 149.99),
            ]
            
            cursor.executemany(
                "INSERT INTO products (name, price) VALUES (?, ?)",
                sample_products
            )
            conn.commit()
            print(f"✓ Inserted {len(sample_products)} sample products")
        else:
            print(f"Table already has {count} products")
        
        # Display current products
        print("\nCurrent products in database:")
        cursor.execute("SELECT id, name, price FROM products")
        for row in cursor.fetchall():
            print(f"  {row.id}: {row.name} - ${row.price:.2f}")
        
        conn.close()
        print("\n✓ Database initialization complete!")
        
    except Exception as e:
        print(f"✗ Error: {e}")
        return False
    
    return True

if __name__ == "__main__":
    init_database()
