SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc [dbo].[sp_kmsrutaquadded]
(@fecha varchar(8))
as



--declaramos tablas temporales

declare @deta table (rutad varchar(100), kmstotalesdiad int, viajesdiad int, kmstotalesmesd int, viajesmesd int, fecha datetime)

declare @acum table (ruta varchar(100), kmstotalesdia int, viajesdia int, kmstotalesmes int, viajesmes int)


---ruta, kms y viajes del mes.



insert into @deta

select 

Rutad = isnull((select cty_nmstct from company where company.cmp_id = (select max(cmp_id) from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))),'') + ' - ' + 
(select cty_nmstct from company where company.cmp_id  = stops.cmp_id)
,0
,0
,kmtotalesmesd = [dbo].[fnc_MilesBetweenCityCodes]( isnull((select cmp_city from company where company.cmp_id = (select max(cmp_id) from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))),''),
(select cmp_city from company where company.cmp_id  = stops.cmp_id))
,viajesmesd =  (stp_number)
,fecha = stp_arrivaldate 
 from stops
where 
stops.ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_billto = 'QUAD' and ord_status in ('STD','CMP'))
and stops.stp_event in (select abbr from eventcodetable where ect_billable = 'Y')
and ord_hdrnumber <> '0'
and isnull((select cty_nmstct from company where company.cmp_id = (select max(cmp_id) from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))),'') <>
(select cty_nmstct from company where company.cmp_id  = stops.cmp_id)
and cast(month(stp_arrivaldate ) as varchar) +'-'+cast(year(stp_arrivaldate ) as varchar) = @fecha
and (select cty_nmstct from company where company.cmp_id = (select max(cmp_id) from stops a with (nolock) 
where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))) is not null
order by ord_hdrnumber,stp_mfh_sequence


--agrupamos los datos de la tabla temporal de los detalles para resumirlos ya que no se puede hacer group by por consultas anidadas

insert into @acum

select 
Rutad,
0,
0, 
sum(kmstotalesmesd),
count(viajesmesd)
from @deta
group by Rutad


---kms  del dia por ruta.
update @acum 
set kmstotalesdia = 
(
select 
isnull((sum(kmstotalesmesd)),0)
from @deta 
where 
datediff(dd,fecha,getdate()) = 0 
and rutad = ruta
)


--viajes del dia por ruta

update @acum 
set viajesdia = 
(
select 
isnull((count(viajesmesd)),0)
from @deta 
where 
datediff(dd,fecha,getdate()) = 0 
and rutad = ruta
)


----------------------------------------------------------TOTALES---------------------------------------------------------------------------------------------------------------------------------------------------------

insert into @acum 

select 
'**TOTALES***',
0,
0, 
sum(kmstotalesmesd),
count(viajesmesd)
from @deta


---kms  del dia totales.

update @acum 
set kmstotalesdia = 
(
select 
isnull((sum(kmstotalesmesd)),0)
from @deta 
where 
datediff(dd,fecha,getdate()) = 0 
)
where ruta  ='**TOTALES***'

--viajes del dia totales

update @acum 
set viajesdia = 
(
select 
isnull((count(viajesmesd)),0)
from @deta 
where 
datediff(dd,fecha,getdate()) = 0
)
where ruta  ='**TOTALES***'




-------------------------------------------------------------Despliegue total del reporte.--------------------------------------------------------------------------------------------------------------------------------

select * from @acum
GO
