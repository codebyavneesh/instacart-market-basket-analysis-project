CREATE DATABASE instacart_db;
USE instacart_db;

DROP TABLE departments;
DROP TABLE aisles;
DROP TABLE products;
DROP TABLE orders;
DROP TABLE order_products_prior;
DROP TABLE order_products_train;
-- ===========================================
-- Departments
-- ===========================================
CREATE TABLE departments (
    department_id TINYINT PRIMARY KEY,
    department VARCHAR(100) NOT NULL
);

-- ===========================================
-- Aisles
-- ===========================================
CREATE TABLE aisles (
    aisle_id SMALLINT PRIMARY KEY,
    aisle VARCHAR(100) NOT NULL
);

-- ===========================================
-- Products
-- ===========================================
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    aisle_id SMALLINT NOT NULL,
    department_id TINYINT NOT NULL,

    CONSTRAINT fk_products_aisle
        FOREIGN KEY (aisle_id)
        REFERENCES aisles(aisle_id),

    CONSTRAINT fk_products_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);

-- ===========================================
-- Orders
-- ===========================================
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    eval_set ENUM('prior','train','test') NOT NULL,
    order_number SMALLINT NOT NULL,
    order_dow TINYINT NOT NULL,
    order_hour_of_day TINYINT NOT NULL,
    days_since_prior_order TINYINT NULL
);

-- ===========================================
-- Order Products Prior
-- ===========================================
drop table order_products_prior;
CREATE TABLE order_products_prior (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    add_to_cart_order SMALLINT NOT NULL,
    reordered TINYINT NOT NULL,

    PRIMARY KEY (order_id, product_id),

    CONSTRAINT fk_prior_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_prior_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- ===========================================
-- Order Products Train
-- ===========================================
CREATE TABLE order_products_train (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    add_to_cart_order SMALLINT NOT NULL,
    reordered TINYINT NOT NULL,

    PRIMARY KEY (order_id, product_id),

    CONSTRAINT fk_train_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_train_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- ===========================================
-- Indexes
-- ===========================================

CREATE INDEX idx_orders_user
ON orders(user_id);

CREATE INDEX idx_products_department
ON products(department_id);

CREATE INDEX idx_products_aisle
ON products(aisle_id);

CREATE INDEX idx_prior_product
ON order_products_prior(product_id);

CREATE INDEX idx_train_product
ON order_products_train(product_id);

SET FOREIGN_KEY_CHECKS = 0;
SELECT VERSION();
SHOW CREATE TABLE order_products_prior;
SHOW CREATE TABLE order_products_train;
SHOW INDEX FROM order_products_prior;
SHOW INDEX FROM order_products_train;

