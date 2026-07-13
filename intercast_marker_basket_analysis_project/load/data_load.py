import pandas as pd
import pymysql
from tqdm import tqdm

# ==========================
# MySQL Connection
# ==========================
conn = pymysql.connect(
    host="localhost",
    user="root",
    password="root",
    database="instacart_db",
    local_infile=True,
    autocommit=False
)

cursor = conn.cursor()

# ==========================
# CSV Folder
# ==========================
path = r"C:\Users\Sistech Computer\OneDrive\Desktop\sandeep\intercast_marker_basket_analysis_project\data\raw"

files = {
    "order_products__prior.csv": "order_products_prior",
    "order_products__train.csv": "order_products_train"
}

# ==========================
# Disable FK Checks
# ==========================
cursor.execute("SET FOREIGN_KEY_CHECKS=0")

# ==========================
# Import
# ==========================
for file_name, table_name in files.items():

    print(f"\nImporting {file_name}...")

    insert_query = f"""
    INSERT INTO {table_name}
    (order_id, product_id, add_to_cart_order, reordered)
    VALUES (%s,%s,%s,%s)
    """

    for chunk in tqdm(pd.read_csv(f"{path}\\{file_name}", chunksize=5000)):

        data = list(chunk.itertuples(index=False, name=None))

        cursor.executemany(insert_query, data)

        conn.commit()

    print(f"{table_name} Imported Successfully.")

# ==========================
# Enable FK Checks
# ==========================
cursor.execute("SET FOREIGN_KEY_CHECKS=1")

cursor.close()
conn.close()

print("\nAll Files Imported Successfully.")