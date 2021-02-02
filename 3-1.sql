select stamp,
substring(url from 'https?://([^/]*)') as referrer_host,
substring(url from 'id=([^&]*)') as id
from access_log

select
current_date as dt,
current_timestamp as stamp

select purchase_id,amount,coupon,
(amount-coupon) as discount_amount1,COALESCE((amount - coupon),amount) as discount_amount2
from purchase_log_with_coupon;

select user_id,concat(pref_name,city_name) as name1,(pref_name||city_name) as name2
from mst_user_location

select year,greatest(q1,q2,q3,q4) as max, least(q1,q2,q3,q4) as min
from quarterly_sales

select year,(coalesce(q1,0)+coalesce(q2,0)+coalesce(q3,0)+coalesce(q4,0))/4 as average
from quarterly_sales
order by year

select year,
(coalesce(q1,0)+coalesce(q2,0)+coalesce(q3,0)+coalesce(q4,0))/
(sign(coalesce(q1,0))+sign(coalesce(q2,0))+sign(coalesce(q3,0))+sign(coalesce(q4,0)))
as average
from quarterly_sales
order by year 

select dt,ad_id,
cast(clicks as double precision)/impressions as ctr,
100.0*clicks/impressions as ctr_as_percent
from advertising_stats
where dt = '2017-04-01'
order by dt,ad_id


select dt,ad_id,
case when impressions>0 then 100.0*clicks/impressions
end as ctr_as_percent,
100*clicks/nullif(impressions,0) as ctr_as_percent_by_null
from advertising_stats
order by dt,ad_id

select 
abs(x1-x2) as abs,
sqrt(power(x1-x2,2)) as sqrt1
from location_1d

select 
sqrt(power(x1-x2,2)+power(y1-y2,2)) as dist,
point(x1,y1) <-> point(x2,y2) as dist
from location_2d

select user_id,
register_stamp::timestamp as register_stamp,
register_stamp::timestamp + '1 hour'::interval as after1hour,
register_stamp::timestamp + '2 hour'::interval as after2hour,
register_stamp::timestamp + '3 hour'::interval as after3hour,
register_stamp::timestamp + '4 hour'::interval as after4hour
from mst_users_with_birthday


select user_id,
current_date as today,
register_stamp::date as register_date,
current_date - register_stamp::date as diff_days,
from mst_users_with_birthday

select user_id,
current_date as today,
register_stamp::date as register_date,
birth_date::date as birth_date,
extract(year from age(birth_date::date)) as current_age,
extract(year from age(register_stamp::date,birth_date::date)) as register_age
from mst_users_with_birthday

