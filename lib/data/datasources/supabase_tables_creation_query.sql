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
ALTER TABLE products ADD COLUMN image_url TEXT;

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
CREATE TABLE transactions (
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

-- Add invoice status enum
CREATE TYPE invoice_status AS ENUM (
    'draft',
    'sent',
    'overdue', 
    'paid',
    'cancelled'
);

-- Add payment status enum  
CREATE TYPE payment_status AS ENUM (
    'pending',
    'completed',
    'failed',
    'cancelled'
);

-- Invoice table
CREATE TABLE invoices (
    id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    sales_order_id INTEGER NOT NULL REFERENCES sales_order(id) ON DELETE CASCADE,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    
    -- Invoice details
    invoice_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    
    -- Financial information
    subtotal NUMERIC(18, 2) NOT NULL CHECK (subtotal >= 0),
    tax_amount NUMERIC(18, 2) DEFAULT 0 CHECK (tax_amount >= 0),
    discount_amount NUMERIC(18, 2) DEFAULT 0 CHECK (discount_amount >= 0),
    total_amount NUMERIC(18, 2) NOT NULL CHECK (total_amount >= 0),
    
    -- Status and tracking
    status invoice_status DEFAULT 'draft',
    notes TEXT,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id),
    
    -- Constraints
    CONSTRAINT check_due_date CHECK (due_date >= invoice_date),
    CONSTRAINT check_total_calculation CHECK (total_amount = subtotal + tax_amount - discount_amount)
);

-- Invoice items table (for detailed line items)
CREATE TABLE invoice_items (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    sales_order_item_id INTEGER NOT NULL REFERENCES sales_order_items(id) ON DELETE CASCADE,
    product_item_id INTEGER NOT NULL REFERENCES product_items(id) ON DELETE CASCADE,
    
    -- Item details
    description TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(18, 2) NOT NULL CHECK (unit_price >= 0),
    line_total NUMERIC(18, 2) NOT NULL CHECK (line_total >= 0),
    
    -- Constraints
    CONSTRAINT check_line_total CHECK (line_total = quantity * unit_price)
);

-- Payments table
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    payment_number VARCHAR(50) UNIQUE NOT NULL,
    invoice_id INTEGER NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    
    -- Payment details
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    amount NUMERIC(18, 2) NOT NULL CHECK (amount > 0),
    payment_method payment_method NOT NULL,
    
    -- Bank transfer details (optional)
    bank_reference VARCHAR(100), -- Bank transfer reference number
    bank_account VARCHAR(100),   -- Sender's bank account info
    transfer_note TEXT,          -- Additional transfer notes
    
    -- Status and tracking
    status payment_status DEFAULT 'completed',
    notes TEXT,
    
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id)
);

-- Create indexes for better performance
CREATE INDEX idx_invoices_sales_order_id ON invoices(sales_order_id);
CREATE INDEX idx_invoices_customer_id ON invoices(customer_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);
CREATE INDEX idx_invoices_invoice_date ON invoices(invoice_date);

CREATE INDEX idx_invoice_items_invoice_id ON invoice_items(invoice_id);
CREATE INDEX idx_invoice_items_product_item_id ON invoice_items(product_item_id);

CREATE INDEX idx_payments_invoice_id ON payments(invoice_id);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);
CREATE INDEX idx_payments_status ON payments(status);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_invoices_updated_at 
    BEFORE UPDATE ON invoices 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at 
    BEFORE UPDATE ON payments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create the missing RPC functions for dashboard
CREATE OR REPLACE FUNCTION get_due_payments_summary()
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'due_count', COALESCE(COUNT(*), 0),
        'total_due', COALESCE(SUM(total_amount), 0)
    ) INTO result
    FROM invoices 
    WHERE status IN ('sent', 'overdue') 
      AND due_date <= CURRENT_DATE;
      
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Create function for top selling items
CREATE OR REPLACE FUNCTION get_top_selling_items(item_limit INTEGER DEFAULT 5)
RETURNS TABLE (
    product_id INTEGER,
    name TEXT,
    specification TEXT,
    total_sold BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.name::TEXT,
        pi.specification::TEXT,
        SUM(soi.quantity_delivered) as total_sold
    FROM sales_order_items soi
    INNER JOIN product_items pi ON soi.product_item_id = pi.id
    INNER JOIN products p ON pi.product_id = p.id
    INNER JOIN sales_order so ON soi.order_id = so.id
    WHERE so.status = 'delivered'
      AND soi.quantity_delivered > 0
    GROUP BY p.id, p.name, pi.specification
    ORDER BY total_sold DESC
    LIMIT item_limit;
END;
$$ LANGUAGE plpgsql;

-- Function to generate invoice number
CREATE OR REPLACE FUNCTION generate_invoice_number()
RETURNS TEXT AS $$
DECLARE
    current_year TEXT;
    current_month TEXT;
    sequence_num INTEGER;
    invoice_num TEXT;
BEGIN
    current_year := TO_CHAR(CURRENT_DATE, 'YYYY');
    current_month := TO_CHAR(CURRENT_DATE, 'MM');
    
    -- Get next sequence number for current month
    SELECT COALESCE(
        MAX(CAST(SUBSTRING(invoice_number FROM '[0-9]+$') AS INTEGER)), 0
    ) + 1 INTO sequence_num
    FROM invoices 
    WHERE invoice_number LIKE 'INV-' || current_year || current_month || '%';
    
    invoice_num := 'INV-' || current_year || current_month || '-' || LPAD(sequence_num::TEXT, 4, '0');
    
    RETURN invoice_num;
END;
$$ LANGUAGE plpgsql;

-- Function to generate payment number
CREATE OR REPLACE FUNCTION generate_payment_number()
RETURNS TEXT AS $$
DECLARE
    current_year TEXT;
    current_month TEXT;
    sequence_num INTEGER;
    payment_num TEXT;
BEGIN
    current_year := TO_CHAR(CURRENT_DATE, 'YYYY');
    current_month := TO_CHAR(CURRENT_DATE, 'MM');
    
    -- Get next sequence number for current month
    SELECT COALESCE(
        MAX(CAST(SUBSTRING(payment_number FROM '[0-9]+$') AS INTEGER)), 0
    ) + 1 INTO sequence_num
    FROM payments 
    WHERE payment_number LIKE 'PAY-' || current_year || current_month || '%';
    
    payment_num := 'PAY-' || current_year || current_month || '-' || LPAD(sequence_num::TEXT, 4, '0');
    
    RETURN payment_num;
END;
$$ LANGUAGE plpgsql;

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