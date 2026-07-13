import pandas as pd

aisle=pd.read_csv('C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/intercast_marker_basket_analysis_project/data/raw/aisles.csv', encoding='latin1')

departments=pd.read_csv('C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/intercast_marker_basket_analysis_project/data/raw/departments.csv', encoding='latin1')

orders=pd.read_csv('C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/intercast_marker_basket_analysis_project/data/raw/orders.csv', encoding='latin1')

products=pd.read_csv('C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/intercast_marker_basket_analysis_project/data/raw/products.csv', encoding='latin1')

order_products_prior=pd.read_csv('C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/intercast_marker_basket_analysis_project/data/raw/order_products__prior.csv', encoding='latin1')

order_products_train=pd.read_csv('C:/Users/Sistech Computer/OneDrive/Desktop/sandeep/intercast_marker_basket_analysis_project/data/raw/order_products__train.csv', encoding='latin1')


print(len(aisle))
print(len(departments))
print(len(orders))
print(len(products))
print(len(order_products_prior))
print(len(order_products_train))




























