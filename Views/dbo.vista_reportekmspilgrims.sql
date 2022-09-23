SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[vista_reportekmspilgrims]
as

select 
format(FechaTermino,'dd-MM-yyyy')  Fecha,
isnull(LPID,ord_refnum) as Bitacora,
ord_tractor as Tracto,
replace(lgh_primary_trailer,'UNKNOWN','') as '1erPlataforma',
replace(lgh_primary_pup,'UNKNOWN','') as '2daPlataforma',
axletrc + axletrl1 + axletrl2 + axledolly as 'Ejes',
case when lgh_primary_pup = 'UNKNOWN' then 'SENCILLO' else 'FULL' end as Configuracion,
'' as KmsInicial,
'' as KmsFinal,
KmsTDR as KmsRecorrido,
isnull(cast(KmsPilgrims as int),0) as KmsPilgrims,
PctDif = case when KmsPilgrims = 0 then 0 else round((cast(KmsTDR as float) -cast(isnull(KmsPilgrims,0) as float))/ cast((KmsPilgrims) as float) *100 ,2) end,
ord_consignee as Compania,
(select  cmp_name from company where cmp_id = ord_consignee) as Nombre,
Destino,
Estado,
Operador,
(select sum(isnull(stp_ord_toll_cost,0)) from stops where stops.ord_hdrnumber  = kms.ord_hdrnumber) as Casetas,
(select isnull(max(CargaTon),0) + isnull(max(CargaTon2),0) from Sl_Pilgrims_Rutas s where s.ruta = kms.Ruta) as Kgs , 
(select isnull(max(Cajas),0) + isnull(max(Cajas2),0) from Sl_Pilgrims_Rutas s where s.ruta = kms.Ruta) as Cajas , 
Notas as Observaciones,
ord_hdrnumber ControlConvoy,
isnull(Ruta,'Fuera SDS') as Ruta
from

(select  
ord_hdrnumber,
ord_refnum,
ord_completiondate as FechaTermino,
ord_tractor,
ord_totalweight,
(select max(lgh_primary_trailer) from legheader where legheader.ord_hdrnumber = orderheader.ord_hdrnumber) as lgh_primary_trailer ,
(select max(lgh_primary_pup) from legheader where legheader.ord_hdrnumber = orderheader.ord_hdrnumber) as lgh_primary_pup ,
isnull((select trc_Axles  from tractorprofile  where ord_Tractor = trc_number),0) as axletrc,
isnull((select trl_Axles  from trailerprofile  where (select max(lgh_primary_trailer) from legheader where legheader.ord_hdrnumber = orderheader.ord_hdrnumber) = trl_number),0) as axletrl1,
isnull((select trl_Axles  from trailerprofile  where (select max(lgh_primary_pup) from legheader where legheader.ord_hdrnumber = orderheader.ord_hdrnumber) = trl_number),0) as axletrl2,
isnull((select trl_Axles  from trailerprofile  where (select max(lgh_dolly) from legheader where legheader.ord_hdrnumber = orderheader.ord_hdrnumber) = trl_number),0) as axledolly,
(select cty_name from city where cty_code =ord_destcity) as destino,
(select UPPER(stc_state_desc) from statecountry where stc_state_c =ord_deststate) as estado,
ord_consignee,
mpp_firstname +' ' + mpp_lastname as Operador,
(select sum(stp_ord_mileage) from stops (nolock) where stops.ord_hdrnumber =  orderheader.ord_hdrnumber) as KmsTDR,
(select  max(not_text) from notes where ntb_table = 'orderheader' and not_type = 'RUTA' and nre_tablekey = orderheader.ord_hdrnumber) as Notas,
(select max(ref_number) from referencenumber where ref_type = 'SID' and  referencenumber.ord_hdrnumber = orderheader.ord_hdrnumber) as Ruta,
(select max(ref_number) from referencenumber where ref_type = 'LPID' and  referencenumber.ord_hdrnumber = orderheader.ord_hdrnumber) as LPID,
 (select max(DistanciaIdaVuelta) from SL_PilgrimsTMW_CatalogoClientes where Compania_TMW =  ord_Consignee) as   KmsPilgrims
 from orderheader 
 left join manpowerprofile on orderheader.ord_driver1 = mpp_id
where orderheader.ord_billto = 'PILGRIMS' and ord_status = 'CMP' and ord_status <> 'CAN' 
and datediff(dd,ord_completiondate,getdate()) <= 7 ) as kms




GO
