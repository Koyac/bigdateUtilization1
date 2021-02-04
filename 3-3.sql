select dt,count(purchase_amount) as purchase_count,
sum(purchase_amount) as total_sum,avg(purchase_amount) as avg_amount
from purchase_log
group by dt
order by dt

select dt,sum(purchase_amount) as total_amount,
avg(sum(purchase_amount)) over(order by dt rows between 6 preceding 
							   and current row) as seven_day_avg,
case when 7=count(*) over(order by dt rows between 6 preceding and current row)
then avg(sum(purchase_amount)) over(order by dt rows between 6 preceding and current row)
end as seven_day_acg_string
from purchase_log
group by dt
order by dt

select dt,substring(dt,1,7) as year_mount,sum(purchase_amount) as total_amout,
sum(sum(purchase_amount)) over(partition by substring(dt,1,7) order 
							   by dt rows unbounded preceding) as agg_amount
from purchase_log
group by dt
order by dt

with
daily_purchase as (
	select dt,substring(dt,1,4) as year,
	substring(dt,6,2) as month,
	substring(dt,9,2) as date,
	sum(purchase_amount) as purchase_amount
	from purchase_log
	group by dt
)
select *
from daily_purchase
order by dt


with
daily_purchase as (
	select dt,substring(dt,1,4) as year,
	substring(dt,6,2) as month,
	substring(dt,9,2) as date,
	sum(purchase_amount) as purchase_amount
	from purchase_log
	group by dt
)
select dt,concat(year,'-',month) as year_month,purchase_amount,
sum(purchase_amount) over(partition by year,month order by dt rows unbounded preceding)
as agg_amount
from daily_purchase
order by dt


with
daily_purchase as (
	select dt,substring(dt,1,4) as year,
	substring(dt,6,2) as month,
	substring(dt,9,2) as date,
	sum(purchase_amount) as purchase_amount
	from purchase_log
	group by dt
)
select month,
sum(case year when '2014' then purchase_amount end) as amount_2014,
sum(case year when '2015' then purchase_amount end) as amount_2015,
100*(sum(case year when '2015' then purchase_amount end)/sum(case year when '2014' then purchase_amount end)) as rate
from daily_purchase
group by month
order by month


with
daily_purchase as (
	select dt,substring(dt,1,4) as year,
	substring(dt,6,2) as month,
	substring(dt,9,2) as date,
	sum(purchase_amount) as purchase_amount
	from purchase_log
	group by dt
),
monthly_amount as (
	select year,month,sum(purchase_amount) as amount
	from daily_purchase
	group by year,month
),
calc_index as (
	select year,month,amount,
	sum(case when year='2015' then amount end) over(order by year,month rows unbounded preceding) as agg_amount,
	sum(amount) over(order by year,month rows between 11 preceding and current row)
from monthly_amount
order by year,month
)
select concat(year,'-',month) as year_month,amount,agg_amount,year_avg_amount
from calc_index
where year = '2015'
order by year_month
エラー


with
sub_category_amount as (
	select category as category,
	sub_category as sub_category,
	sum(price) as amount
	from purchase_detail_log
	group by category,sub_category
),
category_amount as (
	select category,
	'all' as sub_category,
	sum(price) as amount
	from purchase_detail_log
	group by category
),
total_amount as (
	select 'all' as category,
	'all' as sub_category,
	sum(price) as amount
	from purchase_detail_log
)
select category,sub_category,amount from sub_category_amount
union all select category,sub_category,amount from category_amount
union all select category,sub_category,amount from total_amount;

select 
coalesce(category,'all') as category,
coalesce(sub_category,'all') as sub_category,
sum(price) as amount
from 
purchase_detail_log
group by rollup(category,sub_category);