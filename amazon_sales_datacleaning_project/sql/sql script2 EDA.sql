use amazon_sales;
select * from amazon_sales_final;

-- which brand sells the most --

select brand, count(brand) from amazon_sales_final
group by brand
order by count(brand) desc
limit 1;
 
 -- which brand sells the least --
 
select brand,count(*) from amazon_sales_final
group by brand
order by count(brand) asc
limit 1;

-- which products has highest rating--

select max(ratings_cleaned) from amazon_sales_final;

select title, brand, ratings_cleaned
from amazon_sales_final
where ratings_cleaned = (select max(ratings_cleaned) from amazon_sales_final);
 
 -- which product has low ratings --
 
 select title, ratings_cleaned from amazon_sales_final
 where ratings_cleaned= (select min(ratings_cleaned) from amazon_sales_final);
 
 -- which brand has most high rated products --
 
select brand, count(*) from amazon_sales_final
where ratings_cleaned=( select max(ratings_cleaned) from 
                        amazon_sales_final)
group by brand
order by count(*) desc
limit 1;

-- total revenue --

select sum(unit_sold_last_month * coalesce(`current/discounted_price`,listed_price,price_on_variant,'unknown')) as total_revenue from amazon_sales_final;
 
-- total revenue brand wise --

select brand, 
sum(unit_sold_last_month * coalesce(`current/discounted_price`,listed_price,price_on_variant,'unknown')) as total_rev
from amazon_sales_final
group by brand
order by total_rev desc;

-- max total rev by brand --

select brand, sum(unit_sold_last_month * coalesce(`current/discounted_price`,listed_price,price_on_variant,'unknown')) as total_rev
from amazon_sales_final
group by brand
order by total_rev desc
limit 1;

select `current/discounted_price`, listed_price from amazon_sales_final;
select * from amazon_sales_final where brand like 'OW%';

-- brand wise best seller --
 
select title,brand,ratings_cleaned
from amazon_sales_final
where ratings_cleaned=(select max(ratings_cleaned) from amazon_sales_final);

-- which brand has most best seller--

select * from amazon_sales_final;

with top_best_seller as
(
select brand, count(*) as best_seller_count
from amazon_sales_final
where is_best_seller = 'yes'
group by brand
)
select brand,best_seller_count
from top_best_seller
where best_seller_count =(select max(best_seller_count) from top_best_seller);

-- does sponsership influence best sellers --

select brand, count(*) as best_seller_count
from amazon_sales_final
where is_best_seller = 'yes' and is_sponsored ='no'
group by brand;

-- does sponsership influence sales units --

select unit_sold_last_month, is_sponsored from amazon_sales_final;

select is_sponsored, round(avg(unit_sold_last_month)) from amazon_sales_final
group by is_sponsored;

select is_sponsored,count(is_sponsored) from amazon_sales_final 
group by is_sponsored; 

select brand, buy_box_availability,count(buy_box_availability) 
from amazon_sales_final
group by brand, buy_box_availability
order by brand asc;

select brand,
sum(case when buy_box_availability = 'in stock' then 1 else 0 end) as in_stock,
sum(case when buy_box_availability= 'out of stock' then 1 else 0 end) as out_of_stock
from amazon_sales_final
group by brand
order by brand asc;

-- monthy sales trends --
-- dataset contains only two timestamps in the same month Therefore, monthly trend cannot be studied.--

select count(*), monthname(collected_at)
from amazon_sales_final
group by monthname(collected_at);

select count(*), collected_at
from amazon_sales_final
group by collected_at;

-- avg delivery time --

select datediff(delivery_date,collected_at) from amazon_sales_final;

select brand,
      round(avg(datediff(delivery_date,collected_at))) as delivery_days
from amazon_sales_final
group by brand;

-- rating vs selling correlation --

select ratings_cleaned, avg(unit_sold_last_month) 
from amazon_sales_final
group by ratings_cleaned
order by ratings_cleaned desc; 

-- price vs sales relation --

select avg(unit_sold_last_month) , avg(`current/discounted_price`) 
from amazon_sales_final;

select 
case
	when `current/discounted_price` <1000 then 'low price'
    when `current/discounted_price` >1000 and `current/discounted_price` <5000 then 'medium'
    else 'high price'
end as price_range,
avg(unit_sold_last_month) as average_unit_sold
from amazon_sales_final
group by price_range;


select `current/discounted_price` from amazon_sales_final 
where `current/discounted_price`= `current/discounted_price` >5000;