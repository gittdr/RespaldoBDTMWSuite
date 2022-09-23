SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [dbo].[sp_balancedriver] (@modo varchar(5) = NULL)

as 
/**
--AUTOR - Emilio Olvera Yáñez
--FECHA CREACION 8/28/2018 1:15 pm

--VERSION 1.0
--DESCRIPCION- SP que mediante consultas genera hoja de balance de operadores.

prueba ejecución del sp 

exec sp_balancedriver
exec sp_balancedriver 'snap'

prueba para consultar lo insertado en la tabla pesistente
 select * from tts_drv_dispo order by lider desc
select * from tts_drv_dispo_detail where region = 'villahermosa' and fecha = 'hoy'


***/

--borramos el contenido de las tablas persistentes para estar listas y recibir nuevos datos.

delete tts_drv_dispo_detail
delete tts_drv_dispo

--Creamos variable tabla para recibir los datos de los sps del rawdata
CREATE TABLE #rawdatadrv 
(Cliente varchar(20), Origen varchar(100), Destino varchar(100), Remolque varchar(40), ProyectoDrv varchar(20),
Proyecto varchar(100), Region varchar(100),Tractor varchar(20), Operador varchar(20), 
 Status varchar(20), LghStatus varchar(20),Fecha datetime, FechaTermino datetime, 
 CiudadOrigen varchar(200), CiudadDestino varchar(200), Orden varchar(20), Leg varchar(20), Lider varchar(200))


----INSERTAR LOS DRIVERS QUE ESTAN EN CURSO --------------------------------------------------------------------------------------------------------------------------


insert into #rawdatadrv

	select Cliente,Origen,Destino,Remolque,ProyectoDrv,Proyecto,REgion, Tractor,Operador,Status,leg_status,Fecha,FechaTermino,CiudadOrigen,CiudadDestino,Orden,Leg,Lider from(

   select

	Cliente = (select ord_billto from orderheader where orderheader.ord_hdrnumber = legheader.ord_hdrnumber), 
	Origen =  (select cmp_name from company where cmp_id =cmp_id_start),
	Destino = (select cmp_name from company where cmp_id = cmp_id_end),
	Remolque = lgh_primary_trailer,
	ProyectoDrv = case when mpp_type3 in ('BAJ') then 'ABIERTO' else 
	           (select name from labelfile where labeldefinition = 'drvtype3' and
			    abbr= (select mpp_type3 from manpowerprofile m where m.mpp_id  = legheader.lgh_driver1)) end,
    Proyecto = case when mpp_type3 in ('BAJ','TOL','FULS','ONI','PA') then 'ABIERTO' else 
	           (select name from labelfile where labeldefinition = 'drvtype3' and
			    abbr= (select mpp_type3 from manpowerprofile m where m.mpp_id  = legheader.lgh_driver1)) end,
    Region =  isnull((select rgh_name from regionheader where rgh_id = (select cty_region1 from city where cty_code = lgh_endcity )   ),'UNKNOWN'),
    Tractor =  lgh_tractor,
	Operador = lgh_driver1,
	Status = 'ROAD',
	leg_status = lgh_outstatus,
	Fecha=  lgh_enddate,
	FechaTermino =  lgh_enddate,
	CiudadOrigen = lgh_startcty_nmstct,
	CiudadDestino = lgh_endcty_nmstct,
	Orden = legheader.ord_hdrnumber,
	Leg = legheader.lgh_number,
	Lider =  replace(isnull((select name from labelfile where labeldefinition = 'teamleader' and abbr = (select mpp_teamleader from manpowerprofile where mpp_id = lgh_driver1)),'UNKNOWN'),'','UNKNOWN'),
	row_number() over(partition by legheader.lgh_driver1 order by lgh_enddate desc) as rn
	from legheader (nolock)
    where lgh_outstatus = ('STD') and lgh_driver1 <> 'UNKNOWN'
	and lgh_driver1 not in (select mpp_id from manpowerprofile (nolock) where mpp_type3 = 'PA')
	and lgh_driver1 not in (select mpp_id from manpowerprofile (nolock) where mpp_status = 'OUT')
	and lgh_driver1 is not null
	and len(lgh_driver1) > 1
	) as started
	where rn = 1

----INSERTAR LOS DRIVERS QUE ESTAN PLANEADOS --------------------------------------------------------------------------------------------------------------------------


insert into #rawdatadrv

	select Cliente,Origen,Destino,Remolque,ProyectoDrv,Proyecto,REgion, Tractor,Operador,Status,leg_status,Fecha,FechaTermino,CiudadOrigen,CiudadDestino,Orden,Leg,Lider from(

   select

	Cliente = (select ord_billto from orderheader where orderheader.ord_hdrnumber = legheader.ord_hdrnumber), 
	Origen =  (select cmp_name from company where cmp_id =cmp_id_start),
	Destino = (select cmp_name from company where cmp_id = cmp_id_end),
	Remolque = lgh_primary_trailer,
	ProyectoDrv = case when mpp_type3 in ('BAJ') then 'ABIERTO' else 
	           (select name from labelfile where labeldefinition = 'drvtype3' and
			    abbr= (select mpp_type3 from manpowerprofile m where m.mpp_id  = legheader.lgh_driver1)) end,
    Proyecto = case when mpp_type3 in ('BAJ','TOL','FULS','ONI','PA') then 'ABIERTO' else 
	           (select name from labelfile where labeldefinition = 'drvtype3' and
			    abbr= (select mpp_type3 from manpowerprofile m where m.mpp_id  = legheader.lgh_driver1)) end,
    Region =  isnull((select rgh_name from regionheader where rgh_id = (select cty_region1 from city where cty_code = lgh_endcity )   ),'UNKNOWN'),
    Tractor =  lgh_tractor,
	Operador = lgh_driver1,
	Status = 'PLN',
	leg_status = lgh_outstatus,
	Fecha=  lgh_enddate,
	FechaTermino =  lgh_enddate,
	CiudadOrigen = lgh_startcty_nmstct,
	CiudadDestino = lgh_endcty_nmstct,
	Orden = legheader.ord_hdrnumber,
	Leg = legheader.lgh_number,
	Lider =  replace(isnull((select name from labelfile where labeldefinition = 'teamleader' and abbr = (select mpp_teamleader from manpowerprofile where mpp_id = lgh_driver1)),'UNKNOWN'),'','UNKNOWN'),
	row_number() over(partition by legheader.lgh_driver1 order by lgh_enddate desc) as rn
	from legheader (nolock)
    where lgh_outstatus = ('PLN') and lgh_driver1 <> 'UNKNOWN'
	and lgh_driver1 not in (select mpp_id from manpowerprofile (nolock) where mpp_type3 = 'PA')
	and lgh_driver1 not in (select mpp_id from manpowerprofile (nolock) where mpp_status = 'OUT')
	and lgh_driver1 is not null
	and len(lgh_driver1) > 1
	) as started
	where rn = 1




----INSERTAR LOS DRIVERS QUE ESTAN DISPONIBLES --------------------------------------------------------------------------------------------------------------------------



insert into #rawdatadrv


SELECT  


  	Cliente =  orderheader.ord_billto,
	Origen = legheader.cmp_id_start,
    Destino = legheader.cmp_id_end,
	Remolque = mpp_pln_lgh, 
	ProyectoDrv = case when manpowerprofile.mpp_type3 in ('BAJ') then 'ABIERTO' else 
	           (select name from labelfile where labeldefinition = 'drvtype3' and
			    abbr= (select mpp_type3 from manpowerprofile m where m.mpp_id  = legheader.lgh_driver1)) end,
    Proyecto = case when manpowerprofile.mpp_type3 in ('BAJ','TOL','FULS','ONI','PA') then 'ABIERTO' else 
	           (select name from labelfile where labeldefinition = 'drvtype3' and
			    abbr= (select mpp_type3 from manpowerprofile m where m.mpp_id  = legheader.lgh_driver1)) end,
    Region = isnull((select rgh_name from regionheader where rgh_id =  (select cty_region1 from city  where cty_code = mpp_avl_city)),'UNKNOWN'),
    Tractor = mpp_tractornumber,
	Operador = mpp_id,
	Status = 'AVL' ,
	OrdStatus = mpp_status,

	Fecha =  mpp_avl_date,
	FechaTermino = mpp_avl_date,

    CiudadOrigen ='',
	CiudadDestino = (select cty_name from city  where cty_code = mpp_avl_city),
	Orden = orderheader.ord_hdrnumber,
	Leg = legheader.lgh_number,
	Lider = replace(isnull((select name from labelfile where labeldefinition = 'teamleader' and abbr =  manpowerprofile.mpp_teamleader),'UNKNOWN'),'','UNKNOWN')

	from manpowerprofile (nolock)
	left join legheader (nolock) on legheader.lgh_number = manpowerprofile.mpp_pln_lgh
	left join orderheader (nolock) on legheader.ord_hdrnumber = orderheader.ord_hdrnumber
	where mpp_status in  ('AVL') and mpp_next_legnumber is null
	and mpp_status <> 'OUT'



	
----INSERTAR LOS DRIVERS QUE TIENEN EXPIRACION --------------------------------------------------------------------------------------------------------------------------


insert into #rawdatadrv


	Select 
	Cliente =  orderheader.ord_billto,
	Origen = legheader.cmp_id_start,
	Destino = legheader.cmp_id_end,
	Remolque = mpp_pln_lgh,
	ProyectoDrv = case when manpowerprofile.mpp_type3 in ('BAJ') then 'ABIERTO' else 
	           (select name from labelfile where labeldefinition = 'drvtype3' and
			    abbr= (select mpp_type3 from manpowerprofile m where m.mpp_id  = legheader.lgh_driver1)) end,
    Proyecto = case when manpowerprofile.mpp_type3 in ('BAJ','TOL','FULS','ONI','PA') then 'ABIERTO' else 
	           (select name from labelfile where labeldefinition = 'drvtype3' and
			    abbr= (select mpp_type3 from manpowerprofile m where m.mpp_id  = legheader.lgh_driver1)) end,
	Region  = isnull((select rgh_name from regionheader where rgh_id =  (select cty_region1 from city  where cty_code = mpp_avl_city)),'UNKNOWN'),
	Tractor = '',
	Operador = exp_id,
	Status = 'OUT' ,
	OrdStatus = (select name from labelfile where abbr = exp_code and labeldefinition = 'DrvExp'),
	Fecha = exp_expirationdate, --mpp_avl_date,
	FechaTermino = exp_lastdate, ---exp_compldate,
	CiudadOrigen = '',
	CiudadDestino =  (select cty_name from city  where cty_code = mpp_avl_city),
	Orden = orderheader.ord_hdrnumber,
	Leg = legheader.lgh_number,
	Lider = replace(isnull((select name from labelfile where labeldefinition = 'teamleader' and abbr =  manpowerprofile.mpp_teamleader),'UNKNOWN'),'','UNKNOWN')

	from expiration
	left join manpowerprofile on mpp_id = exp_id
	left join legheader (nolock) on legheader.lgh_number = manpowerprofile.mpp_pln_lgh
	left join orderheader (nolock) on legheader.ord_hdrnumber = orderheader.ord_hdrnumber
	
	where exp_idtype = 'DRV' and exp_completed = 'N'
	and manpowerprofile.mpp_type3 <> 'PA' and mpp_status <> 'OUT'
	and exp_code in ('SIC','LIC','SERMED','EXMED','CAPA','ADMIN','LEG','VAC','TRAM','OMTTO','PER','FALTA','DES') 
	and datediff(day,exp_expirationdate,getdate()) >= 0
		

	

--Insertamos la consulta de la tabla variable con el resultado final a nuestra tabla persistente
insert into tts_drv_dispo_detail

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
	isnull((select name from labelfile where  abbr  = LghStatus and labeldefinition = 'DrvExp'),lghStatus),
	Fecha =
		   case
		      when (datediff(dd,getdate(),Fecha) <= 0) then 'Hoy'
			  when (datediff(dd,getdate(),Fecha) = 1 ) then '+1'
			  when (datediff(dd,getdate(),Fecha) = 2 ) then '+2'
			  when (datediff(dd,getdate(),Fecha) = 3 ) then '+3'
			  when (datediff(dd,getdate(),Fecha) = 4 ) then '+4' 
			  when (datediff(dd,getdate(),Fecha) > 4 ) then '>4'
			  end,

	Fechaf = Fecha,
	Fechat = FechaTermino,
	CiudadOrigen,
	CiudadDestino,
	Orden,
	Leg,
	Lider,
	ProyectoDrv
from #rawdatadrv


--Insertamos en la tabla variable creada el producto de la consulta 
insert into tts_drv_dispo 

select
O.Lider,
O.Proyecto,
----al dia de hoy-------------------
roadh  = (select count(A.Fechaf) from tts_drv_dispo_detail A where A.fecha = 'Hoy'      and A.Status  = 'ROAD' and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
plnh   = (select count(A.Fechaf) from tts_drv_dispo_detail A where A.fecha = 'Hoy'      and A.Status  = 'PLN'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
avlh   = (select count(    *   ) from tts_drv_dispo_detail A where A.fecha = 'Hoy'      and A.Status  = 'AVL'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
outh   = (select count(    *   ) from tts_drv_dispo_detail A where A.fecha = 'Hoy'      and A.Status  = 'OUT'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
----al dia de hoy + 1 ---------------
road1  = (select count(A.Fechaf) from tts_drv_dispo_detail A where A.fecha = '+1'       and A.Status  = 'ROAD' and (O.ProyDrv = A.ProyDrv)  and (O.Lider = A.Lider)),
pln1   = (select count(A.Fechaf) from tts_drv_dispo_detail A where A.fecha = '+1'      and A.Status   = 'PLN'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
avl1   = (select count(    *   ) from tts_drv_dispo_detail A where A.fecha = '+1'       and A.Status  = 'AVL'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
out1   = (select count(    *   ) from tts_drv_dispo_detail A where A.fecha  ='+1'       and A.Status  = 'OUT'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
----al dia de hoy + 2 ---------------
road2  = (select count(A.Fechaf) from tts_drv_dispo_detail A where A.fecha = '+2'       and A.Status  = 'ROAD' and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
pln2   = (select count(A.Fechaf) from tts_drv_dispo_detail A where A.fecha = '+2'      and A.Status   = 'PLN'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
avl2   = (select count(    *   ) from tts_drv_dispo_detail A where A.fecha = '+2'       and A.Status  = 'AVL'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
out2   = (select count(    *   ) from tts_drv_dispo_detail A where A.fecha = '+2'       and A.Status  = 'OUT'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),

----al dia de hoy + 3 ---------------
road3  = (select count(A.Fechaf) from tts_drv_dispo_detail A where A.fecha = '+3'       and A.Status  = 'ROAD' and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
pln3   = (select count(A.Fechaf) from tts_drv_dispo_detail A where A.fecha = '+3'      and A.Status   = 'PLN'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
avl3   = (select count(    *   ) from tts_drv_dispo_detail A where A.fecha = '+3'       and A.Status  = 'AVL'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
out3   = (select count(    *   ) from tts_drv_dispo_detail A where A.fecha = '+3'       and A.Status  = 'OUT'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),

----al dia de hoy + 4 ---------------
road4  = (select count(A.Fechaf) from tts_drv_dispo_detail A where A.fecha = '+4'      and A.Status  = 'ROAD' and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
pln4   = (select count(A.Fechaf) from tts_drv_dispo_detail A where A.fecha = '+4'      and A.Status  = 'PLN'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
avl4   = (select count(    *   ) from tts_drv_dispo_detail A where A.fecha = '+4'      and A.Status  = 'AVL'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
out4   = (select count(    *   ) from tts_drv_dispo_detail A where A.fecha = '+4'      and A.Status  = 'OUT'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),

----al dia de hoy > 4 ---------------
roadm  = (select count(A.Fechaf) from tts_drv_dispo_detail A where A.fecha = '>4'      and A.Status  = 'ROAD' and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
plnm   = (select count(A.Fechaf) from tts_drv_dispo_detail A where A.fecha = '>4'      and A.Status  = 'PLN'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
avlm   = (select count(    *   ) from tts_drv_dispo_detail A where A.fecha = '>4'      and A.Status  = 'AVL'  and (O.ProyDrv = A.ProyDrv) and (O.Lider = A.Lider)),
outm   = (select count(    *   ) from tts_drv_dispo_detail A where A.fecha = '>4'      and A.Status  = 'OUT'  and (O.ProyDrv = A.Proyecto) and (O.Lider = A.Lider)),

ordeng = 0,
'',
O.ProyDrv
from tts_drv_dispo_detail O
group by O.Lider, O.Proyecto, O.ProyDrv
order by ordeng



delete tts_drv_dispo where (outh+roadh+plnh+avlh+road1+pln1+out1+avl1+road2+pln2+avl2+out2+road3+pln3+avl3+road4+pln4+out3+avl4+roadm+plnm+avlm+out4+outm) = 0 

if (@modo = 'snap')
 begin
   select @modo = 'snap'
  insert into [172.24.16.113].TMW_DWLive.dbo.driverperformance_bm
 
  select getdate(),
  lider,
  proyecto,
  case when cast((sum(outh)+sum(roadh)+sum(plnh)+sum(avlh)+sum(road1)+sum(pln1)+sum(out1)+sum(avl1)+sum(road2)+sum(pln2)+sum(avl2)+sum(out2)+sum(road3)+sum(pln3)+sum(avl3)+sum(road4)+sum(pln4)+sum(out3)+sum(avl4)+sum(roadm)+sum(plnm)+sum(avlm)+sum(out4)+sum(outm))as float) = 0 then 0 else
 1-(cast((sum(outh)+sum(out1)+sum(out2)+sum(out3)+sum(out4)+sum(outm)) as float)  / cast((sum(outh)+sum(roadh)+sum(plnh)+sum(avlh)+sum(road1)+sum(pln1)+sum(out1)+sum(avl1)+sum(road2)+sum(pln2)+sum(avl2)+sum(out2)+sum(road3)+sum(pln3)+sum(avl3)+sum(road4)+sum(pln4)+sum(out3)+sum(avl4)+sum(roadm)+sum(plnm)+sum(avlm)+sum(out4)+sum(outm))as float)) end as uptime

 ,(sum(roadh)+sum(plnh)+sum(avlh)+sum(outh))+(sum(road1)+sum(pln1)+sum(avl1)+sum(out1))+(sum(road2)+sum(pln2)+sum(avl2)+sum(out2))+(sum(road3)+sum(pln3)+sum(avl3)+sum(out3))+ (sum(road4)+sum(pln4)+sum(avl4)+sum(out4))+(sum(roadm)+sum(plnm)+sum(avlm)+sum(outm)) as drivers

  from tts_drv_dispo
  group by lider,proyecto
end

GO
