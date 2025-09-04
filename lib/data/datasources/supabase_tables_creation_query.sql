-- Create ENUM types first (before tables that use them)
CREATE TYPE movement_type AS ENUM (
    'purchase',
    'sale',
    'adjustment',
    'salereturn',
    'purchasereturn',
    'initialquantity'
);

CREATE TYPE order_item_status AS ENUM (
    'pending',
    'shipped',
    'delivered',
    'returned',
    'cancelled',
    'partiallydelivered'
);

CREATE TYPE order_status AS ENUM (
    'new',
    'processed',
    'partiallydelivered',
    'delivered',
    'cancelled',
    'returned'
);

CREATE TYPE user_role AS ENUM (
    'admin',
    'storekeeper',
    'systemadmin'
);

CREATE TYPE payment_method AS ENUM (
    'cash',
    'banktransfer',
    'creditterms',
    'deposit'
);

-- Categories table with sub-categories using hierarchical model
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    parent_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
    CHECK (id != parent_id)
);

-- Index for performance
CREATE INDEX idx_categories_parent_id ON categories(parent_id);

-- Suppliers table
CREATE TABLE suppliers(
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    address TEXT,
    phone_number VARCHAR(20)
);

-- Products table
CREATE TABLE products(
    id SERIAL PRIMARY KEY, 
    name VARCHAR(100) NOT NULL, 
    description TEXT,
    brand VARCHAR(50),
    category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL
);

-- Product items table
CREATE TABLE product_items(
    id SERIAL PRIMARY KEY,
    specification VARCHAR(255) NOT NULL,
    sku VARCHAR(50) UNIQUE,
    barcode VARCHAR(50) UNIQUE,
    unit_of_measure VARCHAR(50) NOT NULL,
    color VARCHAR(50),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    product_id INTEGER REFERENCES products(id),
    supplier_id INTEGER REFERENCES suppliers(id),
    minimum_stock INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Inventory table
CREATE TABLE inventory(
    product_item_id INTEGER PRIMARY KEY REFERENCES product_items(id) ON DELETE CASCADE,
    stock INTEGER NOT NULL CHECK (stock >= 0),
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Transaction table
CREATE TABLE transaction (
    id SERIAL PRIMARY KEY,
    transaction_type movement_type NOT NULL,
    date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Stock movement table
CREATE TABLE stock_movement (
    id SERIAL PRIMARY KEY,
    transaction_id INTEGER NOT NULL REFERENCES transaction(id) ON DELETE CASCADE,
    product_item_id INTEGER NOT NULL REFERENCES product_items(id) ON DELETE CASCADE,
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    quantity INTEGER NOT NULL,
    note TEXT
);

-- Customers table
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT
);

-- Customer delivery addresses table
CREATE TABLE customer_delivery_addresses (
    id SERIAL PRIMARY KEY,
    address_code VARCHAR(20),
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    delivery_address TEXT
);

-- Customer contacts table
CREATE TABLE customer_contacts (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    position TEXT NOT NULL,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE
);

-- Contact phones table
CREATE TABLE contact_phones (
    contact_id INTEGER NOT NULL REFERENCES customer_contacts(id) ON DELETE CASCADE,
    phone_number TEXT NOT NULL,
    PRIMARY KEY (contact_id, phone_number)
);

-- Users table
CREATE TABLE users(
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    role user_role DEFAULT 'storekeeper'
);

-- Sales order table
CREATE TABLE sales_order (
    id SERIAL PRIMARY KEY,
    transaction_id INTEGER NOT NULL REFERENCES transaction(id) ON DELETE CASCADE,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    order_date TIMESTAMPTZ NOT NULL,
    status order_status NOT NULL DEFAULT 'new',
    total_amount NUMERIC(18, 2) NOT NULL,
    payment_method payment_method NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    po_number TEXT,
    po_date TIMESTAMPTZ NOT NULL
);

-- Sales order items table
CREATE TABLE sales_order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES sales_order(id) ON DELETE CASCADE,
    product_item_id INTEGER NOT NULL REFERENCES product_items(id) ON DELETE CASCADE,
    quantity_ordered INTEGER NOT NULL,
    quantity_delivered INTEGER NOT NULL DEFAULT 0,
    default_unit_price NUMERIC(18, 2) NOT NULL,
    adjusted_unit_price NUMERIC(18, 2) NOT NULL,
    status order_item_status DEFAULT 'pending',
    added_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ
);

-- Purchase table
CREATE TABLE purchase (
    id SERIAL PRIMARY KEY,
    transaction_id INTEGER NOT NULL REFERENCES transaction(id) ON DELETE CASCADE,
    po_number VARCHAR(50),
    supplier_id INTEGER REFERENCES suppliers(id) ON DELETE CASCADE,
    purchase_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    total_amount NUMERIC(18, 2) NOT NULL,
    payment_method payment_method NOT NULL
);

-- Purchase items table
CREATE TABLE purchase_items (
    id SERIAL PRIMARY KEY,
    purchase_id INTEGER NOT NULL REFERENCES purchase(id) ON DELETE CASCADE,
    product_item_id INTEGER NOT NULL REFERENCES product_items(id) ON DELETE CASCADE,
    quantity_ordered INTEGER NOT NULL,
    unit_cost NUMERIC(18, 2) NOT NULL
);

-- Sales item return table
CREATE TABLE sales_item_return (
    id SERIAL PRIMARY KEY,
    origin_sales_id INTEGER NOT NULL REFERENCES sales_order(id) ON DELETE CASCADE,
    order_item_id INTEGER NOT NULL REFERENCES sales_order_items(id) ON DELETE CASCADE,
    transaction_id INTEGER NOT NULL REFERENCES transaction(id) ON DELETE CASCADE,
    product_item_id INTEGER NOT NULL REFERENCES product_items(id) ON DELETE CASCADE,
    quantity_returned INTEGER NOT NULL,
    return_date TIMESTAMPTZ NOT NULL,
    reason TEXT NOT NULL
);

-- Purchase item return table
CREATE TABLE purchase_item_return (
    id SERIAL PRIMARY KEY,
    origin_purchase_id INTEGER NOT NULL REFERENCES purchase(id) ON DELETE CASCADE,
    purchase_item_id INTEGER NOT NULL REFERENCES purchase_items(id) ON DELETE CASCADE,
    transaction_id INTEGER NOT NULL REFERENCES transaction(id) ON DELETE CASCADE,
    product_item_id INTEGER NOT NULL REFERENCES product_items(id) ON DELETE CASCADE,
    quantity_returned INTEGER NOT NULL,
    return_date TIMESTAMPTZ NOT NULL,
    reason TEXT NOT NULL
);

-- Order delivery table
CREATE TABLE order_delivery (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES sales_order(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Order delivery items table
CREATE TABLE order_delivery_items (
    id SERIAL PRIMARY KEY,
    order_delivery_id INTEGER NOT NULL REFERENCES order_delivery(id) ON DELETE CASCADE,
    order_item_id INTEGER NOT NULL REFERENCES sales_order_items(id) ON DELETE CASCADE,
    quantity_shipped INTEGER NOT NULL CHECK (quantity_shipped >= 0),
    received_date TIMESTAMPTZ
);

-- Seed categories data
INSERT INTO categories(name)
VALUES
('Tools'),
('Fasteners'),
('Plumbing'),
('Electrical'),
('Paint & Finishes'),
('Lumber & Wood'),
('Building & Construction Materials'),
('Hardware'),
('Gardening'),
('Safety Equipment'),
('Cleaning Supplies'),
('Automotive'),
('Lighting'),
('Storage & Shelving'),
('Office Supplies'),
('Household & General Tools'),
('Plastic Sheet & Rolls');

-- Seed sub-categories
INSERT INTO categories(name, parent_id)
VALUES
('Hand Tools', 1),
('Power Tools', 1),
('Cutting Tools', 1),
('Measuring Tools', 1),
('Nails', 2),
('Screws', 2),
('Bolts & Nuts', 2),
('Anchors', 2),
('Pipes', 3),
('Fittings', 3),
('Faucets', 3),
('Valves', 3),
('Wires', 4),
('Switches', 4),
('Outlets', 4),
('Lightbulbs', 4),
('Breakers', 4),
('Paints', 5),
('Primers', 5),
('Thinners', 5),
('Brushes & Rollers', 5),
('Plywood', 6),
('MDF', 6),
('Boards', 6),
('Cement', 7),
('Sand', 7),
('Gravel', 7),
('Bricks', 7),
('Adhesive', 7),
('Hinges', 8),
('Locks', 8),
('Handles', 8),
('Doors', 8),
('Accessories', 8),
('Soil', 9),
('Fertilizers', 9),
('Hoses', 9),
('Gardening Tools', 9),
('Gloves', 10),
('Helmets', 10),
('Goggles', 10),
('Ear Protection', 10),
('Mops', 11),
('Buckets', 11),
('Brooms', 11),
('Detergents', 11),
('Car Tools', 12),
('Oils', 12),
('Batteries', 12),
('Bins', 14),
('Cabinets', 14),
('Racks', 14),
('Hooks', 14);

-- Insert sample supplier
INSERT INTO suppliers(name) VALUES('Unnamed');

-- Insert sample product
INSERT INTO products(category_id, name, brand)
VALUES (16, 'Kunci Ring Pas', 'Tekiro');

-- Insert sample product items
INSERT INTO product_items(specification, unit_of_measure, unit_price, product_id)
VALUES 
    ('12mm', 'pc', 15000, 1), 
    ('14mm', 'pc', 17500, 1),
    ('16mm', 'pc', 19500, 1);