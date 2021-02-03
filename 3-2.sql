select count(*) as total,
count(distinct user_id),
count(distinct product_id),
sum(score),
avg(score),
max(score),
min(score),
stddev(score)
from review

select 
user_id,
count(*) as total_count,
count(distinct product_id) as product_count,
sum(score) as sum,
max(score) as max,
min(score) as min
from review
group by user_id;


select user_id,product_id,score,avg(score) over() as avg_score,
avg(score) over(partition by user_id) as user_avg_score,
score - avg(score) over(partition by user_id) as user_avg_score_diff
from review

select product_id,score,
row_number() over(order by score desc) as row,
rank() over(order by score desc),
dense_rank() over(order by score desc),
lag(product_id) over(order by score desc) as lag1,
lag(product_id,2) over(order by score desc) as lag2,
lead(product_id) over(order by score desc) as lead1,
lead(product_id) over(order by score desc) as lead2
from popular_products
order by row;

select product_id,score,
row_number() over(order by score desc) as row,
sum(score) over(order by score desc rows between unbounded preceding and current row) as cum_score,
avg(score) over(order by score desc rows between 1 preceding and 1 following) as local_avg,
first_value(product_id) over(order by score desc rows between unbounded preceding and unbounded following) as first_value,
last_value(product_id) over(order by score desc rows between unbounded preceding and unbounded following) as last_value
from popular_products
order by row


select product_id,row_number() over(order by score desc) as row,
array_agg(product_id) over(order by score desc rows between unbounded preceding and unbounded following) as whole_agg,
array_agg(product_id) over(order by score desc rows between unbounded preceding and current row) as cum_agg,
array_agg(product_id) over(order by score desc rows between 1 preceding and 1 following) as local_agg
from popular_products
where category='action'
order by row


select *
from (select category,product_id,score,row_number() over(partition by category order by score desc) as rank from popular_products)
as pupolar_products_with_rank
where rank <= 2
order by category,score