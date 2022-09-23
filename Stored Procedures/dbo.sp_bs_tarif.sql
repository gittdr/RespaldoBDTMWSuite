SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**********************************
Autor: Emilio Olvera Yanez
Fecha: 16 Nov 2018 11.07am COR

SP que llena las tablas para generar reporte 
de estado de ordenes sin tarifa

Sentencia de prueba

exec [sp_bs_tarif]

exec [sp_bs_tarif] 'snap'


select * from tts_bs_tarif_detail
select * from delete tts_bs_tarif


************************************/


CREATE proc [dbo].[sp_bs_tarif] (@modo varchar(5) = NULL)

as

delete tts_bs_tarif_detail
delete tts_bs_tarif



insert into  tts_bs_tarif_detail

select ord_billto as Cliente,
(select cmp_name from company where cmp_id = ord_shipper) as Origen,
(select cty_nmstct from company where cmp_id =ord_shipper) as CiudadOrigen,
(select cmp_name from company where cmp_id =ord_consignee) as Destino,
(select cty_nmstct from company where cmp_id = ord_consignee) as CiudadDestino,
 o.ord_hdrnumber as Orden,
 datediff(day,o.ord_completiondate,getdate()) as   tarifflag,
  o.ord_completiondate as Fecha,
 case when  ((select count(*) from workflow_Data where  Workflow_Field_Name = 'Result' and Workflow_Field_Data like 'ERROR' and workflow_id = (select max(workflow_id)
 from workflow where workflow_startvalue = ord_number) and workflow_field_name = 'Result')) >0 then 'Y' else 'N' end as Error,
 '' as ErrorDesc,
 '' as ErrorNote,
 '' as ErrorNoteType
 --(select ivh_invoicestatus from invoiceheader where ivh_hdrnumber = o.ord_hdrnumber)
  from orderheader o 
 where  
-- isnull(tar_number,0)  = 0
--and ord_completiondate >= '2020-01-01' and o.ord_billto NOT IN( 'TDRQUERE','SAE') and ord_status = 'CMP' 
--and ord_completiondate < CONVERT(varchar, getdate(), 101)   and ord_invoicestatus = 'AVL'

ord_hdrnumber in (select ord_hdrnumber from orderheader where isnull(tar_number,0)  = 0 and ord_completiondate >= '2020-01-01' and ord_status = 'CMP' and ord_completiondate < CONVERT(varchar, getdate(), 101)   and ord_invoicestatus = 'AVL'  and ord_billto NOT IN( 'TDRQUERE','SAE'))
and isnull((select ivh_invoicestatus from invoiceheader where ivh_hdrnumber = o.ord_hdrnumber),'STD' )<> 'XFR'
--order by ((select count(*) from workflow_Data where  Workflow_Field_Name = 'Result' and Workflow_Field_Data like 'ERROR' and workflow_id = (select max(workflow_id)
-- from workflow where workflow_startvalue = ord_number) and workflow_field_name = 'Result')),
--  datediff(day,o.ord_completiondate,getdate()) desc

update tts_bs_tarif_detail set ErrorDesc = 'Por Procesar'
where Error = 'N'

update tts_bs_tarif_detail set ErrorNote = (select not_text_large from notes where ntb_Table = 'orderheader'  and not_type = 'TARI' and nre_tablekey = orden
and not_number = (select max(not_number) from notes where ntb_Table = 'orderheader'  and not_type = 'TARI' and nre_tablekey = Orden))

update tts_bs_tarif_detail set ErrorNoteType = (select (select name from labelfile where  abbr = not_viewlevel and labeldefinition = 'noteslevel' ) from notes where ntb_Table = 'orderheader'  and not_type = 'TARI' and nre_tablekey = orden
and not_number = (select max(not_number) from notes where ntb_Table = 'orderheader'  and not_type = 'TARI' and nre_tablekey = Orden))

update tts_bs_tarif_detail set ErrorDesc = isnull((select max(Error) from tts_syslink_errlogords where orden = ord_Hdrnumber),'No Rate Found')
where Error = 'Y'


insert into tts_bs_tarif

select 
cliente,
count(*) as ordenes,
avg(tariflag) as tariflag,
sum(case when error = 'N' then 1 else 0 end ) as PorRecalc,
sum(case when errordesc = 'No Rate Found' then 1 else 0 end) as TarifaNoEncontrada,  
sum(case when errordesc = 'No Rate Found' then 0 when errordesc = 'Por procesar' then 0  else 1 end) as ErroresOrdenes 
from tts_bs_tarif_detail
group by cliente


	
if (@modo = 'snap')
 begin
   select @modo = 'snap'

  insert into [172.24.16.113].TMW_DWLive.dbo.tarrif_bm
 
  select getdate(),
  Cliente,
  Ordenes,
  TarifLag
  from tts_bs_tarif

end

GO
