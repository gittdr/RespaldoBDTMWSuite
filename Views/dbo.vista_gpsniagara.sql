SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [dbo].[vista_gpsniagara] as 


select 

'TDR' as Userr,
'niagaratdr' as Password,
'TDR'+trc_number as DeviceID,
 CONVERT(date,   cast( DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), trc_gps_date) as datetime),101) as sDate,
convert(char(5), cast( DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), trc_gps_date) as datetime),108) as sTime,

cast(round(cast(cast(trc_gps_latitude as float)/3600 as float),2) as decimal(5,2)) as Latitude,
cast(round(cast(cast(trc_gps_longitude as float)/3600 as float),2) * -1 as decimal(5,2)) as Longitud,
'true' as IgnitionStatus,
isnull(trc_gps_speed,0) as Speed,
0 as Course,
'NA' as TempFrozen,
'NA' as TempCold,
110 as EventNumber

from tractorprofile
where trc_status <> 'OUT' and trc_number <> 'UNKNOWN' and trc_number in
(select lgh_tractor from legheader where lgh_outstatus = 'STD'
and ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_billto in ('NIAGARA','COPAMEX')) )

union

---cajas

select 

'TDR' as Userr,
'niagaratdr' as Password,
'TDR'+trl_number as DeviceID,
(CONVERT(date,   cast( DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), isnull(trl_gps_date,getdate())) as datetime),101)) as sDate,
(convert(char(5), cast( DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), isnull(trl_gps_date,getdate())) as datetime),108))as sTime,

isnull(cast(round(cast(cast(trl_gps_latitude as float)/3600 as float),2) as decimal(5,2)),0) as Latitude,
isnull(cast(round(cast(cast(trl_gps_longitude as float)/3600 as float),2) * -1 as decimal(5,2)),0) as Longitud,
'true' as IgnitionStatus,
isnull(trl_gps_speed,0) as Speed,
0 as Course,
'NA' as TempFrozen,
'NA' as TempCold,
110 as EventNumber

from trailerprofile
where trl_status <> 'OUT' and trl_number <> 'UNKNOWN' and trl_number in
(select lgh_primary_trailer from legheader where lgh_outstatus = 'STD'
and ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_billto in ('NIAGARA','COPAMEX')) )





GO
