#アクション数と割合を計算するクエリ
with
stats as (
	select count(distinct session) as total_uu
	from action_log
)
select l.action,count(l) as action,s.total_uu,
100*count(distinct l.session) / s.total_uu as usage_rate,
1.0*count(l) / count(distinct l.session) as count_per_user
from action_log as l
cross join stats as s
group by l.action,s.total_uu;

#ログイン状態を判別するクエリ
with 
action_log_with_status as (
	select session,user_id,action,
	case when coalesce(user_id,'') != '' then 'login' else 'guest' end as login_status
	from action_log
)
select *
from action_log_with_status

#ログイン状態によるアクション数の集計クエリ
with 
action_log_with_status as (
	select session,user_id,action,
	case when coalesce(user_id,'') <> '' then 'login' else 'guest' end as login_status
	from action_log
)
select 
coalesce(action,'all') as action,
coalesce(login_status,'all') as login_status,
count(distinct session) as action_uu,
count(1) as action_count
from action_log_with_status
group by rollup(action,login_status)

#会員状態を判別するクエリ
with 
action_log_with_status as (
	select session,user_id,action,
	case when coalesce(max(user_id)
	over(partition by session order by stamp
	rows between unbounded preceding and current row),'')<>'' then 'member' else 'none'
	end as member_status,stamp
	from action_log
)
select *
from action_log_with_status

#性別と年齢から年齢別区分を計算するクエリ
with 
mst_users_with_int_birth_date as (
	select *,20170101 as int_specific_date,
	cast(replace(substring(birth_date,1,10),'-','') as integer) as int_birth_date
	from mst_users
),
mst_users_with_age as (
	select *,floor((int_specific_date-int_birth_date)/10000) as age
	from mst_users_with_int_birth_date
),
mst_users_with_category as (
	select user_id,sex,age,concat(
		case when 20 <= age then sex
		else ''
		end,
		case when age between 4 and 12 then 'C'
		when age between 13 and 19 then 'T'
		when age between 20 and 34 then '1'
		when age between 35 and 49 then '2'
		when age >= 50 then '3'
		end
	) as category
	from mst_users_with_age
)
select *
from mst_users_with_category


#年齢別区分ごとの人数を集計するクエリ
with 
mst_users_with_int_birth_date as (
	select *,20170101 as int_specific_date,
	cast(replace(substring(birth_date,1,10),'-','') as integer) as int_birth_date
	from mst_users
),
mst_users_with_age as (
	select *,floor((int_specific_date-int_birth_date)/10000) as age
	from mst_users_with_int_birth_date
),
mst_users_with_category as (
	select user_id,sex,age,concat(
		case when 20 <= age then sex
		else ''
		end,
		case when age between 4 and 12 then 'C'
		when age between 13 and 19 then 'T'
		when age between 20 and 34 then '1'
		when age between 35 and 49 then '2'
		when age >= 50 then '3'
		end
	) as category
	from mst_users_with_age
)
select category,count(1) as user_count
from mst_users_with_category
group by category

#一週間に何日利用しているかを集計するクエリ
with
action_log_with_dt as (
	select *,substring(stamp,1,10) as dt
	from action_log
),
action_day_count_per_user as (
	select user_id,count(distinct dt) as action_day_count
	from action_log_with_dt
	where dt between '2016-11-01' and '2017-11-07'
	group by user_id
)
select action_day_count,count(distinct user_id) as user_count
from action_day_count_per_user
group by action_day_count
order by action_day_count

#ユーザーごとのアクションフラグを集計するクエリ
with
user_action_flag as (
	select user_id,
	sign(sum(case when action='purchase' then 1 else 0 end)) as has_purchase,
	sign(sum(case when action='review' then 1 else 0 end)) as has_review,
	sign(sum(case when action='favorite' then 1 else 0 end)) as has_favorite
	from action_log
	group by user_id
)
select *
from user_action_flag