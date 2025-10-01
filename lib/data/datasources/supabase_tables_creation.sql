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

create table public.transactions (
  id serial not null,
  transaction_type public.movement_type not null,
  date timestamp with time zone not null default CURRENT_TIMESTAMP,
  created_by uuid null,
  constraint transaction_pkey primary key (id),
  constraint transactions_created_by_fkey foreign KEY (created_by) references users (id)
) TABLESPACE pg_default;

create table public.users (
  id uuid not null,
  name text null,
  role public.user_role null default 'guest'::user_role,
  email text null,
  constraint users_pkey primary key (id),
  constraint users_id_fkey foreign KEY (id) references auth.users (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.categories (
  id serial not null,
  name character varying(50) not null,
  parent_id integer null,
  constraint categories_pkey primary key (id),
  constraint categories_name_key unique (name),
  constraint categories_parent_id_fkey foreign KEY (parent_id) references categories (id) on delete set null,
  constraint categories_check check ((id <> parent_id))
) TABLESPACE pg_default;

create table public.customers (
  id serial not null,
  name text not null,
  address text null,
  constraint customers_pkey primary key (id)
) TABLESPACE pg_default;

create index IF not exists idx_categories_parent_id on public.categories using btree (parent_id) TABLESPACE pg_default;

create table public.customer_contacts (
  id serial not null,
  name text not null,
  position text not null,
  customer_id integer not null,
  constraint customer_contacts_pkey primary key (id),
  constraint customer_contacts_customer_id_fkey foreign KEY (customer_id) references customers (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.contact_phones (
  contact_id integer not null,
  phone_number text not null,
  constraint contact_phones_pkey primary key (contact_id, phone_number),
  constraint contact_phones_contact_id_fkey foreign KEY (contact_id) references customer_contacts (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.customer_delivery_addresses (
  id serial not null,
  address_code character varying(20) null,
  customer_id integer not null,
  delivery_address text null,
  constraint customer_delivery_addresses_pkey primary key (id),
  constraint customer_delivery_addresses_customer_id_fkey foreign KEY (customer_id) references customers (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.suppliers (
  id serial not null,
  name character varying(100) null,
  address text null,
  phone_number character varying(20) null,
  constraint suppliers_pkey primary key (id)
) TABLESPACE pg_default;

create table public.products (
  id serial not null,
  name character varying(100) not null,
  description text null,
  brand character varying(50) null,
  category_id integer null,
  image_url text null,
  constraint products_pkey primary key (id),
  constraint unique_name_brand unique (name, brand),
  constraint products_category_id_fkey foreign KEY (category_id) references categories (id) on delete set null
) TABLESPACE pg_default;

create table public.product_items (
  id serial not null,
  specification character varying(255) not null,
  sku character varying(50) null,
  barcode character varying(50) null,
  unit_of_measure character varying(50) not null,
  color character varying(50) null,
  unit_price numeric(10, 2) not null,
  product_id integer null,
  supplier_id integer null,
  minimum_stock integer null default 0,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  updated_at timestamp with time zone null default CURRENT_TIMESTAMP,
  constraint product_items_pkey primary key (id),
  constraint product_items_sku_key unique (sku),
  constraint product_items_barcode_key unique (barcode),
  constraint unique_product_spec_color unique (product_id, specification, color),
  constraint product_items_supplier_id_fkey foreign KEY (supplier_id) references suppliers (id),
  constraint product_items_product_id_fkey foreign KEY (product_id) references products (id),
  constraint product_items_unit_price_check check ((unit_price >= (0)::numeric))
) TABLESPACE pg_default;

create table public.inventory (
  product_item_id integer not null,
  stock numeric(18, 4) not null,
  updated_at timestamp with time zone null default CURRENT_TIMESTAMP,
  constraint inventory_pkey primary key (product_item_id),
  constraint inventory_product_item_id_fkey foreign KEY (product_item_id) references product_items (id) on delete CASCADE,
  constraint inventory_stock_check check ((stock >= (0)::numeric))
) TABLESPACE pg_default;

create table public.purchase (
  id serial not null,
  transaction_id integer not null,
  po_number character varying(50) null,
  supplier_id integer null,
  purchase_date timestamp with time zone not null default CURRENT_TIMESTAMP,
  total_amount numeric(18, 2) not null,
  payment_method public.payment_method not null,
  constraint purchase_pkey primary key (id),
  constraint purchase_supplier_id_fkey foreign KEY (supplier_id) references suppliers (id) on delete CASCADE,
  constraint purchase_transaction_id_fkey foreign KEY (transaction_id) references transactions (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.purchase_items (
  id serial not null,
  purchase_id integer not null,
  product_item_id integer not null,
  quantity_ordered numeric(18, 4) not null,
  unit_cost numeric(18, 2) not null,
  constraint purchase_items_pkey primary key (id),
  constraint purchase_items_product_item_id_fkey foreign KEY (product_item_id) references product_items (id) on delete CASCADE,
  constraint purchase_items_purchase_id_fkey foreign KEY (purchase_id) references purchase (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.purchase_item_return (
  id serial not null,
  origin_purchase_id integer not null,
  purchase_item_id integer not null,
  transaction_id integer not null,
  product_item_id integer not null,
  quantity_returned numeric(18, 4) not null,
  return_date timestamp with time zone not null,
  reason text not null,
  created_by uuid null,
  constraint purchase_item_return_pkey primary key (id),
  constraint purchase_item_return_created_by_fkey foreign KEY (created_by) references users (id),
  constraint purchase_item_return_origin_purchase_id_fkey foreign KEY (origin_purchase_id) references purchase (id) on delete CASCADE,
  constraint purchase_item_return_product_item_id_fkey foreign KEY (product_item_id) references product_items (id) on delete CASCADE,
  constraint purchase_item_return_purchase_item_id_fkey foreign KEY (purchase_item_id) references purchase_items (id) on delete CASCADE,
  constraint purchase_item_return_transaction_id_fkey foreign KEY (transaction_id) references transactions (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.sales_order (
  id serial not null,
  transaction_id integer not null,
  customer_id integer not null,
  order_date timestamp with time zone not null,
  status public.order_status not null default 'new'::order_status,
  total_amount numeric(18, 2) not null,
  payment_method public.payment_method not null,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  updated_at timestamp with time zone null,
  po_number text null,
  po_date timestamp with time zone not null,
  constraint sales_order_pkey primary key (id),
  constraint sales_order_customer_id_fkey foreign KEY (customer_id) references customers (id) on delete CASCADE,
  constraint sales_order_transaction_id_fkey foreign KEY (transaction_id) references transactions (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.sales_order_items (
  id serial not null,
  order_id integer not null,
  product_item_id integer not null,
  quantity_ordered numeric(18, 4) not null,
  quantity_delivered numeric(18, 4) not null default 0,
  default_unit_price numeric(18, 2) not null,
  adjusted_unit_price numeric(18, 2) not null,
  status public.order_item_status null default 'pending'::order_item_status,
  added_at timestamp with time zone not null default CURRENT_TIMESTAMP,
  updated_at timestamp with time zone null,
  constraint sales_order_items_pkey primary key (id),
  constraint sales_order_items_order_id_fkey foreign KEY (order_id) references sales_order (id) on delete CASCADE,
  constraint sales_order_items_product_item_id_fkey foreign KEY (product_item_id) references product_items (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.sales_item_return (
  id serial not null,
  origin_sales_id integer not null,
  order_item_id integer not null,
  transaction_id integer not null,
  product_item_id integer not null,
  quantity_returned numeric(18, 4) not null,
  return_date timestamp with time zone not null,
  reason text not null,
  created_by uuid null,
  constraint sales_item_return_pkey primary key (id),
  constraint sales_item_return_created_by_fkey foreign KEY (created_by) references users (id),
  constraint sales_item_return_order_item_id_fkey foreign KEY (order_item_id) references sales_order_items (id) on delete CASCADE,
  constraint sales_item_return_origin_sales_id_fkey foreign KEY (origin_sales_id) references sales_order (id) on delete CASCADE,
  constraint sales_item_return_product_item_id_fkey foreign KEY (product_item_id) references product_items (id) on delete CASCADE,
  constraint sales_item_return_transaction_id_fkey foreign KEY (transaction_id) references transactions (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.order_delivery (
  id serial not null,
  order_id integer not null,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  constraint order_delivery_pkey primary key (id),
  constraint order_delivery_order_id_fkey foreign KEY (order_id) references sales_order (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.order_delivery_items (
  id serial not null,
  order_delivery_id integer not null,
  order_item_id integer not null,
  quantity_shipped numeric(18, 4) not null,
  received_date timestamp with time zone null,
  created_by uuid null,
  constraint order_delivery_items_pkey primary key (id),
  constraint order_delivery_items_created_by_fkey foreign KEY (created_by) references users (id),
  constraint order_delivery_items_order_delivery_id_fkey foreign KEY (order_delivery_id) references order_delivery (id) on delete CASCADE,
  constraint order_delivery_items_order_item_id_fkey foreign KEY (order_item_id) references sales_order_items (id) on delete CASCADE,
  constraint order_delivery_items_quantity_shipped_check check ((quantity_shipped >= (0)::numeric))
) TABLESPACE pg_default;

create table public.invoices (
  id serial not null,
  invoice_number character varying(50) not null,
  sales_order_id integer not null,
  customer_id integer not null,
  invoice_date date not null default CURRENT_DATE,
  due_date date not null,
  subtotal numeric(18, 2) not null,
  tax_amount numeric(18, 2) null default 0,
  discount_amount numeric(18, 2) null default 0,
  total_amount numeric(18, 2) not null,
  status public.invoice_status null default 'draft'::invoice_status,
  notes text null,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  updated_at timestamp with time zone null default CURRENT_TIMESTAMP,
  created_by uuid null,
  constraint invoices_pkey primary key (id),
  constraint invoices_invoice_number_key unique (invoice_number),
  constraint invoices_sales_order_id_fkey foreign KEY (sales_order_id) references sales_order (id) on delete CASCADE,
  constraint invoices_customer_id_fkey foreign KEY (customer_id) references customers (id) on delete CASCADE,
  constraint invoices_created_by_fkey foreign KEY (created_by) references users (id),
  constraint check_due_date check ((due_date >= invoice_date)),
  constraint invoices_total_amount_check check ((total_amount >= (0)::numeric)),
  constraint check_total_calculation check (
    (
      total_amount = ((subtotal + tax_amount) - discount_amount)
    )
  ),
  constraint invoices_discount_amount_check check ((discount_amount >= (0)::numeric)),
  constraint invoices_subtotal_check check ((subtotal >= (0)::numeric)),
  constraint invoices_tax_amount_check check ((tax_amount >= (0)::numeric))
) TABLESPACE pg_default;

create index IF not exists idx_invoices_sales_order_id on public.invoices using btree (sales_order_id) TABLESPACE pg_default;

create index IF not exists idx_invoices_customer_id on public.invoices using btree (customer_id) TABLESPACE pg_default;

create index IF not exists idx_invoices_status on public.invoices using btree (status) TABLESPACE pg_default;

create index IF not exists idx_invoices_due_date on public.invoices using btree (due_date) TABLESPACE pg_default;

create index IF not exists idx_invoices_invoice_date on public.invoices using btree (invoice_date) TABLESPACE pg_default;

create trigger update_invoices_updated_at BEFORE
update on invoices for EACH row
execute FUNCTION update_updated_at_column ();

create table public.invoice_items (
  id serial not null,
  invoice_id integer not null,
  sales_order_item_id integer not null,
  product_item_id integer not null,
  quantity numeric(18, 4) not null,
  unit_price numeric(18, 2) not null,
  line_total numeric(18, 2) not null,
  constraint invoice_items_pkey primary key (id),
  constraint invoice_items_product_item_id_fkey foreign KEY (product_item_id) references product_items (id) on delete CASCADE,
  constraint invoice_items_invoice_id_fkey foreign KEY (invoice_id) references invoices (id) on delete CASCADE,
  constraint invoice_items_sales_order_item_id_fkey foreign KEY (sales_order_item_id) references sales_order_items (id) on delete CASCADE,
  constraint invoice_items_unit_price_check check ((unit_price >= (0)::numeric)),
  constraint invoice_items_line_total_check check ((line_total >= (0)::numeric)),
  constraint invoice_items_quantity_check check ((quantity > (0)::numeric)),
  constraint check_line_total check ((line_total = ((quantity)::numeric * unit_price)))
) TABLESPACE pg_default;

create index IF not exists idx_invoice_items_invoice_id on public.invoice_items using btree (invoice_id) TABLESPACE pg_default;

create index IF not exists idx_invoice_items_product_item_id on public.invoice_items using btree (product_item_id) TABLESPACE pg_default;

create table public.payments (
  id serial not null,
  payment_number character varying(50) not null,
  invoice_id integer not null,
  payment_date date not null default CURRENT_DATE,
  amount numeric(18, 2) not null,
  payment_method public.payment_method not null,
  bank_reference character varying(100) null,
  bank_account character varying(100) null,
  transfer_note text null,
  status public.payment_status null default 'completed'::payment_status,
  notes text null,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  updated_at timestamp with time zone null default CURRENT_TIMESTAMP,
  created_by uuid null,
  constraint payments_pkey primary key (id),
  constraint payments_payment_number_key unique (payment_number),
  constraint payments_created_by_fkey foreign KEY (created_by) references users (id),
  constraint payments_invoice_id_fkey foreign KEY (invoice_id) references invoices (id) on delete CASCADE,
  constraint payments_amount_check check ((amount > (0)::numeric))
) TABLESPACE pg_default;

create index IF not exists idx_payments_invoice_id on public.payments using btree (invoice_id) TABLESPACE pg_default;

create index IF not exists idx_payments_payment_date on public.payments using btree (payment_date) TABLESPACE pg_default;

create index IF not exists idx_payments_status on public.payments using btree (status) TABLESPACE pg_default;

create trigger update_payments_updated_at BEFORE
update on payments for EACH row
execute FUNCTION update_updated_at_column ();

create table public.stock_movement (
  id serial not null,
  transaction_id integer not null,
  product_item_id integer not null,
  timestamp timestamp with time zone not null default CURRENT_TIMESTAMP,
  quantity numeric(18, 4) not null,
  note text null,
  created_by uuid null,
  constraint stock_movement_pkey primary key (id),
  constraint stock_movement_created_by_fkey foreign KEY (created_by) references users (id),
  constraint stock_movement_product_item_id_fkey foreign KEY (product_item_id) references product_items (id) on delete CASCADE,
  constraint stock_movement_transaction_id_fkey foreign KEY (transaction_id) references transactions (id) on delete CASCADE
) TABLESPACE pg_default;


