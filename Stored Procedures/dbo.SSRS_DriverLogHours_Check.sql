SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE procedure [dbo].[SSRS_DriverLogHours_Check]
(
@DateStart datetime,
@DateEnd datetime,
@ShowInactiveDrivers_YN char(1) = 'N',
@OnlyShowDayswithProblems char(1) = 'N',
@DriverType1 varchar(max)='',
@DriverType2 varchar(max)='',
@DriverType3 varchar(max)='',
@DriverType4 varchar(max)=''

)
as
/*
SSRS_DriverLogHours_Check
JR
Created 6/4/2015

Sample call
exec [SSRS_DriverLogHours_Check] '1/1/2012','12/31/2012','N','N','','','',''


Purpose: Report on potential problems with driver log hours, including dates they may be missing
Need to check for missing hours and/hour hours not logged on days when they had activity (may or may not be a problem).
*/
WITH CTE_DATES AS
(
SELECT
   @DateStart DateValue UNION ALL SELECT
   DateValue + 1
FROM CTE_DATES
WHERE DateValue + 1 <= @DateEnd)
 

   SELECT
	m.mpp_id,
	m.mpp_lastfirst,
   CAST(DateValue AS datetime) as LogDate
      
     into #DriverDates
   FROM CTE_DATES
   join manpowerprofile m on 1=1
      where m.mpp_status<>'OUT'
      and m.mpp_id not in ('','UNKNOWN','UNK')
      and (CHARINDEX(m.mpp_type1,@DriverType1)>0 or @DriverType1='')
      and (CHARINDEX(m.mpp_type2,@DriverType2)>0 or @DriverType2='')
      and (CHARINDEX(m.mpp_type3,@DriverType3)>0 or @DriverType3='')
      and (CHARINDEX(m.mpp_type4,@DriverType4)>0 or @DriverType4='')
      
         ORDER BY m.mpp_lastfirst,LogDate
   OPTION (MAXRECURSION 0)


   select d.*,
   --ISNULL(
   --(select count(g.lgh_number)
   --from legheader g
   --where (g.lgh_driver1=d.mpp_id
   --or g.lgh_driver2=d.mpp_id)
   --and
   --g.lgh_enddate>=LogDate
   --and g.lgh_startdate<Dateadd(day,1,LogDate)
   --and g.lgh_outstatus IN ('CMP','STD')
   --),0) as [Trips During],
   SPACE(255) as [Hours Issues],
   l.log_date,
   l.on_duty_hrs,
   l.off_duty_hrs,
   l.driving_hrs,
   l.sleeper_berth_hrs
   into #Results
   from #DriverDates d
  left outer join log_driverlogs l on d.mpp_id = l.mpp_id
and l.log_date = LogDate
	ORDER BY mpp_lastfirst,LogDate

update #Results set [Hours Issues]=
case ISNULL(log_date,-1)
when -1 then 'No log received' 
else 'OK'
end


--update #Results set [Hours Issues]='No hours, and no trips found' where [Trips During]=0 and log_driverlog_ID is null

--update #Results set [Hours Issues]='No hours, but trips were found' where [Trips During]>0 and log_driverlog_ID is null

select * 
from #Results
where ([Hours Issues]<>'OK' and @OnlyShowDayswithProblems='Y')
or 
@OnlyShowDayswithProblems='N'

GO
GRANT EXECUTE ON  [dbo].[SSRS_DriverLogHours_Check] TO [public]
GO
