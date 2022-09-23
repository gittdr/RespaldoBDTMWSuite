SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/********
exec sp_pilgrims_cmpfreights '2018-09-01T00:00:00', '2018-10-30T23:59:00', 'PI15765-QA76000-APY15765'




*********/

create proc [dbo].[sp_pilgrims_cmpfreights_sds] ( @sds varchar(30),@token varchar(254))

as



declare @CompletedFreights xml

set @CompletedFreights =

(
select 
FechaTermino Fecha,
ord_refnum as Ruta,
bitacora,
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
'0.00' Casetas,
Notas as Observaciones
from

(select  ord_refnum,
lgh_number as bitacora,
ord_completiondate as FechaTermino,
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
 case ord_Consignee
when 'PLGDIGRO' then 878
when 'PLGWAAGS' then 898
when 'PLGSIHGO' then 65
when 'PLGMIEM' then 110
when 'PLGICDMX' then 166
when 'PLGDITAB' then 1.560
when 'PLGWEM' then 226
when 'PLGCHGRO' then 692
when 'PLGDISCO' then 1.331
when 'PLGPIEM' then 62
when 'PLGLAMOR' then 325
when 'PLGPIQRO' then 264
when 'PLGWASIN' then 2.414
when 'PLGFRQRO' then 310
when 'PLGPLDGO' then 1.900
when 'PLGCDJAL' then 974
when 'PLGFAEM' then 60
when 'PLGAVEM' then 240
when 'PLGDCDMX' then 149
when 'PLGLMICH' then 1.163
when 'PLGDIGTO' then 630
when 'PLGCEVER' then 816
when 'PLGCDNL' then 1.712
when 'PLGALNL' then 1.745
when 'PLGCMICH' then 470
when 'PLGCSTA' then 1.418
when 'PLGCATA' then 2.095
when 'PLGDIOAX' then 1.062
when 'PLGRAHGO' then 234
when 'PLGDIVER' then 610
when 'PLGCDPU' then 393
when 'PLGRCDMX' then 141
when 'PLGPCDMX' then 170
when 'PLGPISLP' then 690
when 'PLGWAEM' then 92
when 'PLGDITAM' then 1.034
when 'PLGDICHI' then 2.505
when 'PLGCDHGO' then 21
when 'PILTEP' then 68
when 'PLGCDSEM' then 103
when 'PLGCDEM' then 291
when 'PLGMAHGO' then 282
when 'CDTTUX' then 1.827
when 'PLGPOTAB' then 1.675
when 'PLGGAVER' then 722
when 'PILSAN' then 191
when 'PATQUE01' then 135
when 'PLGGUEM' then 146
when 'SORMEX01' then 62
when 'PLGFRHGO' then 21
when 'PLGICDMX' then 166
when 'LOGMEX01' then 150
 end as   KmsPilgrims
 from invoiceheader as inv
 left join orderheader as ord  on inv.ord_hdrnumber = ord.ord_hdrnumber 
 left join legheader on ord.ord_hdrnumber = legheader.ord_hdrnumber
 left join manpowerprofile on ord.ord_driver1 = mpp_id
where inv.ivh_billto =  'PILGRIMS' and inv.ivh_invoicestatus = 'HLD'
 and ord_status not in ('XIN', 'CAN')
 and ord.ord_refnum = @sds
 and @token = (select cmp_misc8 from company where cmp_id = 'PILGRIMS')


 ) as kms
 order by fecha desc

FOR XML PATH ('FREIGHT'), root ('COMPLETEDFREIGHTS')

)

select @CompletedFreights as CompletedFreights
GO
