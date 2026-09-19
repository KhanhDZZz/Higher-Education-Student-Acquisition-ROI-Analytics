
--View dữ liệu raw
select *
from public.campaignmeta a 
limit 100
;

select *
from public.campaignperformance b
limit 100
;

select *
from public.channelrates c
limit 100
;

--Đang có những campaign nào?
select distinct b."CampaignName" 
from public.campaignperformance b
limit 100
;


--View dữ liệu sau chuẩn hoá
select *
from public.vw_cleanedPerformance_advanced
;

select *
from public."campaignperformance"
;