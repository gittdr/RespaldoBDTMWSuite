SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[sp_billtoordeder] @orden varchar(20), @modo varchar(20)

as


if @modo = 'DET'
begin
	SELECT 
	(select cty_nmstct from city where cty_code = ord_origincity) as origen ,
	(select cty_nmstct from city where cty_code = ord_destcity) as destino,
	(select cmp_name from company where cmp_id = ord_shipper) as shipper,
	(select cmp_name from company where cmp_id =ord_consignee) as consignee,
	(select sum(stp_ord_mileage) from stops (nolock) where stops.ord_hdrnumber =  ord.ord_hdrnumber)  as kms,
	(select isnull(max(CargaTon),0) + isnull(max(CargaTon2),0) from Sl_Pilgrims_Rutas s where s.ruta = (select max(ref_number) from referencenumber where ref_type = 'SID' and  referencenumber.ord_hdrnumber = ord.ord_hdrnumber) ) as toneladas , 
    (select isnull(max(Cajas),0) + isnull(max(Cajas2),0) from Sl_Pilgrims_Rutas s where s.ruta = (select max(ref_number) from referencenumber where ref_type = 'SID' and  referencenumber.ord_hdrnumber = ord.ord_hdrnumber) ) as Cajas,
	(select FlejePlastico + ValePlastico from Sl_Pilgrims_Rutas s where s.ruta = (select max(ref_number) from referencenumber where ref_type = 'SID' and  referencenumber.ord_hdrnumber = ord.ord_hdrnumber) ) as FlejesPlastico,
	(select FlejePlastico2 + ValePlastico2 from Sl_Pilgrims_Rutas s where s.ruta = (select max(ref_number) from referencenumber where ref_type = 'SID' and  referencenumber.ord_hdrnumber = ord.ord_hdrnumber) ) as FlejesPlastico2,
	(select Remisiones1 from Sl_Pilgrims_Rutas s where s.ruta = (select max(ref_number) from referencenumber where ref_type = 'SID' and  referencenumber.ord_hdrnumber = ord.ord_hdrnumber) ) as Remision1,
	(select Remisiones2 from Sl_Pilgrims_Rutas s where s.ruta = (select max(ref_number) from referencenumber where ref_type = 'SID' and  referencenumber.ord_hdrnumber = ord.ord_hdrnumber) ) as Remision2,
	(select replace(car_name,'UNKNOWN','TDR') from carrier  where car_id = ord_carrier) as carrier,
	ord_startdate as finicio,
	ord_completiondate as ffin,
	(select max(lgh_number) from legheader (nolock) where legheader.ord_hdrnumber = ord.ord_hdrnumber) as Leg,
	case when ord_bookedby = 'ESTAT' then 'Convoy360' else (SELECT usr_fname + ' '+ usr_lname from ttsusers where usr_userid = ord_bookedby) end as ingreso

	 from orderheader ord where ord_hdrnumber = @orden
 end
 --------------------------------------------------------------------------

 if(@modo = 'STOPS')
 begin

	 select 
	stp_mfh_sequence as secuencia,
	cmp_name as locacion,
	(select cty_nmstct from city where cty_code = stp_city) as ciudad,
	stp_arrivaldate as llegada,
	stp_schdtlatest as citallegada,
	cast(datediff(MINUTE, stp_arrivaldate, stp_schdtlatest) as varchar(20)) + ' min ' + case when datediff(MINUTE, stp_arrivaldate, stp_schdtlatest) > 0 then 'tarde' else 'temprano' end  as OT ,
	stp_departuredate as salida,
	(select  (select mpp_firstname + ' ' + mpp_lastname  from manpowerprofile where mpp_id =evt_driver1)  from event e where e.stp_number = s.stp_number) as Operador,
	(select evt_tractor  + ' -  ejes:' + isnull((select cast(trc_axles as varchar(5)) from tractorprofile where trc_number = evt_tractor),'')  from event e where e.stp_number = s.stp_number) as tractor,
	(select  case when evt_trailer1 = 'UNKNOWN' then '' else replace(evt_trailer1,'UNKNOWN','') 
	+ ' -  ejes:' + isnull((select cast(trl_axles as varchar(5)) from trailerprofile where trl_number = evt_trailer1),'') end  from event e where e.stp_number = s.stp_number) as remolque1,
	(select  case when evt_dolly    = 'UNKNOWN' then '' else replace(evt_dolly,'UNKNOWN','') 
	+ ' -  ejes:' + isnull((select cast(trl_axles as varchar(5)) from trailerprofile where trl_number = evt_dolly),'') end from event e where e.stp_number = s.stp_number) as dolly,
	(select  case when evt_trailer2 = 'UNKNOWN' then '' else replace(evt_trailer2,'UNKNOWN','')  
	+ ' -  ejes:' + isnull((select cast(trl_axles as varchar(5)) from trailerprofile where trl_number = evt_trailer2),'') end from event e where e.stp_number = s.stp_number) as remolque2,
	(select isnull((select trc_axles  from tractorprofile where trc_number = evt_tractor),0) +  isnull((select trl_axles  from trailerprofile where trl_number = evt_dolly),0) 
	+ isnull((select trl_axles  from trailerprofile where trl_number = evt_trailer2),0) +  isnull((select trl_axles from trailerprofile where trl_number = evt_trailer1),0) from event e where e.stp_number = s.stp_number) as totalejes,
	isnull(stp_ord_mileage,0) as kms,
	isnull(stp_ord_toll_cost,0) as casetas
	

	from stops  s
	 where ord_hdrnumber = @orden

 end
GO
