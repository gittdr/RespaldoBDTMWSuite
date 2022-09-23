SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[sp_dieselmargin]

as




select
trc_number,
(select (select name from labelfile where labeldefinition = 'fleet' and abbr = trc_fleet) from tractorprofile tra where tra.trc_number = dieselmargin.trc_number) as flota,
costodiesel,
ingreso,
case when ingreso = 0 and costodiesel  > 0  then 100  when ingreso = 0 and costodiesel = 0 then 0 else  100*(costodiesel/ingreso) end as margen,
(select count(*) from legheader where lgh_tractor = trc_number and lgh_outstatus in  ('STD') and datediff(dd,lgh_startdate,getdate()) <= 7 ) as iniciadas,
(select count(*) from legheader where lgh_tractor = trc_number and lgh_outstatus in  ('PLN') and datediff(dd,lgh_startdate,getdate()) <= 7 ) as planeadas,
(select count(*) from legheader where lgh_tractor = trc_number and lgh_outstatus in  ('CMP') and datediff(dd,lgh_startdate,getdate()) <= 7 ) as completadas,
(select count(*) from legheader where lgh_tractor = trc_number and lgh_outstatus in  ('CMP','STD') and datediff(dd,lgh_startdate,getdate()) <= 7 ) as ordenes,
isnull((select sum(lgh_miles) from legheader where lgh_tractor = trc_number and  lgh_outstatus in  ('CMP','STD') and datediff(dd,lgh_startdate,getdate()) <= 7 ),0) as kmsordenes,
round(isnull((select sum(cast(distancia_recorrida as float)) from fuel.[dbo].[intralix_getperformance1day] where datediff(dd,fecha_final,getdate()) <=7 and economico = trc_number),0),0) as kmsodo,

(round(case when isnull((select sum(ord_totalmiles) from orderheader where ord_tractor = trc_number and ord_status = 'CMP' and datediff(dd,ord_completiondate,getdate()) <= 7 ),0)  = 0 then 0 else
(isnull((select sum(ord_totalmiles) from orderheader where ord_tractor = trc_number and ord_status = 'CMP' and datediff(dd,ord_completiondate,getdate()) <= 7 ),0) 
-
round(isnull((select sum(cast(distancia_recorrida as float)) from fuel.[dbo].[intralix_getperformance1day] where datediff(dd,fecha_final,getdate()) <=7 and economico = trc_number),0),0)   
)
/
isnull((select sum(ord_totalmiles) from orderheader where ord_tractor = trc_number and ord_status = 'CMP' and datediff(dd,ord_completiondate,getdate()) <= 7 ),0)end,2) * -1)*100 as pctfueraruta,

(select max(exp_description) from expiration where exp_id = trc_number and datediff(dd,exp_compldate,getdate()) = 12) as expi
from
(
select 
trc_number,
sum(fp_amount) as costodiesel,
isnull((select sum(ord_totalcharge) from orderheader where ord_tractor = trc_number and ord_status = 'CMP'
 and datediff(dd,ord_completiondate,getdate()) <= 7  ),0) as ingreso
 from fuelpurchased
 where datediff(dd,fp_Date,getdate()) <= 7
 group by trc_number
 ) as dieselmargin
order by margen desc
GO
