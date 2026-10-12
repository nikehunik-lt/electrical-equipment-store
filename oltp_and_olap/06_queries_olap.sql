select
    dd.year,
    dd.month,
    dd.month_name,
    sum(fs.total_amount) as revenue,
    sum(fs.profit) as profit,
    round(avg(fs.profit / nullif(fs.total_amount, 0) * 100), 2) as profit_margin_pct
from fact_sales fs
join dim_date dd on fs.date_key = dd.date_key
group by dd.year, dd.month, dd.month_name
order by dd.year, dd.month;

select 
    fs.order_id,
    dp.name as product_name,
    fs.quantity,
    fs.unit_price,
    fs.discount,
    dp.cost,
    round(fs.unit_price * (1 - fs.discount / 100), 2) as final_price_per_item,
    fs.profit
from fact_sales fs
join dim_product dp on fs.product_key = dp.product_key
where fs.profit < 0
limit 10;

select
    dc.name as category,
    sum(fs.total_amount) as revenue,
    sum(fs.profit) as profit
from fact_sales fs
join dim_product dp on fs.product_key = dp.product_key
join dim_category dc on dp.category_id = dc.category_key
group by dc.name
order by profit desc
limit 5;


select
    dc.country,
    count(distinct dc.customer_id) as active_customers,
    sum(fs.total_amount) as total_revenue
from fact_sales fs
join dim_customer dc on fs.customer_key = dc.customer_key
where dc.is_current = true
group by dc.country
order by total_revenue desc;