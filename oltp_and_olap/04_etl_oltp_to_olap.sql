insert into dim_date (date_key, full_date, day, month, month_name, quarter, year, day_of_week)
select
    to_char(d, 'YYYYMMDD')::int,
    d::date,
    extract(day from d)::int,
    extract(month from d)::int,
    to_char(d, 'Month'),
    extract(quarter from d)::int,
    extract(year from d)::int,
    to_char(d, 'Day')
from generate_series('2020-01-01'::date, '2030-12-31'::date, '1 day'::interval) d
where not exists (
    select 1 from dim_date dd where dd.date_key = to_char(d, 'YYYYMMDD')::int
);


create extension if not exists dblink;
insert into dim_category (category_id, name, description)
select c.category_id, c.name, c.description
from dblink(
    'dbname=electro_shop_oltp host=localhost port=5433 user=nikitastepanenko password=52mnbkot85',
    'select category_id, name, description from categories'
) as c(category_id int, name varchar, description text)
where not exists (
    select 1 from dim_category dc where dc.category_id = c.category_id
);


insert into dim_brand (brand_id, name, country)
select b.brand_id, b.name, b.country
from dblink(
    'dbname=electro_shop_oltp host=localhost port=5433 user=nikitastepanenko password=52mnbkot85',
    'select brand_id, name, country from brands'
) as b(brand_id int, name varchar, country varchar)
where not exists (
    select 1 from dim_brand db where db.brand_id = b.brand_id
);


insert into dim_supplier (supplier_id, name, city, country)
select s.supplier_id, s.name, s.city, s.country
from dblink(
    'dbname=electro_shop_oltp host=localhost port=5433 user=nikitastepanenko password=52mnbkot85',
    'select supplier_id, name, city, country from suppliers'
) as s(supplier_id int, name varchar, city varchar, country varchar)
where not exists (
    select 1 from dim_supplier ds where ds.supplier_id = s.supplier_id
);


insert into dim_employee (employee_id, first_name, last_name, position, hire_date)
select e.employee_id, e.first_name, e.last_name, e.position, e.hire_date
from dblink(
    'dbname=electro_shop_oltp host=localhost port=5433 user=nikitastepanenko password=52mnbkot85',
    'select employee_id, first_name, last_name, position, hire_date from employees'
) as e(employee_id int, first_name varchar, last_name varchar, position varchar, hire_date date)
where not exists (
    select 1 from dim_employee de where de.employee_id = e.employee_id
);


-- Крок 1: Закрити старі записи, якщо дані змінилися
update dim_customer dc
set end_date = now(),    
    is_current = false
from dblink(
    'dbname=electro_shop_oltp host=localhost port=5433 user=nikitastepanenko password=52mnbkot85',
    'select customer_id, first_name, last_name, email, city, country from customers'
) as c(customer_id int, first_name varchar, last_name varchar, email varchar, city varchar, country varchar)
where dc.customer_id = c.customer_id  
  and dc.is_current = true  
  and (dc.first_name <> c.first_name       
       or dc.last_name <> c.last_name       
       or dc.email <> c.email       
       or coalesce(dc.city, '') <> coalesce(c.city, '')       
       or coalesce(dc.country, '') <> coalesce(c.country, ''));

-- Крок 2: Вставити нові версії
insert into dim_customer (customer_id, first_name, last_name, email, city, country, start_date, is_current)
select c.customer_id, c.first_name, c.last_name, c.email, c.city, c.country, now(), true
from dblink(
    'dbname=electro_shop_oltp host=localhost port=5433 user=nikitastepanenko password=52mnbkot85',
    'select customer_id, first_name, last_name, email, city, country from customers'
) as c(customer_id int, first_name varchar, last_name varchar, email varchar, city varchar, country varchar)
where not exists (
    select 1 from dim_customer dc
    where dc.customer_id = c.customer_id
      and dc.is_current = true
);


update dim_product dp
set end_date = now(),
    is_current = false
from dblink(
    'dbname=electro_shop_oltp host=localhost port=5433 user=nikitastepanenko password=52mnbkot85',
    'select product_id, name, price, cost, category_id, brand_id from products'
) as p(product_id int, name varchar, price numeric, cost numeric, category_id int, brand_id int)
where dp.product_id = p.product_id
  and dp.is_current = true
  and (dp.name <> p.name
       or dp.price <> p.price
       or dp.cost <> p.cost
       or dp.category_id <> p.category_id
       or dp.brand_id <> p.brand_id);

insert into dim_product (product_id, name, sku, price, cost, category_id, brand_id, start_date, is_current)
select p.product_id, p.name, p.sku, p.price, p.cost, p.category_id, p.brand_id, now(), true
from dblink(
    'dbname=electro_shop_oltp host=localhost port=5433 user=nikitastepanenko password=52mnbkot85',
    'select product_id, name, sku, price, cost, category_id, brand_id from products'
) as p(product_id int, name varchar, sku varchar, price numeric, cost numeric, category_id int, brand_id int)
where not exists (
    select 1 from dim_product dp
    where dp.product_id = p.product_id
      and dp.is_current = true
);


create temp table temp_source_sales as
select 
    o.order_id,
    o.order_date,
    o.status,
    o.customer_id,
    o.employee_id,
    oi.product_id,
    oi.quantity,
    oi.unit_price,
    oi.discount
from dblink(
    'dbname=electro_shop_oltp host=localhost port=5433 user=nikitastepanenko password=52mnbkot85',
    'select order_id, order_date, status, customer_id, employee_id from orders'
) as o(order_id int, order_date timestamp, status varchar, customer_id int, employee_id int)
join dblink(
    'dbname=electro_shop_oltp host=localhost port=5433 user=nikitastepanenko password=52mnbkot85',
    'select order_id, product_id, quantity, unit_price, discount from order_items'
) as oi(order_id int, product_id int, quantity int, unit_price numeric, discount numeric) 
  on o.order_id = oi.order_id;

insert into fact_sales (date_key, customer_key, product_key, employee_key, order_id, quantity, unit_price, discount, total_amount, profit)
select
    to_char(ts.order_date, 'YYYYMMDD')::int,
    dc.customer_key,
    dp.product_key,
    de.employee_key,
    ts.order_id,
    ts.quantity,
    ts.unit_price,
    ts.discount,
    round(ts.quantity * ts.unit_price * (1 - ts.discount / 100), 2),
    round(ts.quantity * (ts.unit_price * (1 - ts.discount / 100) - dp.cost), 2)
from temp_source_sales ts
join dim_customer dc on dc.customer_id = ts.customer_id and dc.is_current = true
join dim_product dp on dp.product_id = ts.product_id and dp.is_current = true
join dim_employee de on de.employee_id = ts.employee_id
where ts.status not in ('cancelled')
  and not exists (
    select 1 from fact_sales fs
    where fs.order_id = ts.order_id
      and fs.product_key = dp.product_key
  );

drop table temp_source_sales;


create temp table temp_source_inventory as
select 
    product_id,
    supplier_id,
    stock_quantity,
    cost
from dblink(
    'dbname=electro_shop_oltp host=localhost port=5433 user=nikitastepanenko password=52mnbkot85',
    'select product_id, supplier_id, stock_quantity, cost from products'
) as p(product_id int, supplier_id int, stock_quantity int, cost numeric);

insert into fact_inventory (date_key, product_key, supplier_key, stock_quantity, stock_value)
select
    to_char(current_date, 'YYYYMMDD')::int,
    dp.product_key,
    ds.supplier_key,
    tsi.stock_quantity,
    round(tsi.stock_quantity * tsi.cost, 2)
from temp_source_inventory tsi
join dim_product dp on dp.product_id = tsi.product_id and dp.is_current = true
join dim_supplier ds on ds.supplier_id = tsi.supplier_id
where not exists (
    select 1 from fact_inventory fi
    where fi.product_key = dp.product_key
      and fi.date_key = to_char(current_date, 'YYYYMMDD')::int
);

drop table temp_source_inventory;


create temp table temp_source_bridge as
select 
    product_id,
    supplier_id,
    cost
from dblink(
    'dbname=electro_shop_oltp host=localhost port=5433 user=nikitastepanenko password=52mnbkot85',
    'select product_id, supplier_id, cost from products'
) as p(product_id int, supplier_id int, cost numeric);

insert into bridge_product_supplier (product_key, supplier_key, supply_price, lead_time_days)
select
    dp.product_key,
    ds.supplier_key,
    tsb.cost,
    floor(random() * 14 + 1)::int
from temp_source_bridge tsb
join dim_product dp on dp.product_id = tsb.product_id and dp.is_current = true
join dim_supplier ds on ds.supplier_id = tsb.supplier_id
where not exists (
    select 1 from bridge_product_supplier bps
    where bps.product_key = dp.product_key
      and bps.supplier_key = ds.supplier_key
);

drop table temp_source_bridge


select 'dim_date' as tbl, count(*) from dim_date
union all
select 'dim_customer', count(*) from dim_customer
union all
select 'dim_product', count(*) from dim_product
union all
select 'dim_category', count(*) from dim_category
union all
select 'dim_brand', count(*) from dim_brand
union all
select 'dim_employee', count(*) from dim_employee
union all
select 'dim_supplier', count(*) from dim_supplier
union all
select 'fact_sales', count(*) from fact_sales
union all
select 'fact_inventory', count(*) from fact_inventory
union all
select 'bridge_product_supplier', count(*) from bridge_product_supplier;