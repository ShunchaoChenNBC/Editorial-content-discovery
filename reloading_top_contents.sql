--- reload data, please make sure parse the string format date to date format 

create or replace table `nbcu-ds-sandbox-a-001.Shunchao_Sandbox.Top_Daily_30_Contents` as 

with Top_50_Contents as ( ---Pull top 50 VOD display_name by daily qualified reach on 5/24 (> 5 minutes watched)
select 
date(parse_datetime("%Y-%m-%d", "2023-08-01")) as Days, -- important convertion 
lower(display_name) as Display_Name,
count(distinct adobe_tracking_id) as Daily_Reached,
from `nbcu-ds-prod-001.PeacockDataMartSilver.SILVER_VIDEO` s
where 1=1
and adobe_date = "2023-08-01"
and num_seconds_played_no_ads > 300
and lower(consumption_type_detail) = "vod" -- VOD top 50
group by 1,2
order by 3 desc
limit 50
),

D1 as (
select 
date(parse_datetime("%Y-%m-%d", "2023-08-01")) as Days,
lower(s.display_name) as Display_Name,
count(distinct adobe_tracking_id) as Cumul_Reached,
from `nbcu-ds-prod-001.PeacockDataMartSilver.SILVER_VIDEO` s
where 1=1
and adobe_date between DATE_ADD( "2023-08-01", INTERVAL -18*30 DAY) and  "2023-08-01"
and num_seconds_played_no_ads > 300
and lower(s.display_name) in (select distinct Display_Name from Top_50_Contents)
and lower(consumption_type_detail) = "vod" -- VOD top 30
group by 1,2
order by 3 desc
),

D2 as (
select
date(parse_datetime("%Y-%m-%d", "2023-07-31")) as Days,
lower(display_name) as Display_Name,
count(distinct adobe_tracking_id) as Cumul_Reached,
from `nbcu-ds-prod-001.PeacockDataMartSilver.SILVER_VIDEO` s
where 1=1
and adobe_date between DATE_ADD("2023-08-01", INTERVAL -18*30 DAY) and "2023-07-31"
and num_seconds_played_no_ads > 300
and lower(display_name) in (select distinct Display_Name from Top_50_Contents)
and lower(consumption_type_detail) = "vod"
group by 1,2
order by 3 desc
)

select D1.Days,
D1.Display_Name,
t.Daily_Reached,
D1.Cumul_Reached,
D1.Cumul_reached - D2.Cumul_reached as Net_New_Reached
from D1
left join D2 on D1.Display_Name = D2.Display_Name
left join Top_50_Contents t on t.Display_Name = D1.Display_Name
union all
select *
from `nbcu-ds-sandbox-a-001.Shunchao_Sandbox.Top_Daily_30_Contents`
order by 4 desc
