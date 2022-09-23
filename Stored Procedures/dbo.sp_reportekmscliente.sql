SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec [sp_reportekmscliente] '7-2015','despachognc@tdr.com.mx','W','R'
--exec [sp_reportekmscliente] '8-2015','despachognc@tdr.com.mx','A','R'
--exec [sp_reportekmscliente] '7-2014','despacholiverpool@tdr.com.mx','A','R'

CREATE proc [dbo].[sp_reportekmscliente]
(@fecha varchar(8), @billto varchar(100),@modo varchar(1),@vista varchar(1))
as




--declaramos tablas temporales

declare @deta table (Orden varchar(20) ,tractord varchar(100),fecha datetime, rutad varchar(200), kmstotalessemd int, viajessemd int, kmstotalesmesd int, viajesmesd int )

declare @acum table (ruta varchar(200), tractor varchar(100), kmstotalessem int, viajessem int, kmstotalesmes int, viajesmes int)

declare @cliente table (cliente varchar(100))



if (@billto <> 'GNC' and  @fecha <> '7-2015' )  
begin
	insert into @cliente 
			  select cmp_id from ESTATUSERCOMPANIES  where login = @billto
					and cmp_id in (select cmp_id from company where cmp_billto = 'Y')
end        

---ruta, kms y viajes del mes desglozados por orden-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------.


insert into @deta

select 
 Orden = ord_hdrnumber
 ,Tractord = ( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number)
 ,fecha = stp_arrivaldate 
 ,Ruta = isnull((select cty_nmstct from company where company.cmp_id = (select max(cmp_id) from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))),'') + ' - ' + 
 (select cty_nmstct from company where company.cmp_id  = stops.cmp_id)
 ,0
 ,0
 ,kmtotalesmesd = [dbo].[fnc_MilesBetweenCityCodes]( isnull((select cmp_city from company where company.cmp_id = (select max(cmp_id) from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))),''),
 (select cmp_city from company where company.cmp_id  = stops.cmp_id))
 ,viajesmesd =  (stp_number)

 from stops
where 
stops.ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_billto in (select * from @cliente) and ord_status in ('STD','CMP'))
and stops.stp_event in (select abbr from eventcodetable where ect_billable = 'Y')
and ord_hdrnumber <> '0'
and isnull((select cty_nmstct from company where company.cmp_id = (select max(cmp_id) from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) 
and (a.ord_hdrnumber = stops.ord_hdrnumber))),'') <>
(select cty_nmstct from company where company.cmp_id  = stops.cmp_id)
and cast(month(stp_arrivaldate ) as varchar) +'-'+cast(year(stp_arrivaldate ) as varchar) = @fecha
and (select cty_nmstct from company where company.cmp_id = (select max(cmp_id) from stops a with (nolock) 
where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))) is not null
order by ord_hdrnumber,stp_mfh_sequence





--vista desde el recurso Tractor--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if @vista = 'T'
 BEGIN

	--agrupamos los datos de la tabla temporal de los detalles para resumirlos ya que no se puede hacer group by por consultas anidadas

	insert into @acum

	select 
    'Trc',
	Tractord,
	0,
	0, 
	sum(kmstotalesmesd),
	count(viajesmesd)
	from @deta
	group by Tractord


	---kms  de ult semana por ruta
	update @acum 
	set kmstotalessem = 
	(
	select 
	isnull((sum(kmstotalesmesd)),0)
	from @deta 
	where 
	datepart(week, getdate()+1) = datepart(week,fecha+1)
	--datediff(dd,getdate(),fecha) <= 7 
	and tractord = tractor
	)



	--viajes de los ult semana por ruta

	update @acum 
	set viajessem = 
	(
	select 
	isnull((count(viajesmesd)),0)
	from @deta 
	where 
	datepart(week, getdate()+1) = datepart(week,fecha+1)
	--datediff(dd,getdate(),fecha) <= 7 
	and tractord = tractor
	)


 END 


--vista desde el recurso de la ruta--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if @vista = 'R'
 BEGIN

	--agrupamos los datos de la tabla temporal de los detalles para resumirlos ya que no se puede hacer group by por consultas anidadas

	insert into @acum

	select 
	Rutad,
    'Rut',
	0,
	0, 
	sum(kmstotalesmesd),
	count(viajesmesd)
	from @deta
	group by Rutad


	---kms  de ult semana por ruta.
	update @acum 
	set kmstotalessem = 
	(
	select 
	isnull((sum(kmstotalesmesd)),0)
	from @deta 
	where 
	datepart(week, getdate()+1) = datepart(week,fecha+1)
	--datediff(dd,fecha,getdate()) <= 7  
	and rutad = ruta
	)

	--viajes de ult semana dias por ruta

	update @acum 
	set viajessem = 
	(
	select 
	isnull((count(viajesmesd)),0)
	from @deta 
    where 
	datepart(week, getdate()+1) = datepart(week,fecha+1)
	--datediff(dd,getdate(),fecha) <= 7 
	and rutad = ruta
	)



 END 



----------------------------------------------------------TOTALES---------------------------------------------------------------------------------------------------------------------------------------------------------

insert into @acum 

select 
'**TOTALES***',
'**TOTALES***',
0,
0, 
sum(kmstotalesmesd),
count(viajesmesd)
from @deta


---kms  del dia totales.

update @acum 
set kmstotalessem = 
(
select 
isnull((sum(kmstotalesmesd)),0)
from @deta 
where 
datepart(week, getdate()+1) = datepart(week,fecha+1)
--datediff(dd,getdate(),fecha) <= 7
)
where tractor  ='**TOTALES***'

--viajes del dia totales

update @acum 
set viajessem = 
(
select 
isnull((count(viajesmesd)),0)
from @deta 
where 
datepart(week, getdate()+1) = datepart(week,fecha+1)
--datediff(dd,getdate(),fecha) <= 7
)
where tractor  ='**TOTALES***'







-------------------------------------------------------------Despliegue total del reporte.--------------------------------------------------------------------------------------------------------------------------------


 

--MODO PARA MOSTRAR EL ACUMULADO DEL REPORTE


if @modo = 'A' and @vista = 'R'
 BEGIN
 
  select ruta,(kmstotalessem) as KmsTotalesSemana, viajessem as ViajesSemana, kmstotalesmes,viajesmes from @acum
 
 END


if @modo = 'A' and @vista = 'T'
 BEGIN
 
  select tractor,(kmstotalessem) as KmsTotalesSemana, viajessem as ViajesSemana,   kmstotalesmes,viajesmes from @acum
 
 END


--MODO PARA MOSTRAR EL DETALLE DEL REPORTE

if @modo = 'D'
 BEGIN

	select  
      Orden
      ,Tractor = tractord
      ,Fecha = fecha
      ,Ruta = Rutad
      ,Kms =  kmstotalesmesd
    from @deta

 END



 --MODO PARA MOSTRAR EL DETALLE POR TRACTO DEL REPORTE

if @modo = 'W'
 BEGIN
 	select  

      Tractor = t.tractord
      ,semana1 =  (select count(Orden) from @deta d where  t.tractord = d.tractord and t.rutad = d.rutad and DATEPART(week, fecha+1) - DATEPART(week, DATEADD(dd, - DAY(fecha+1) + 1, fecha+1)) = 1)
	  ,semana2 =  (select count(Orden) from @deta d where  t.tractord = d.tractord and t.rutad = d.rutad and DATEPART(week, fecha+1) - DATEPART(week, DATEADD(dd, - DAY(fecha+1) + 1, fecha+1)) = 2)
	  ,semana3 =  (select count(Orden) from @deta d where  t.tractord = d.tractord and t.rutad = d.rutad and DATEPART(week, fecha+1) - DATEPART(week, DATEADD(dd, - DAY(fecha+1) + 1, fecha+1)) = 3)
	  ,semana4 =  (select count(Orden) from @deta d where  t.tractord = d.tractord and t.rutad = d.rutad and DATEPART(week, fecha+1) - DATEPART(week, DATEADD(dd, - DAY(fecha+1) + 1, fecha+1)) = 4)
      ,Ruta = t.Rutad
      
    from @deta t

	group by t.tractord,t.Rutad
 END


GO
