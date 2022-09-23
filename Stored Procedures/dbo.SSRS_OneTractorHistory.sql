SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[SSRS_OneTractorHistory]
(@trc_number varchar(8),
@DateStart datetime,
@DateEnd datetime,
@MinimumDistanceBetweenPings float,
@ShowAllCheckcalls_YN char(1)

)
						
AS

SET NOCOUNT ON

/**
 *
 * NAME:
 * dbo.SSRS_OneTractorHistory
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * One truck checkcalls. Assumes negative Longitude (Western hemisphere)
 Setting the @MinimumDistanceBetweenLegs eliminates intermediary checkcalls less than that distance, to make the map less cluttered.
 The Setting @ShowAllCheckcalls_YN can be set to Y to show checkcalls even if they have the exact position as another checkcall. If set to N, the 
 system only keeps the first and last checkcalls for that item
 *
**************************************************************************

Sample call

exec [SSRS_OneTractorHistory] @trc_number='BOB',@DateStart='8/1/2013',@DateEnd='9/1/2013',@MinimumDistanceBetweenPings=1


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 *Positional info about a truck and checkcalls
 *
 * PARAMETERS:
@trc_number - the tractor number
@DateStart 
@DateEnd 
@MinimumDistanceBetweenPings - Remove checkcalls closer than this to the prior checkcall
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR created procedure
 **/

Declare @TractorPositions table ([Tractor] varchar(8) null,[Position] geography null, --2
[Latitude] float null,[Longitude] float null,[GPS Date] datetime null,[Description] varchar(255) null,MinDate datetime null,MaxDate datetime null,PosCount int,
[Distance from Last Ping] float null,[Minutes Since Last Ping] int null,[Approx Speed] float null)



insert into @Tractorpositions
select ckc.ckc_tractor
,'Point (-' + CONVERT(varchar(50),ckc.ckc_longseconds/3600.0000) + ' ' + CONVERT(varchar(50),ckc.ckc_latseconds/3600.0000) + ')' --2
,ckc.ckc_latseconds/3600.0000
,-1*(ckc.ckc_longseconds/3600.00)
,ckc.ckc_date
,ckc.ckc_comment --6
,null,null,null,null,null,null
from checkcall ckc with(nolock)
where ckc.ckc_tractor = @trc_number
and ckc.ckc_date >=@DateStart and ckc.ckc_date < @DateEnd
AND ckc.ckc_latseconds is not null 
and ckc.ckc_longseconds is not null
ORDER BY ckc.ckc_date
/*
update @TractorPositions SET [NextStopPosition] = ('Point (-' + CONVERT(varchar(50),[NextStopLongitude]) + ' ' + CONVERT(varchar(50),[NextStopLatitude]) + ')' )
where [NextStopLatitude] is not null and [NextStopLongitude] is not null
*/
select [Tractor] as trc,[Latitude] as lat,[Longitude] as long,[GPS Date] as gpsd 
into #toplist
from @TractorPositions

update @TractorPositions set MinDate = (Select top 1 gpsd from #toplist where #toplist.lat=Latitude
	and #toplist.long=Longitude order by gpsd),
	 MaxDate = (Select top 1 gpsd from #toplist where #toplist.lat=Latitude
	and #toplist.long=Longitude order by gpsd desc),
		 PosCount = (Select count(gpsd) from #toplist where #toplist.lat=Latitude
	and #toplist.long=Longitude)
	

-- Delete Dupes
If @ShowAllCheckcalls_YN = 'N'
BEGIN
DELETE @TractorPositions where PosCount>1 and [GPS Date]<>MinDate and [GPS Date]<>MaxDate and Description not like '%PACOS%'
end

update @TractorPositions set [Distance from Last Ping] = dbo.tmw_airdistance_fn(Latitude,Longitude,(select top 1 lat from #toplist where gpsd<[GPS Date] order by gpsd desc),
	(select top 1 long from #toplist where gpsd<[GPS Date] order by gpsd desc)),
	[Minutes Since Last Ping]=DateDiff(mi,(select top 1 gpsd from #toplist where gpsd<[GPS Date] order by gpsd desc),[GPS Date])
	
update @TractorPositions set [Approx Speed]=	[Distance from Last Ping]/([Minutes Since Last Ping]/60.00)
where [Minutes Since Last Ping]>0 and [Minutes Since Last Ping] is not null and [Distance from Last Ping] is not null and [Distance from Last Ping] >0

If @ShowAllCheckcalls_YN = 'N'
BEGIN
	select * from @TractorPositions 
	where [Distance from Last Ping]>=@MinimumDistanceBetweenPings
END	
ELSE
BEGIN
	select * from @TractorPositions 
END
	


GO
GRANT EXECUTE ON  [dbo].[SSRS_OneTractorHistory] TO [public]
GO
