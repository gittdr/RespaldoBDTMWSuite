SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/********
exec sp_pilgrims_cmpfreights_orden ''', 'PI15765-QA76000-APY15765'




*********/

CREATE proc [dbo].[sp_pilgrims_cmpfreights_orden] ( @orden varchar(20),@token varchar(254))

as



declare @CompletedFreights xml

set @CompletedFreights =

(
select 
ruta as Ruta,
Bitacora,
Orden as IDConvoy,
Estatus as EStatus,
FechaInicioReal,
FechaFinReal,
FechaInicioPlaneada,
FechaFinPlaneada,
ord_tractor as Tracto,
replace(lgh_primary_trailer,'UNKNOWN','') as 'Remolque1',
replace(lgh_primary_pup,'UNKNOWN','') as 'Remolque2',
axletrc + axletrl1 + axletrl2 + axledolly as 'Ejes',
case when lgh_primary_pup = 'UNKNOWN' then 'SENCILLO' else 'FULL' end as Configuracion,
KmsTDR as KmsRecorrido,
isnull(cast(KmsPilgrims as int),0) as KmsPilgrims,
PctDif = cast(round((cast(KmsTDR as float) -cast(isnull(KmsPilgrims,0) as float))/ cast((KmsPilgrims) as float) *100 ,2) as varchar(10)),
Origen,
EstadoOrigen,
Destino,
EstadoDestino,
Operador,
(select sum(isnull(stp_ord_toll_cost,0)) from stops where stops.ord_hdrnumber  = kms.orden) as Casetas,

(select cht_itemcode as IdCargoSec,ivd_description as Descripcion,  ivd_unit as Unidad, cast(round(cast(ivd_quantity as float),2) as varchar(20)) as Cantidad, round(ivd_rate,2) as Tarifa,ivd_charge as Monto
  from invoicedetail inv where inv.ord_hdrnumber = '612589' and cht_itemcode not in ('MIN','VIAJE','GST','PST') FOR XML PATH('Cargo'), TYPE) as CargosSecundarios,

(select isnull(max(CargaTon),0) + isnull(max(CargaTon2),0) from Sl_Pilgrims_Rutas s where s.ruta = kms.Ruta) as Kgs , 
(select isnull(max(Cajas),0) + isnull(max(Cajas2),0) from Sl_Pilgrims_Rutas s where s.ruta = kms.Ruta) as Cajas , 
Notas as Observaciones
from

(select 
isnull((select max(ref_number) from referencenumber ref where  ref.ref_table = 'orderheader' and  ref.ref_type = 'SID' and ref.ref_tablekey = ord.ord_hdrnumber),'Fuera SDS')   as Ruta,
isnull((select max(ref_number) from referencenumber ref where  ref.ref_table = 'orderheader' and  ref.ref_type = 'LPID' and ref.ref_tablekey = ord.ord_hdrnumber),ord.ord_refnum)  as bitacora,
ord_status as Estatus,
ord.ord_hdrnumber as orden,
lgh_startdate as FechaInicioReal,
lgh_enddate as FechaFinReal,
lgh_schdtearliest as FechaInicioPlaneada,
lgh_schdtlatest as FechaFinPlaneada,
ord_tractor,
lgh_primary_trailer,
lgh_primary_pup,
isnull((select trc_Axles  from tractorprofile  where ord_Tractor = trc_number),0) as axletrc,
isnull((select trl_Axles  from trailerprofile  where lgh_primary_trailer = trl_number),0) as axletrl1,
isnull((select trl_Axles  from trailerprofile  where lgh_primary_pup = trl_number),0) as axletrl2,
isnull((select trl_Axles  from trailerprofile  where lgh_dolly = trl_number),0) as axledolly,
(select cty_name from city where cty_code =ord_origincity) as origen,
(select UPPER(stc_state_desc) from statecountry where stc_state_c =ord_originstate) as estadoorigen,
(select cty_name from city where cty_code =ord_destcity) as destino,
(select UPPER(stc_state_desc) from statecountry where stc_state_c =ord_deststate) as estadodestino,
ord_consignee,
mpp_firstname +' ' + mpp_lastname as Operador,
ord_totalmiles as KmsTDR,
(select  max(not_text) from notes where ntb_table = 'orderheader' and not_type = 'RUTA' and nre_tablekey = ord.ord_hdrnumber) as Notas,
(select max(DistanciaIdaVuelta) from SL_PilgrimsTMW_CatalogoClientes where Compania_TMW =  ord_Consignee) as   KmsPilgrims
 from invoiceheader as inv
 left join orderheader as ord  on inv.ord_hdrnumber = ord.ord_hdrnumber 
 left join legheader on ord.ord_hdrnumber = legheader.ord_hdrnumber
 left join manpowerprofile on ord.ord_driver1 = mpp_id
where inv.ivh_billto =  'PILGRIMS' 
 and ord_status not in ('XIN', 'CAN') and ord.ord_status = 'CMP'
 and ord.ord_hdrnumber  = @orden
 and @token = (select cmp_misc8 from company where cmp_id = 'PILGRIMS')


 ) as kms
 order by FechaFinReal desc

FOR XML PATH ('FREIGHT'), root ('COMPLETEDFREIGHTS')

)

select @CompletedFreights as CompletedFreights
GO
