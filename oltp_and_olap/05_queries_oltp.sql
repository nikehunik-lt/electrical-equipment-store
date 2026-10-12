-- Query 1: Top 10 customers by order value
select
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    c.email,
    count(o.order_id) as total_orders,
    sum(o.total_amount) as total_spent
from customers c
join orders o on c.customer_id = o.customer_id
where o.status = 'delivered'
group by c.customer_id, c.first_name, c.last_name, c.email
order by total_spent desc
limit 10;

-- Query 2: Sales by category over the past year
select
    cat.name as category,
    count(oi.order_item_id) as items_sold,
    sum(oi.quantity) as total_quantity,
    round(sum(oi.quantity * oi.unit_price * (1 - oi.discount / 100)), 2) as revenue
from order_items oi
join products p on oi.product_id = p.product_id
join categories cat on p.category_id = cat.category_id
join orders o on oi.order_id = o.order_id
where o.order_date >= now() - interval '1 year'
  and o.status not in ('cancelled')
group by cat.name
order by revenue desc;

-- Query 3: Average bill by month
select
    to_char(o.order_date, 'YYYY-MM') as month,
    count(distinct o.order_id) as orders_count,
    round(avg(o.total_amount), 2) as avg_order_value,
    round(sum(o.total_amount), 2) as total_revenue
from orders o
where o.status not in ('cancelled')
group by to_char(o.order_date, 'YYYY-MM')
order by month;