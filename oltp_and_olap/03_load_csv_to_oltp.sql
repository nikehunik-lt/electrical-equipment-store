-- categories
create temp table temp_categories (
    name varchar(100),
    description text
);

copy temp_categories(name, description)
from '/Users/nikitastepanenko/Desktop/project/csv_data/categories.csv'
with (format csv, header true, delimiter ',');

insert into categories (name, description)
select t.name, t.description
from temp_categories t
where not exists (
    select 1 from categories c where c.name = t.name
);

drop table temp_categories;


create temp table temp_brands (
    name varchar(100),
    country varchar(50)
);

copy temp_brands(name, country)
from '/Users/nikitastepanenko/Desktop/project/csv_data/brands.csv'
with (format csv, header true, delimiter ',');

insert into brands (name, country)
select t.name, t.country
from temp_brands t
where not exists (
    select 1 from brands b where b.name = t.name
);

drop table temp_brands;


create temp table temp_suppliers (
    name varchar(150),
    contact_name varchar(100),
    email varchar(100),
    phone varchar(50),
    address text,
    city varchar(50),
    country varchar(100)
);

copy temp_suppliers(name, contact_name, email, phone, address, city, country)
from '/Users/nikitastepanenko/Desktop/project/csv_data/suppliers.csv'
with (format csv, header true, delimiter ',');

insert into suppliers (name, contact_name, email, phone, address, city, country)
select t.name, t.contact_name, t.email, t.phone, t.address, t.city, t.country
from temp_suppliers t
where not exists (
    select 1 from suppliers s where s.email = t.email
);

drop table temp_suppliers;


create temp table temp_products (
    name varchar(200),
    description text,
    sku varchar(50),
    category_id int,
    brand_id int,
    supplier_id int,
    price numeric(10,2),
    cost numeric(10,2),
    stock_quantity int
);

copy temp_products(name, description, sku, category_id, brand_id, supplier_id, price, cost, stock_quantity)
from '/Users/nikitastepanenko/Desktop/project/csv_data/products.csv'
with (format csv, header true, delimiter ',');

insert into products (name, description, sku, category_id, brand_id, supplier_id, price, cost, stock_quantity)
select t.name, t.description, t.sku, t.category_id, t.brand_id, t.supplier_id, t.price, t.cost, t.stock_quantity
from temp_products t
where not exists (
    select 1 from products p where p.sku = t.sku
);

drop table temp_products;


create temp table temp_customers (
    first_name varchar(50),
    last_name varchar(50),
    email varchar(100),
    phone varchar(50),
    address text,
    city varchar(50),
    country varchar(150)
);

copy temp_customers(first_name, last_name, email, phone, address, city, country)
from '/Users/nikitastepanenko/Desktop/project/csv_data/customers.csv'
with (format csv, header true, delimiter ',');

insert into customers (first_name, last_name, email, phone, address, city, country)
select t.first_name, t.last_name, t.email, t.phone, t.address, t.city, t.country
from temp_customers t
where not exists (
    select 1 from customers c where c.email = t.email
);

drop table temp_customers;


create temp table temp_employees (
    first_name varchar(50),
    last_name varchar(50),
    email varchar(100),
    phone varchar(50),
    position varchar(50),
    hire_date date
);

copy temp_employees(first_name, last_name, email, phone, position, hire_date)
from '/Users/nikitastepanenko/Desktop/project/csv_data/employees.csv'
with (format csv, header true, delimiter ',');

insert into employees (first_name, last_name, email, phone, position, hire_date)
select t.first_name, t.last_name, t.email, t.phone, t.position, t.hire_date
from temp_employees t
where not exists (
    select 1 from employees e where e.email = t.email
);

drop table temp_employees;


create temp table temp_orders (
    customer_id int,
    employee_id int,
    order_date timestamp,
    status varchar(20),
    total_amount numeric(12,2),
    shipping_address text
);

copy temp_orders(customer_id, employee_id, order_date, status, total_amount, shipping_address)
from '/Users/nikitastepanenko/Desktop/project/csv_data/orders.csv'
with (format csv, header true, delimiter ',');

insert into orders (customer_id, employee_id, order_date, status, total_amount, shipping_address)
select t.customer_id, t.employee_id, t.order_date, t.status, t.total_amount, t.shipping_address
from temp_orders t
where not exists (
    select 1 from orders o
    where o.customer_id = t.customer_id
      and o.order_date = t.order_date
      and o.shipping_address = t.shipping_address
);

drop table temp_orders;


create temp table temp_order_items (
    order_id int,
    product_id int,
    quantity int,
    unit_price numeric(10,2),
    discount numeric(5,2)
);

copy temp_order_items(order_id, product_id, quantity, unit_price, discount)
from '/Users/nikitastepanenko/Desktop/project/csv_data/order_items.csv'
with (format csv, header true, delimiter ',');

insert into order_items (order_id, product_id, quantity, unit_price, discount)
select t.order_id, t.product_id, t.quantity, t.unit_price, t.discount
from temp_order_items t
where not exists (
    select 1 from order_items oi
    where oi.order_id = t.order_id
      and oi.product_id = t.product_id
      and oi.unit_price = t.unit_price
);

drop table temp_order_items;


create temp table temp_payments (
    order_id int,
    payment_date timestamp,
    amount numeric(12,2),
    payment_method varchar(30),
    status varchar(20)
);

copy temp_payments(order_id, payment_date, amount, payment_method, status)
from '/Users/nikitastepanenko/Desktop/project/csv_data/payments.csv'
with (format csv, header true, delimiter ',');

insert into payments (order_id, payment_date, amount, payment_method, status)
select t.order_id, t.payment_date, t.amount, t.payment_method, t.status
from temp_payments t
where not exists (
    select 1 from payments p
    where p.order_id = t.order_id
      and p.payment_date = t.payment_date
);

drop table temp_payments;


select 'categories' as table_name, count(*) from categories
union all
select 'brands', count(*) from brands
union all
select 'suppliers', count(*) from suppliers
union all
select 'products', count(*) from products
union all
select 'customers', count(*) from customers
union all
select 'employees', count(*) from employees
union all
select 'orders', count(*) from orders
union all
select 'order_items', count(*) from order_items
union all
select 'payments', count(*) from payments;