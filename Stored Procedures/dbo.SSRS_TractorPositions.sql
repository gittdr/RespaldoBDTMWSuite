SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[SSRS_TractorPositions]   
   
AS  
  
SET NOCOUNT ON  
/**
 *
 * NAME:
 * dbo.SSRS_TractorPositions
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
Tractor Positions based on tractorprofile GPS data  
Intended for use on a SSRS report with a map using the Geography data type  
Requires SQL 2008 or later  
Assumes negative Longitude (Western hemisphere)
 *
**************************************************************************

Sample call


exec SSRS_TractorPositions


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Description of result set
 *
 * PARAMETERS:
 * 001 - @lgh_number int - The legheader number
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR created example blurb
 **/ 
  
Declare @TractorPositions table ([Tractor] varchar(8) null,TractorStatus varchar(8) null,[Position] geography null, --2  
[Latitude] float null,[Longitude] float null,[GPS Date] datetime null,[Description] varchar(255) null, --6  
[Next Stop Segment Number] int null,[Next Stop Company ID] varchar(10) null,[Next Stop Earliest Date] datetime, [Next Stop LatestDate] datetime,--10  
[Distance to Next stop] float null,CurrentDate datetime,[LastPingDate] datetime) --13  
  
  
insert into @Tractorpositions  
select trc_number 
,trc_status 
,'Point (-' + CONVERT(varchar(50),trc_gps_longitude/3600.0000) + ' ' + CONVERT(varchar(50),trc_gps_latitude/3600.0000) + ')' --2  
,trc_gps_latitude/3600.0000  
,-1*(trc_gps_longitude/3600.00)  
,trc_gps_date  
,trc_gps_desc --6  
,stp.stp_number  
,stp.cmp_id  
,stp.stp_schdtearliest    
,stp.stp_schdtlatest --10  
,dbo.tmw_airdistance_fn(trc_gps_latitude/3600.0000,trc_gps_longitude/3600.0000,  
case cmp_latseconds  
 when null then cty.cty_latitude  
 else cmp_latseconds/3600.00 end,  
case cmp_longseconds  
 when null then cty.cty_longitude  
 else cmp_longseconds/3600.00 end)  -- 11  

,getdate()
,ISNULL((select top 1 ckc_date from checkcall where ckc_tractor=trc.trc_number order by ckc_date desc),'1/1/1950')
 --13  
from tractorprofile trc with(nolock)  
left outer join legheader leg with(nolock) on  leg.lgh_tractor=trc.trc_number  
and leg.lgh_outstatus in ('PLN','STD') and   
leg.lgh_number=(select top 1 lgh_number   
  from legheader c with(nolock)   
  where c.lgh_outstatus in ('PLN','STD')  
  and c.lgh_tractor=trc.trc_number  
  order by c.lgh_startdate desc)  
left outer join stops stp with(nolock) on stp.lgh_number=leg.lgh_number  
 and stp.stp_number=(select top 1 stp_number  
   from stops sc with(nolock)  
   where sc.lgh_number=leg.lgh_number  
   and stp_status<>'DNE' order by stp_mfh_sequence)  
left outer join company scmp with(nolock) on scmp.cmp_id=stp.cmp_id    
left outer join city cty with(nolock) on scmp.cmp_city=cty.cty_code  
where trc_status<>'OUT'  
and trc_number not in ('UNKNOWN','UNK','')  


  
  
select * from @TractorPositions  
   
   
GO
GRANT EXECUTE ON  [dbo].[SSRS_TractorPositions] TO [public]
GO
