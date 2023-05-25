create or replace table `nbcu-ds-sandbox-a-001.Shunchao_Sandbox.Top_Daily_30_Contents` as

with Top_30_Contents as ( ---Pull top 30 VOD display_name by daily qualified reach on 5/24 (> 5 minutes watched)
select 
current_date("America/New_York")-1 as Days,
lower(display_name) as Display_Name,
count(distinct adobe_tracking_id) as Daily_reached,
from `nbcu-ds-prod-001.PeacockDataMartSilver.SILVER_VIDEO` s
where 1=1
and adobe_date = current_date("America/New_York")-1
and num_seconds_played_no_ads > 300
and lower(consumption_type_detail) = "vod" -- VOD top 30
group by 1,2
order by 3 desc
limit 30
),

D1 as (
select 
current_date("America/New_York")-1 as Days,
lower(display_name) as Display_Name,
count(distinct adobe_tracking_id) as Cumul_reached,
from `nbcu-ds-prod-001.PeacockDataMartSilver.SILVER_VIDEO` s
where 1=1
and adobe_date between DATE_ADD(current_date("America/New_York")-2, INTERVAL -18*30 DAY) and current_date("America/New_York")-1
and num_seconds_played_no_ads > 300
and lower(display_name) in (select distinct Display_Name from Top_30_Contents)
and lower(consumption_type_detail) = "vod" -- VOD top 30
group by 1,2
order by 3 desc
),

D2 as (
select
current_date("America/New_York")-2 as Days,
lower(display_name) as Display_Name,
count(distinct adobe_tracking_id) as Cumul_reached,
from `nbcu-ds-prod-001.PeacockDataMartSilver.SILVER_VIDEO` s
where 1=1
and adobe_date between DATE_ADD(current_date("America/New_York")-1, INTERVAL -18*30 DAY) and current_date("America/New_York")-1
and num_seconds_played_no_ads > 300
and lower(display_name) in (select distinct Display_Name from Top_30_Contents)
and lower(consumption_type_detail) = "vod"
group by 1,2
order by 3 desc
)

select D1.*,
D1.Cumul_reached - D2.Cumul_reached as Net_New_Reached
from D1
left join D2 on D1.Display_Name = D2.Display_Name
order by 3 desc
