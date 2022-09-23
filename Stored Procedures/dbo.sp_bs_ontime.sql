SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc  [dbo].[sp_bs_ontime] 

/*
Autor: Emilio Olvera Yanez
fecha_ 28 sept 2018

sp que agrega datos de los stops en cuanto a su ontime para poder realizar reporte de hoja de seguimiento.


exec sp_bs_ontime 

select * from tts_bs_ontime_detail

*/

as



--Limpieza de la tabla persistente para recibir los nuevos datos
delete tts_bs_ontime_detail
delete tts_bs_ontime


--Insersion de nuevos datos hacia la tabla persistente provenientes de la consulta de stops

insert into tts_bs_ontime_detail

select 
(Select ord_billto   from orderheader o where o.ord_hdrnumber = s.ord_hdrnumber) as Cliente,
(Select (select replace(name,'BAJIO','ABIERTO') from labelfile where labeldefinition = 'revtype3' and abbr = ord_revtype3) from orderheader o where o.ord_hdrnumber = s.ord_hdrnumber) as Proyecto,
(select cmp_name from company c where c.cmp_id= s.cmp_id ) as Locacion,

 (select  'http://maps.google.com/maps?z=12&t=k&q=loc:' +CAST((cmp_latseconds) / 3600.00 AS varchar)  + '+-' + CAST((cmp_longseconds)/ 3600.00 AS varchar) 			
 from company c where c.cmp_id= s.cmp_id ) as Longlat,

(select ste_updated_arrival from stops_eta se where se.stp_number = s.stp_number) as ETA, 

case 
when s.stp_status = 'OPN' and  datediff(minute, dateadd(minute,30,stp_schdtearliest), (select ste_updated_arrival from stops_eta se where se.stp_number = s.stp_number)) > 60              then  'LATE'
when s.stp_status = 'OPN' and  datediff(minute, dateadd(minute,30,stp_schdtearliest), (select ste_updated_arrival from stops_eta se where se.stp_number = s.stp_number)) between 30 and 60 then 'RISK'
when s.stp_status = 'OPN' and  datediff(minute, dateadd(minute,30,stp_schdtearliest), (select ste_updated_arrival from stops_eta se where se.stp_number = s.stp_number)) < 30              then 'ONTIME'

when s.stp_status = 'DNE' and datediff(minute, dateadd(minute,30,stp_schdtearliest), stp_arrivaldate) <= 0   then 'CMPONTIME'
when s.stp_status = 'DNE' and datediff(minute, dateadd(minute,30,stp_schdtearliest), stp_arrivaldate) >  0   then 'CMPLATE'
 end as Estatus, 
 datediff(minute, (stp_schdtearliest), (select ste_updated_arrival from stops_eta se where se.stp_number = s.stp_number))  as dif,
stp_status,
stp_arrivaldate,
stp_schdtearliest,
case when  s.stp_status = 'DNE' then 'HOY'  when datediff(day,getdate(),stp_schdtearliest) <= 0 then 'HOY'  else '>=+1' end as fecha,
ord_hdrnumber,
stp_number,
cast(stp_sequence as varchar(20)) as secuencia,
(select lgh_tractor from legheader (nolock) where lgh_number = s.lgh_number) as tractor,
mov_number,
replace(isnull((select name from labelfile where labeldefinition = 'teamleader' and abbr = (select mpp_teamleader from manpowerprofile where mpp_id = ((select lgh_driver1 from legheader (nolock) where lgh_number = s.lgh_number)))),'UNKNOWN'),'','UNKNOWN') as lider,
(select lgh_driver1 from legheader (nolock) where lgh_number = s.lgh_number) as operador,
(select lgh_primary_trailer from legheader (nolock) where lgh_number = s.lgh_number) as trailer,
(Select ord_refnum   from orderheader o where o.ord_hdrnumber = s.ord_hdrnumber) as Rerefencia,
case when (select cmp_latseconds from company c where c.cmp_id= s.cmp_id) is null then 'NO LAT-LONG' 
	 when (select cmp_latseconds from company c where c.cmp_id= s.cmp_id) < 1     then 'NO LAT-LONG' 
	 when s.stp_number not in (select stp_number from stops_eta (nolock))         then 'OFFTIME CACL'
	 else 'OK'
end as causanocalc

FROM stops s
where
datediff(day,s.stp_schdtearliest,getdate()) <= 2
and
stp_status not in ('NON')
and s.ord_hdrnumber <> 0 

--eliminacion de stops de los cuales no tenemos un eta calculado.
--delete tts_bs_ontime_detail where ( (StopStatus <> 'DNE') \
--and stops not in (select stp_number from stops_eta))


--eliminar stops completados que no son del dia
delete tts_bs_ontime_detail where StopStatus =  'DNE' and datediff(day,arrival,getdate()) <> 0  

--marcar stops que se no se pudieron calcular.
update tts_bs_ontime_detail set status = 'NOCAL' where status is null
update tts_bs_ontime_detail set secuencia = secuencia +'/' + casT((select cast(count(*) as varchar(20)) from stops where stops.ord_hdrnumber = orden) as varchar(20))


--Insertamos en la tabla variable creada el producto de la consulta 
insert into tts_bs_ontime


select
o.cliente,
o.proyecto,
o.lider,
----totales del dia-----------------
Eventos = count(*),
CMPOntime  = (select count(    *   ) from tts_bs_ontime_detail A where                             A.Status  = 'CMPONTIME' and (O.Proyecto = A.Proyecto) and (O.Lider = A.Lider) and (O.cliente = A.cliente)),
CMPLate    = (select count(    *   ) from tts_bs_ontime_detail A where                             A.Status  = 'CMPLATE'   and (O.Proyecto = A.Proyecto) and (O.Lider = A.Lider) and (O.cliente = A.cliente)),
----al dia de hoy-------------------
ontimeh    = (select count(    *   ) from tts_bs_ontime_detail A where A.fecha = 'Hoy'         and A.Status  = 'ONTIME'    and (O.Proyecto = A.Proyecto) and (O.Lider = A.Lider) and (O.cliente = A.cliente)),
riskh      = (select count(    *   ) from tts_bs_ontime_detail A where A.fecha = 'Hoy'         and A.Status  = 'RISK'      and (O.Proyecto = A.Proyecto) and (O.Lider = A.Lider) and (O.cliente = A.cliente)),
lateh      = (select count(    *   ) from tts_bs_ontime_detail A where A.fecha = 'Hoy'         and A.Status  = 'LATE'      and (O.Proyecto = A.Proyecto) and (O.Lider = A.Lider) and (O.cliente = A.cliente)),
nocalch    = (select count(    *   ) from tts_bs_ontime_detail A where A.fecha = 'Hoy'         and A.Status  = 'NOCAL'     and (O.Proyecto = A.Proyecto) and (O.Lider = A.Lider) and (O.cliente = A.cliente)),
----al dia de hoy + 1 ---------------
[ontime>1] = (select count(    *   ) from tts_bs_ontime_detail A where A.fecha = '>=+1'        and A.Status  = 'ONTIME'    and (O.Proyecto = A.Proyecto) and (O.Lider = A.Lider) and (O.cliente = A.cliente)),
[risk>1  ] = (select count(    *   ) from tts_bs_ontime_detail A where A.fecha = '>=+1'        and A.Status  = 'RISK'      and (O.Proyecto = A.Proyecto) and (O.Lider = A.Lider) and (O.cliente = A.cliente)),
[late>1  ] = (select count(    *   ) from tts_bs_ontime_detail A where A.fecha  ='>=+1'        and A.Status  = 'LATE'      and (O.Proyecto = A.Proyecto) and (O.Lider = A.Lider) and (O.cliente = A.cliente)),
[nocal>1 ] = (select count(    *   ) from tts_bs_ontime_detail A where A.fecha = '>=+1'        and A.Status  = 'NOCAL'     and (O.Proyecto = A.Proyecto) and (O.Lider = A.Lider) and (O.cliente = A.cliente))
 
from tts_bs_ontime_detail O
group by o.cliente,o.proyecto, o.lider





GO
