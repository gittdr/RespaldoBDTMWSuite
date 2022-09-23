SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROC [dbo].[SSRS_MilesFrom]   
 (
@TripSegmentNumber int,
@MaxDistance int,
 @UseDate char(3),
 @TractorStatus varchar(2000)
 )  
AS  
  
SET NOCOUNT ON  
/**
 *
 * NAME:
 * dbo.SSRS_MilesFrom 
 Usage: Input a trip segment number and see nearby trucks. You can also see where trucks WILL be in distance in the future for STD/PLN loads
 *
 * REVISION HISTORY:
 *
 * 
 **/ 
  
 declare @Stop table (
 [Company ID] varchar(8),
 [CLoc] geography null,
 [Company Name] varchar(100),
 CityState varchar(25),Zip varchar(10),StopDate datetime,
 CityCode int
 )
 
insert @Stop
select top 1 
c.cmp_id,
'Point (-' + CONVERT(varchar(50),c.cmp_longseconds/3600.0000) + ' ' + 
	CONVERT(varchar(50),c.cmp_latseconds/3600.0000) + ')', --2  
c.cmp_name,
c.cty_nmstct,
c.cmp_zip,
case @UseDate
when 'EAR' then s.stp_schdtearliest
when 'LAT' then s.stp_schdtlatest
when 'ARR' then s.stp_arrivaldate
when 'DEP' then s.stp_departuredate
else s.stp_arrivaldate
end,
c.cmp_city
from stops s
join company c on s.cmp_id = c.cmp_id
join legheader l on s.lgh_number = s.lgh_number
where s.lgh_number = @TripSegmentNumber
ORDER BY s.stp_mfh_sequence

if (select [CLoc] from @Stop) is null
	BEGIN
	-- Try the city
	update @Stop
		set CLoc = 
		(select top 1 'Point (-' + CONVERT(varchar(50),c.cty_longitude) + ' ' + 
	CONVERT(varchar(50),c.cty_latitude) + ')'
	from city c where c.cty_code = CityCode)
	
		if (select [CLoc] from @Stop) is null
			BEGIN
			RAISERROR (N'No GPS found for the first stop on leg!', -- Message text.
           10, -- Severity,
           1, -- State,
           @TripSegmentNumber, -- First argument.
           5); -- Second argument.
-- The message text returned is: This is message number 5.
				RETURN
			END

	END
  
  

  
Declare @TractorPositions table ([Tractor] varchar(8) null,TractorStatus varchar(8) null,[Position] geography null, --2  
[Latitude] float null,[Longitude] float null,[GPS Date] datetime null,[Description] varchar(255) null, --6  
CurrentDate datetime,[LastPingDate] datetime,[Distance] float null,EstFreeStartedDate datetime,StartGeo geography null,
EstFreePLNDate datetime,PlanGeo Geography null) --13  
  
  
declare @Company Geography

  set @Company= (select top 1 [CLoc] from @stop)  
  
insert into @Tractorpositions  
select trc_number 
,trc_status 
,'Point (-' + CONVERT(varchar(50),trc_gps_longitude/3600.0000) + ' ' + CONVERT(varchar(50),trc_gps_latitude/3600.0000) + ')'
,trc_gps_latitude/3600.0000  
,-1*(trc_gps_longitude/3600.00)  
,trc_gps_date  
,trc_gps_desc --6  
,getdate()
,ISNULL((select top 1 ckc_date from checkcall where ckc_tractor=trc.trc_number order by ckc_date desc),'1/1/1950')
,@Company.STDistance('Point (-' + CONVERT(varchar(50),trc_gps_longitude/3600.0000) + ' ' + CONVERT(varchar(50),trc_gps_latitude/3600.0000) + ')') / 1609.344
,(select top 1 stp_departuredate from stops s
join event e on s.stp_number = e.stp_number
join legheader l on s.lgh_number = l.lgh_number
where e.evt_tractor = trc.trc_number
and l.lgh_outstatus = 'STD'
order by s.stp_departuredate desc)
,null
,(select top 1 stp_departuredate from stops s
join event e on s.stp_number = e.stp_number
join legheader l on s.lgh_number = l.lgh_number
where e.evt_tractor = trc.trc_number
and l.lgh_outstatus = 'PLN'
order by s.stp_departuredate desc)
,null


 --13  
from tractorprofile trc with(nolock)  
where CHARINDEX(trc.trc_status,@TractorStatus)>0
and trc_number not in ('UNKNOWN','UNK','')  
and (@Company.STDistance('Point (-' + CONVERT(varchar(50),trc_gps_longitude/3600.0000) + ' ' + CONVERT(varchar(50),trc_gps_latitude/3600.0000) + ')')/ 1609.344)<=@MaxDistance


update @TractorPositions set StartGeo = 
(
select top 1 

'Point (-' + CONVERT(varchar(50),c.cmp_longseconds/3600.0000) + ' ' + CONVERT(varchar(50),c.cmp_latseconds/3600.0000) + ')'
from company c 
join stops s on c.cmp_id = s.cmp_id
join event e on e.stp_number = s.stp_number
join legheader l on s.lgh_number = l.lgh_number
where e.evt_tractor = [Tractor]
and l.lgh_outstatus= 'STD'
ORDER BY s.stp_arrivaldate desc
)
where TractorStatus='STD'

update @TractorPositions set StartGeo = 
(
select top 1 

'Point (-' + CONVERT(varchar(50),c.cmp_longseconds/3600.0000) + ' ' + CONVERT(varchar(50),c.cmp_latseconds/3600.0000) + ')'
from company c 
join stops s on c.cmp_id = s.cmp_id
join event e on e.stp_number = s.stp_number
join legheader l on s.lgh_number = l.lgh_number
where e.evt_tractor = [Tractor]
and l.lgh_outstatus= 'PLN'
ORDER BY s.stp_arrivaldate desc
)
where TractorStatus='PLN'


update @TractorPositions set Distance = @Company.STDistance(PlanGeo)/ 1609.344 where  TractorStatus='PLN'

update @TractorPositions set Distance = @Company.STDistance(StartGeo)/ 1609.344 where  TractorStatus='STD' and Distance is null


update @TractorPositions set Distance = -1 where Distance is null
select t.*
from @TractorPositions t

--where Distance<=@MaxDistance and Distance is not null
order by [Distance]
GO
GRANT EXECUTE ON  [dbo].[SSRS_MilesFrom] TO [public]
GO
