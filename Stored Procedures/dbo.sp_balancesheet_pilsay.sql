SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [dbo].[sp_balancesheet_pilsay] (@modo varchar(5) = NULL)

as 
/**
--AUTOR - Emilio Olvera Yáñez
--FECHA CREACION 6/5/2013 9:53 am
--FECHA ULT MOD 2/8/2018 10:20 am
--VERSION 3.0
--DESCRIPCION- SP que mediante consultas genera matriz de balance de ordenes.

prueba ejecución del sp 

exec sp_balancesheet
exec sp_balancesheet 'snap'

prueba para consultar lo insertado en la tabla pesistente
 select * from tts_matrix_dispo order by region desc
select * from tts_matrix_dispo_detail where region = 'villahermosa' and fecha = 'hoy'


***/

--borramos el contenido de las tablas persistentes para estar listas y recibir nuevos datos.


delete tts_bs_dispo_detail_pilsay
delete tts_bs_dispo_pilsay

--Creamos variable tabla para recibir los datos de los sps del rawdata
CREATE TABLE #rawdata 
(Cliente varchar(max), Origen varchar(max), Destino varchar(max), Remolque varchar(100), 
Proyecto varchar(max), Region varchar(max),Tractor varchar(100), Operador varchar(max), 
 Status varchar(100), LghStatus varchar(100),Fecha datetime,CiudadOrigen varchar(max),
 CiudadDestino varchar(max), Orden varchar(100), Leg varchar(100), Lider varchar(max))

 

--INSERTAMOS ORDENES EN AVL DESDE OPTICA ORIGEN-----------------------------------------------------------------------------------------------------------
--OUTS----------------------------------------------------------------------------------------------------------------------------------------------------
insert into #rawdata

/*
exec dbo.outbound_view_matrix_outs   '', '',  '',  '',  '',  '',  '', '',  'UNK','UNK', 'UNK',  'UNK',  0,  0,  0, 'AVL,AVH,PND', 'ALL', 'ord',  '',  '',
  '',  'UNK',  'UNK', 'UNK',  'UNK', 0,  'N',  0,  9999, '',  '',   '',  '',  '', NULL,  '',  '','','', '','', '','', NULL,  '', '', 'UNK', 'UNK', 
{ts '1900-01-01 00:00:00.000'},0,  '','FLAT',  'BRKFUL', 'BRKACC', 0,  0,  0,  '',  ''
*/

SELECT
   
	Cliente = (select ord_billto from orderheader where ord_hdrnumber = legheader.ord_hdrnumber),	
	Origen =  cmp_id_start,
	Destino = cmp_id_end,
	Remolque = isnull(lgh_primary_trailer,''),
    Proyecto = replace((SELECT name FROM labelfile WHERE  labeldefinition = 'RevType3' and abbr = (select ord_revtype3 from orderheader where orderheader.ord_hdrnumber = legheader.ord_hdrnumber)),'BAJIO','ABIERTO'),
    	---Se basa en la region de ORIGEN--------------------------------------------------------------------------------------------------------------------
	Region =  isnull((select rgh_name from regionheader where rgh_id =  legheader.lgh_startregion1),'UNKNOWN'),
    Tractor = lgh_driver1,
	Operador = cast( lgh_number as varchar(20)),
	Status = 'OUT',
	LghStatus = lgh_outstatus,
	---Se basa en la fecha de inicio de leg----------------------------------------------------------------------------------------------------------------------
	Fecha= lgh_schdtearliest, --lgh_startdate,
	---Se basa en la ciudad de ORIGEN------------------------------------------------------------------------------------------------------------------------
	CiudadOrigen = lgh_startcty_nmstct,
	CiudadDestino = lgh_endcty_nmstct,
	Orden = legheader.ord_hdrnumber,
	Leg = legheader.lgh_number,
	Lider =  replace(isnull((select name from labelfile where labeldefinition = 'teamleader' and abbr = (select mpp_teamleader from manpowerprofile where mpp_id = lgh_driver1)),'UNKNOWN'),'','UNKNOWN')
	from legheader (nolock)
	where lgh_outstatus in ('AVL','AVH','PND')
	and lgh_miles not between 0 and 100





--INSERTAMOS ORDENES EN AVL DESDE OPTICA DESTINO------------------------------------------------------------------------------------------------------------
--INS-------------------------------------------------------------------------------------------------------------------------------------------------------

insert into #rawdata

/*
exec dbo.outbound_view_matrix_ins   '', '',  '',  '',  '',  '',  '', '',  'UNK','UNK', 'UNK',  'UNK',  0,  0,  0, 'AVL,AVH,PND', 'ALL', 'ord',  '',  '',
  '',  'UNK',  'UNK', 'UNK',  'UNK', 0,  'N',  0,  9999, '',  '',   '',  '',  '', NULL,  '',  '','','', '','', '','', NULL,  '', '', 'UNK', 'UNK', 
{ts '1900-01-01 00:00:00.000'},0,  '','FLAT',  'BRKFUL', 'BRKACC', 0,  0,  0,  '',  ''
*/

SELECT
   
	Cliente = (select ord_billto from orderheader where ord_hdrnumber = legheader.ord_hdrnumber),	
	Origen =  cmp_id_start,
	Destino = cmp_id_end,
	Remolque = isnull(lgh_primary_trailer,''),
    Proyecto = replace((SELECT name FROM labelfile WHERE  labeldefinition = 'RevType3' and abbr = (select ord_revtype3 from orderheader where orderheader.ord_hdrnumber = legheader.ord_hdrnumber)),'BAJIO','ABIERTO'),
    	---Se basa en la region de DESTINO--------------------------------------------------------------------------------------------------------------------
	Region =  isnull((select rgh_name from regionheader where rgh_id =  legheader.lgh_endregion1),'UNKNOWN'),
    Tractor = lgh_driver1,
	Operador = lgh_number,
	Status = 'IN',
	LghStatus = lgh_outstatus,
	---Se basa en la fecha de fin de leg----------------------------------------------------------------------------------------------------------------------
	Fecha= isnull((select max(stp_schdtlatest) from stops where stops.lgh_number = legheader.lgh_number),'1900-12-31 23:59:00.000'), --lgh_enddate,
	---Se basa en la ciudad de DESTINO------------------------------------------------------------------------------------------------------------------------
    CiudadOrigen = lgh_startcty_nmstct,
	CiudadDestino = lgh_endcty_nmstct,
	Orden = legheader.ord_hdrnumber,
	Leg = legheader.lgh_number,
    Lider =  replace(isnull((select name from labelfile where labeldefinition = 'teamleader' and abbr = (select mpp_teamleader from manpowerprofile where mpp_id = lgh_driver1)),'UNKNOWN'),'','UNKNOWN')
	from legheader (nolock) 
	where lgh_outstatus in ('AVL','AVH','PND')
	and lgh_miles not between 0 and 100

	

--INSERTAMOS RECURSOS QUE ESTARAN DISPONIBLES PARA SER (PLANEADOS)-------------------------------------------------------------------------------------------

----INSERTAR LAS ORDENES EN CURSO--------------------


insert into #rawdata

	select Cliente,Origen,Destino,Remolque,Proyecto,REgion, Tractor,Operador,Status,leg_status,Fecha,CiudadOrigen,CiudadDestino,Orden,Leg,Lider from(

   select
	Cliente = (select ord_billto from orderheader where orderheader.ord_hdrnumber = legheader.ord_hdrnumber), 
	Origen =  cmp_id_start,
	Destino =    STUFF((SELECT ', ' + (stops.cmp_id)
          FROM stops 
          WHERE stops.lgh_number = legheader.lgh_number and stp_type = 'DRP'
          ORDER BY stp_sequence 
          FOR XML PATH('')), 1, 1, ''),
	Remolque = lgh_primary_trailer,
    Proyecto = replace((select name from labelfile where labeldefinition = 'Revtype3' and abbr= (select ord_revtype3 from orderheader where orderheader.ord_hdrnumber = legheader.ord_hdrnumber)),'BAJIO','ABIERTO'),
    --Region =  isnull((select rgh_name from regionheader where rgh_id = (select cty_region1 from city where cty_code = lgh_endcity )   ),'UNKNOWN'),
	Region = case when (select ord_billto from orderheader where orderheader.ord_hdrnumber = legheader.ord_hdrnumber) not in('PILGRIMS','SAYER')
							then isnull((select rgh_name from regionheader where rgh_id = (select cty_region1 from city where cty_code = lgh_endcity )   ),'UNKNOWN')
								else ( isnull((select rgh_name from regionheader where rgh_id = (Select (select cty_region1 from city where cty_code = stops.stp_city )   
										from stops
										WHERE stops.lgh_number = legheader.lgh_number and stp_type = 'DRP'
										and stops.stp_number = (select max(stps.stp_number) from stops stps where stps.lgh_number =   legheader.lgh_number and stp_type = 'DRP') 
										)
										),'UNKNOWN'))
									end,
    Tractor =  lgh_tractor,
	Operador = lgh_driver1,
	Status = 'STD',
	leg_status = lgh_outstatus,
	Fecha=  lgh_enddate,
	CiudadOrigen = lgh_startcty_nmstct,
	--CiudadDestino = lgh_endcty_nmstct,
	
	--cambiar con el case when y con ese mismo agregarlo a origen
	CiudadDestino = case when (select ord_billto from orderheader where orderheader.ord_hdrnumber = legheader.ord_hdrnumber)not in('PILGRIMS','SAYER')
							then lgh_endcty_nmstct
								else (select (select cty_nmstct from city where cty_code = stops.stp_city)
										from stops
										WHERE stops.lgh_number = legheader.lgh_number and stp_type = 'DRP'
										and stops.stp_number = (select max(stps.stp_number) from stops stps where stps.lgh_number =   legheader.lgh_number and stp_type = 'DRP') 
										)
									end,
	Orden = legheader.ord_hdrnumber,
	Leg = legheader.lgh_number,
	Lider =  replace(isnull((select name from labelfile where labeldefinition = 'teamleader' and abbr = (select mpp_teamleader from manpowerprofile where mpp_id = lgh_driver1)),'UNKNOWN'),'','UNKNOWN'),
	row_number() over(partition by legheader.lgh_driver1 order by lgh_enddate desc) as rn
	from legheader (nolock)
    where lgh_outstatus not in ('AVL','CAN','CMP') and lgh_driver1 <> 'UNKNOWN'
	and lgh_driver1 not in (select mpp_id from manpowerprofile (nolock) where mpp_type3 = 'PA')
	and lgh_driver1 not in (select mpp_id from manpowerprofile (nolock) where mpp_status = 'OUT')
	) as started
	where rn = 1



----INSERTAR RECURSOS DISPONIBLES (DRV)--------------------



insert into #rawdata


SELECT  


  	Cliente =  orderheader.ord_billto,
	--(select ord_billto from orderheader where ord_hdrnumber in (select max(ord_hdrnumber) from orderheader where ord_status ='CMP'
	--and ord_Driver1 = mpp_id)),
	
	Origen = legheader.cmp_id_start,
	
	-- (select cmp_id_start from legheader where lgh_number in (select max(lgh_number) from legheader where lgh_outstatus ='CMP'
	--and lgh_driver1 = mpp_id)),

	Destino =    STUFF((SELECT ', ' + (stops.cmp_id)
          FROM stops 
          WHERE stops.lgh_number = legheader.lgh_number and stp_type = 'DRP'
          ORDER BY stp_sequence 
          FOR XML PATH('')), 1, 1, ''),

	Remolque = mpp_pln_lgh, --(select max(lgh_number) from legheader where lgh_outstatus ='CMP' and lgh_driver1 = mpp_id),

    Proyecto = isnull((select replace(name,'BAJIO','ABIERTO') from labelfile where labeldefinition = 'revtype3' and abbr = orderheader.ord_revtype3),''), 
	Region = case when (select ord_billto from orderheader where orderheader.ord_hdrnumber = legheader.ord_hdrnumber) not in('PILGRIMS','SAYER')
							then isnull((select rgh_name from regionheader where rgh_id = (select cty_region1 from city where cty_code = lgh_endcity )   ),'UNKNOWN')
								else ( isnull((select rgh_name from regionheader where rgh_id = (Select (select cty_region1 from city where cty_code = stops.stp_city )   
										from stops
										WHERE stops.lgh_number = legheader.lgh_number and stp_type = 'DRP'
										and stops.stp_number = (select max(stps.stp_number) from stops stps where stps.lgh_number =   legheader.lgh_number and stp_type = 'DRP') 
										)
										),'UNKNOWN'))
									end,
    
	--Region = isnull((select rgh_name from regionheader where rgh_id =  (select cty_region1 from city  where cty_code = mpp_avl_city)),'UNKNOWN'),
    
	
	Tractor = mpp_tractornumber,
	Operador = mpp_id,
	Status = 'DSP' ,
	OrdStatus = mpp_status,

	Fecha =  mpp_avl_date,

    CiudadOrigen ='',
	--CiudadDestino = (select cty_name from city  where cty_code = mpp_avl_city),
	CiudadDestino = case when (select ord_billto from orderheader where orderheader.ord_hdrnumber = legheader.ord_hdrnumber) not in('PILGRIMS','SAYER')
							then lgh_endcty_nmstct
								else (select (select cty_nmstct from city where cty_code = stops.stp_city)
										from stops
										WHERE stops.lgh_number = legheader.lgh_number and stp_type = 'DRP'
										and stops.stp_number = (select max(stps.stp_number) from stops stps where stps.lgh_number =   legheader.lgh_number and stp_type = 'DRP') 
										)
									end,
	Orden = orderheader.ord_hdrnumber,
	Leg = legheader.lgh_number,
	Lider =(select name from labelfile where labeldefinition = 'teamleader' and abbr =  manpowerprofile.mpp_teamleader)

	from manpowerprofile (nolock)
	left join legheader (nolock) on legheader.lgh_number = manpowerprofile.mpp_pln_lgh
	left join orderheader (nolock) on legheader.ord_hdrnumber = orderheader.ord_hdrnumber
	where mpp_status in  ('AVL','DES','PER','VACT','FALTA','SICT','LIC') and mpp_next_legnumber is null
	and manpowerprofile.mpp_type3 <> 'PA' and mpp_status <> 'OUT'



--Insertamos la consulta de la tabla variable con el resultado final a nuestra tabla persistente
insert into tts_bs_dispo_detail_pilsay

select 
    Cliente, 
	Origen,
	Destino,
	Remolque,
	Proyecto = replace(Proyecto,'BAJIO','ABIERTO'), 
	Region = Region, 
	Tractor = replace(Tractor,'UNKNOWN',''),
	Operador,
	Status, 
	LghStatus,
	Fecha =
		  case  when (datediff(dd,getdate(),Fecha) <= 0 )  then 'Hoy'
		  when (datediff(dd,getdate(),Fecha) = 1 ) then '+1'
		  when (datediff(dd,getdate(),Fecha) = 2 ) then '+2'
		  when (datediff(dd,getdate(),Fecha) = 3 ) then '+3'
		  when (datediff(dd,getdate(),Fecha) = 4 ) then '+4' 
		  when (datediff(dd,getdate(),Fecha) > 4 ) then '>4'
		  end,
	Fechaf = Fecha,
	CiudadOrigen,
	CiudadDestino,
	Orden,
	Leg,
	Lider
from #rawdata



--Insertamos en la tabla variable creada el producto de la consulta 
insert into tts_bs_dispo_pilsay 

select
O.Region,
O.Proyecto,
----al dia de hoy-------------------
outh   = (select count(A.Fechaf) from tts_bs_dispo_detail_pilsay A where A.fecha = 'Hoy' and A.Status  = 'OUT' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
dsph   = (select count(    *   ) from tts_bs_dispo_detail_pilsay A where A.fecha = 'Hoy' and A.Status  = 'DSP' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
stdh   = (select count(    *   ) from tts_bs_dispo_detail_pilsay A where A.fecha = 'Hoy' and A.Status  = 'STD' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
inh    = (select count(A.Fechaf) from tts_bs_dispo_detail_pilsay A where A.fecha = 'Hoy' and A.Status  = 'IN'  and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
----al dia de hoy + 1 ---------------
out1   = (select count(A.Fechaf) from tts_bs_dispo_detail_pilsay A where A.fecha = '+1'  and A.Status  = 'OUT' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
dsp1   = (select count(    *   ) from tts_bs_dispo_detail_pilsay A where A.fecha = '+1'  and A.Status  = 'DSP' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
std1   = (select count(    *   ) from tts_bs_dispo_detail_pilsay A where A.fecha = '+1'  and A.Status  = 'STD' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
in1    = (select count(A.Fechaf) from tts_bs_dispo_detail_pilsay A where A.fecha = '+1'  and A.Status  = 'IN'  and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
----al dia de hoy + 2 ---------------
out2   = (select count(A.Fechaf) from tts_bs_dispo_detail_pilsay A where A.fecha = '+2'  and A.Status  = 'OUT' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
dsp2   = (select count(    *   ) from tts_bs_dispo_detail_pilsay A where A.fecha = '+2'  and A.Status  = 'DSP' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
std2   = (select count(    *   ) from tts_bs_dispo_detail_pilsay A where A.fecha = '+2'  and A.Status  = 'STD' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
in2    = (select count(A.Fechaf) from tts_bs_dispo_detail_pilsay A where A.fecha = '+2'  and A.Status  = 'IN'  and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
----al dia de hoy + 3 ---------------
out3   = (select count(A.Fechaf) from tts_bs_dispo_detail_pilsay A where A.fecha = '+3'  and A.Status  = 'OUT' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
dsp3   = (select count(    *   ) from tts_bs_dispo_detail_pilsay A where A.fecha = '+3'  and A.Status  = 'DSP' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
std3   = (select count(    *   ) from tts_bs_dispo_detail_pilsay A where A.fecha = '+3'  and A.Status  = 'STD' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
in3    = (select count(A.Fechaf) from tts_bs_dispo_detail_pilsay A where A.fecha = '+3'  and A.Status  = 'IN'  and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
----al dia de hoy + 4 ---------------
out4   = (select count(A.Fechaf) from tts_bs_dispo_detail_pilsay A where A.fecha = '+4'  and A.Status  = 'OUT' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
dsp4   = (select count(    *   ) from tts_bs_dispo_detail_pilsay A where A.fecha = '+4'  and A.Status  = 'DSP' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
std4   = (select count(    *   ) from tts_bs_dispo_detail_pilsay A where A.fecha = '+4'  and A.Status  = 'STD' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
in4    = (select count(A.Fechaf) from tts_bs_dispo_detail_pilsay A where A.fecha = '+4'  and A.Status  = 'IN'  and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
----al dia de hoy > 4 ---------------
outm   = (select count(A.Fechaf) from tts_bs_dispo_detail_pilsay A where A.fecha = '>4'  and A.Status  = 'OUT' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
dspm   = (select count(    *   ) from tts_bs_dispo_detail_pilsay A where A.fecha = '>4'  and A.Status  = 'DSP' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
stdm   = (select count(    *   ) from tts_bs_dispo_detail_pilsay A where A.fecha = '>4'  and A.Status  = 'STD' and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
inm    = (select count(A.Fechaf) from tts_bs_dispo_detail_pilsay A where A.fecha = '>4'  and A.Status  = 'IN'  and (O.Proyecto = A.Proyecto) and (O.Region = A.Region)),
ordeng = case O.region 
when 'Nuevo Laredo' then 1
when 'Monterrey' then 2
when 'Chihuahua' then 3
when 'Tijuana' then 4
when 'Culiacan' then 5
when 'Guadalajara' then 6
when 'Queretaro' then 7
when 'Puebla' then 8
when 'Mexico' then 9
when 'Villahermosa' then 10
when 'Merida' then 11
when 'UNKNOWN' then 12

end

from tts_bs_dispo_detail_pilsay O
group by O.Region, O.Proyecto
order by ordeng


if (@modo = 'snap')
 begin
  insert into [172.24.16.113].TMW_DWLive.dbo.regionperformance_bm
 
  select getdate(),
  region,
  Proyecto,
  cast(out1 as float) - cast((dsp1+ std1 + in1) as float)  as value
  from tts_bs_dispo_pilsay

end


GO
