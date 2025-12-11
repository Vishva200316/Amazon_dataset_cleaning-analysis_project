use amazon_sales;
select * from amazon_sales;
create table amazon_sales1
like amazon_sales;

select * from amazon_sales1;
insert amazon_sales1
select * from amazon_sales;

-- Removing Duplicates --

select * ,
row_number() over(partition by title,rating,number_of_reviews,bought_in_last_month,`current/discounted_price`,price_on_variant,listed_price,is_best_seller,
is_sponsored,is_couponed,buy_box_availability,delivery_details,sustainability_badges,image_url,product_url,collected_at) as row_num
from amazon_sales1;

with duplicates_cte as
(
select * ,
row_number() over(partition by title,rating,number_of_reviews,bought_in_last_month,`current/discounted_price`,price_on_variant,listed_price,is_best_seller,
is_sponsored,is_couponed,buy_box_availability,delivery_details,sustainability_badges,image_url,product_url,collected_at) as row_num
from amazon_sales1
)
select * from duplicates_cte 
where row_num > 1;

select * from amazon_sales1 
where title = 'Amazon Basics 48-Pack AA Alkaline High-Performance Batteries, 1.5 Volt, 10-Year Shelf Life';

CREATE TABLE `amazon_sales2` (
  `title` text,
  `rating` text,
  `number_of_reviews` text,
  `bought_in_last_month` text,
  `current/discounted_price` text,
  `price_on_variant` text,
  `listed_price` text,
  `is_best_seller` text,
  `is_sponsored` text,
  `is_couponed` text,
  `buy_box_availability` text,
  `delivery_details` text,
  `sustainability_badges` text,
  `image_url` text,
  `product_url` text,
  `collected_at` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert amazon_sales2
select * ,
row_number() over(partition by title,rating,number_of_reviews,bought_in_last_month,`current/discounted_price`,price_on_variant,listed_price,is_best_seller,
is_sponsored,is_couponed,buy_box_availability,delivery_details,sustainability_badges,image_url,product_url,collected_at) as row_num
from amazon_sales1;

select * from amazon_sales2;

select * from amazon_sales2 
where row_num>1;

select * from amazon_sales2 where title ='Amazon Basics 48-Pack AA Alkaline High-Performance Batteries, 1.5 Volt, 10-Year Shelf Life';

delete from amazon_sales2
where row_num >1;

-- ratings --

alter table amazon_sales2
add column ratings_cleaned decimal(2,1);

update amazon_sales2
set ratings_cleaned = cast(substring_index(rating,' ',1) as decimal(2,1));

-- no of reviews --

update amazon_sales2
set number_of_reviews= replace(number_of_reviews, ',','');

alter table amazon_sales2
modify column number_of_reviews int;

-- bought in last mon --

select * from amazon_sales2 where bought_in_last_month like '%k%' 
and bought_in_last_month like '%+%';

 select  substring_index(bought_in_last_month,' ',1) as sold,
 case 
   when bought_in_last_month like '%K+%' 
   then cast(replace(substring_index(bought_in_last_month,' ',1),'K+','') as decimal) * 1000
   when bought_in_last_month like '%+%' and bought_in_last_month not like '%K%' 
   then cast( replace(substring_index(bought_in_last_month,' ',1),'+','') as decimal)
   
 end as unit_sold
 from amazon_sales2
 ;
  
  alter table amazon_sales2
  add column unit_sold_last_month int;
  
  update amazon_sales2
  set unit_sold_last_month = case when bought_in_last_month like '%K+%' 
                             then cast(replace(substring_index(bought_in_last_month,' ',1),'K+','')as decimal) * 1000
                             when bought_in_last_month like '%+%' and  bought_in_last_month not like '%K%'
                             then cast(replace(substring_index(bought_in_last_month,' ',1),'+','')as decimal)
						     end ;
                             
select * from amazon_sales2 where bought_in_last_month  like '%K+%' ;
select * from amazon_sales2 where bought_in_last_month like '%+%' and  bought_in_last_month not like '%K%';
 
select * from amazon_sales2;
 
 -- current/discounted_price --
 
 select * from amazon_sales2 where `current/discounted_price` ='';
 
 update amazon_sales2 
 set `current/discounted_price`= null
 where `current/discounted_price` = '';
 
alter table amazon_sales2
modify column `current/discounted_price` decimal(10,2);
 
 -- is best seller --
  
select distinct(is_best_seller) from amazon_sales2;
select * from amazon_sales2 where is_best_seller ='';

update amazon_sales2
set is_best_seller = case
                        when is_best_seller ='best seller' then 'yes'
                        when is_best_seller ='no badge' then 'no'
                        else 'no'
                        end;
 -- is sponsored --
 select distinct(is_sponsored) from amazon_sales2;
 select * from amazon_sales2 where is_sponsored ='';
 
 update amazon_sales2
 set is_sponsored = case
                      when is_sponsored ='organic' then 'no'
                      when is_sponsored = 'sponsored' then 'yes'
                      end;

select * from amazon_sales2;

-- is couponed --
 select distinct(is_couponed) from amazon_sales2;
 select * from amazon_sales2 where is_couponed like 'save%';
       
update amazon_sales2
set is_couponed = case
                    when is_couponed = 'no coupon'or is_couponed ='' then 'no'
                    else 'yes'
                    end;
                      
-- price on variant --
select distinct(price_on_variant) from amazon_sales2;
                    
select * from amazon_sales2 where price_on_variant not like '%$%' or price_on_variant  like '%nan%';

update amazon_sales2
set price_on_variant = null
where price_on_variant not like '%$%' or price_on_variant  like '%nan%';

select trim(replace(substring_index(price_on_variant,' ',-1),'$','')) from amazon_sales2;

update amazon_sales2
set price_on_variant = trim(replace(substring_index(price_on_variant,' ',-1),'$',''));

alter table amazon_sales2
modify column price_on_variant decimal(10,2);

select * from amazon_sales2;

-- listed_price --
select listed_price from amazon_sales2
where listed_price ='no discount';

update amazon_sales2
set listed_price = null
where listed_price ='no discount';

select trim(replace(listed_price,'$','')) from amazon_sales2; 

update amazon_sales2
set listed_price =trim(replace(listed_price,'$',''));

alter table amazon_sales2
modify column listed_price decimal(10,2);

select * from amazon_sales2;
 
 
 -- buy_box_availability --
 select distinct(buy_box_availability) from amazon_sales2;
 update amazon_sales2
 set buy_box_availability ='In Stock'
 where buy_box_availability ='add to cart';

update amazon_sales2
 set buy_box_availability ='Out of Stock'
 where buy_box_availability ='';
 
 select * from amazon_sales2;
 
 -- delivery details --
select distinct(delivery_details) from amazon_sales2;
  
select replace(delivery_details,"Delivery",' ') from amazon_sales2;

update amazon_sales2
set delivery_details=replace(delivery_details,"Delivery",' ');

update amazon_sales2
set delivery_details=null
where delivery_details='';
 
select * from amazon_sales2 where delivery_details = 'Mon, sep 1';
update amazon_sales2
set delivery_details = 'Mon, Sep 1'
where delivery_details ='  Sep 1 - 11';

update amazon_sales2
set delivery_details= str_to_date(concat(substring_index(delivery_details,' ',-2),' 2025'),'%b %e %Y')
where delivery_details is not null;

select concat(substring_index(delivery_details,' ',-2),' 2025') from amazon_sales2
where delivery_details is not null;

select delivery_details from amazon_sales2;

alter table amazon_sales2
modify column delivery_details date;

alter table amazon_sales2
rename column delivery_details to delivery_date;

select * from amazon_sales2;


-- sustainability badge --

select distinct(sustainability_badges) from amazon_sales2;

select * from amazon_sales2
where sustainability_badges ='';

update amazon_sales2
set sustainability_badges=null
where sustainability_badges ='';

select trim(replace
          (replace(replace(sustainability_badges,'1 ',''),
          '+1 more',''),
          '+more',''))
from amazon_sales2;

update amazon_sales2 
set sustainability_badges = trim(replace
          (replace(replace(sustainability_badges,'1 ',''),
          '+1 more',''),
          '+more',''));

-- image url --
select * from amazon_sales2;
select distinct(image_url) from amazon_sales2;
select * from amazon_sales2 where image_url='';
-- product_url--
select * from amazon_sales2 where product_url='';
update amazon_sales2
set product_url = null
where product_url = '';

select concat('https://www.amazon.in',product_url) from amazon_sales2; 

update amazon_sales2
set product_url = concat('https://www.amazon.in',product_url);

select left(product_url,locate('/ref=',product_url)-1) from amazon_sales2;
update amazon_sales2
set product_url = left(product_url,locate('/ref=',product_url)-1);
 
 update amazon_sales2
 set product_url=null
 where product_url='';

select * from amazon_sales2;

select * from amazon_sales2 where `current/discounted_price` is null and price_on_variant is null and listed_price is null;

-- title --
alter table amazon_sales2
add column brand varchar(100);

select distinct(substring_index(title,' ',2)) from amazon_sales2;

select title,
case
	when title like '%amazon basics%' then 'Amazon Basics'
    when title like '%apple%' then 'Apple'
    when title like '%Boya%' then 'Boya'
    when title like '%DJI%' then 'DJI'
    when title like '%duracell%' then 'Duracell'
    when title like '%energizer%' then 'Energizer'
    when title like '%hp%' then 'HP'
    when title like '%lisen%' then 'Lisen'
    when title like '%mounting dream%' then 'Mounting Dream'
    when title like '%owc%' then 'OWC'
    when title like '%peak design%' then 'Peak Design'
    when title like '%razer%' then 'Razer'
    when title like '%roku%' then 'Roku'
    when title like '%seagate%' then 'Seagate'
    when title like '%sony%' then 'Sony'
    when title like '%texas instruments%' then 'Texas Instruments'
    when title like '%transformers%' then 'Transformers'
    else 'other'
end as brand
from amazon_sales2;
    
update amazon_sales2
set brand = case
	when title like '%amazon basics%' then 'Amazon Basics'
    when title like '%apple%' then 'Apple'
    when title like '%Boya%' then 'Boya'
    when title like '%DJI%' then 'DJI'
    when title like '%duracell%' then 'Duracell'
    when title like '%energizer%' then 'Energizer'
    when title like '%hp%' then 'HP'
    when title like '%lisen%' then 'Lisen'
    when title like '%mounting dream%' then 'Mounting Dream'
    when title like '%owc%' then 'OWC'
    when title like '%peak design%' then 'Peak Design'
    when title like '%razer%' then 'Razer'
    when title like '%roku%' then 'Roku'
    when title like '%seagate%' then 'Seagate'
    when title like '%sony%' then 'Sony'
    when title like '%texas instruments%' then 'Texas Instruments'
    when title like '%transformers%' then 'Transformers'
    else 'other'
end ;
select * from amazon_sales2;
-- collected at --

ALTER TABLE amazon_sales2
MODIFY collected_at DATETIME;


create table amazon_sales_final as
select row_num,title,brand,ratings_cleaned,unit_sold_last_month,`current/discounted_price`,
price_on_variant,listed_price,is_best_seller,is_sponsored,is_couponed,
buy_box_availability,delivery_date, sustainability_badges,collected_at from amazon_sales2;

select * from amazon_sales_final;
