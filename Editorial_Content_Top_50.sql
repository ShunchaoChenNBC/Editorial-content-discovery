
with cte as (select 
DATE_ADD(DATE_TRUNC(adobe_date, WEEK(SUNDAY)), interval -7 DAY) as Week_Ending, --Sunday as the last day of a Week
lower(display_name) as Display_Name,
count(distinct adobe_tracking_id) as Distinct_Accts,
from `nbcu-ds-prod-001.PeacockDataMartSilver.SILVER_VIDEO` s
where num_seconds_played_no_ads> 300 and adobe_date between "2023-05-01" and "2023-05-20" and lower(consumption_type_detail) = "vod"
group by 1,2), -- 5 minute qualifier 

cte1 as (select cte.*,
dense_rank() over (partition by Week_Ending order by Distinct_Accts desc) as Ranks
from cte)

select 
Week_Ending,
Display_Name,
Distinct_Accts,
Ranks,
Distinct_Accts - LAG(Distinct_Accts) over (partition by Display_Name order by Week_Ending) as Incremental_Reached,
sum(Distinct_Accts) over (partition by Display_Name order by Week_Ending) as Cumulative_Reached
from cte1
where Ranks <= 50
order by 1 desc,4









