SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/**********************************
Autor: Emilio Olvera Yanez
Fecha: 21 sept 2018 2.2pm COR

SP que llena las tablas para generar reporte 
de estado de facturas

Sentencia de prueba

exec [sp_bs_invoice]

exec [sp_bs_invoice] 'snap'


************************************/


CREATE proc [dbo].[sp_bs_invoice] (@modo varchar(5) = NULL)

as

delete tts_bs_invoice_detail
delete tts_bs_invoice



insert into tts_bs_invoice_detail

select ord_billto as Cliente,
 o.ord_hdrnumber as Orden,
  o.ord_completiondate as Fecha,
  datediff(day,o.ord_completiondate,getdate()) as   billlag,
  o.ord_invoicestatus as Estatus,
  isnull((select    max(ivh_hdrnumber)        from invoiceheader i where i.ord_hdrnumber = o.ord_hdrnumber and i.ivh_invoicestatus not in ('CAN')),0) as Factura,
  isnull((select    max(ivh_mbnumber)         from invoiceheader i where i.ord_hdrnumber = o.ord_hdrnumber and i.ivh_invoicestatus not in ('CAN')),0) as Masterb,
  isnull((select    max(ivh_ref_number)       from invoiceheader i where i.ord_hdrnumber = o.ord_hdrnumber and i.ivh_invoicestatus not in ('CAN')),ord_refnum) as RefFactura,
  isnull((select    max(i.ivh_invoicestatus)  from invoiceheader i where i.ord_hdrnumber = o.ord_hdrnumber and i.ivh_invoicestatus not in ('CAN')),'AVL') as EstatusFactura,
  isnull(( 
				select top 1
				
				case when (ivh_currency) = 'US$'
				then (select max(cex_rate) from currency_exchange where cex_from_curr = ivh_currency and cex_date  = (select max(cex_date) from currency_exchange where cex_from_curr = ivh_currency)) * ivh_charge
				else (ivh_charge)
				end 
				 as rate
				
				 from invoiceheader i where i.ord_hdrnumber = o.ord_hdrnumber and i.ivh_invoicestatus not in ('CAN')


					)
					
					,case when (o.ord_currency)= 'US$' then o.ord_totalcharge * (select max(cex_rate) from currency_exchange where cex_from_curr = o.ord_currency and cex_date  = (select max(cex_date) from currency_exchange where cex_from_curr = o.ord_currency))
					
					 else  o.ord_totalcharge end) as MontoFactura,

         
		 '' as [evidencias],
		  case when ord_refnum is null then 1 else 0 end  as FaltanReferencias,
		  0 as FaltanEvidencias,
		  0 as Nocalc,
		  o.ord_revtype4 as ord_EC
from orderheader o 
where ord_status = 'CMP'  

and 
o.ord_hdrnumber not in (select ord_hdrnumber from invoiceheader where ivh_invoicestatus  in ('XFR','NTP','PPD','MFE') ) 



and ord_invoicestatus not in ('XIN','MFE','AMC')

and  ( (select distinct count(not_viewlevel) from notes where  ntb_table = 'orderheader' and not_type = 'EVI'  and nre_tablekey = o.ord_hdrnumber) = 0  or (select distinct count(not_viewlevel) from notes where  ntb_table = 'orderheader' and not_type = 'EVI'  and nre_tablekey = o.ord_hdrnumber) = 2 )

order by cliente,billlag desc 


---SE actualiza la tabla con el detalle de  las evidencias faltantes-------------
update tts_bs_invoice_detail set evidencias = 

 isnull(STUFF((SELECT '; ' + DocTypeName 

          FROM AllPaperworkView

          where OrderNumber = Orden

          and Required = 'Yes' and ReceivedMultiple not like '%Y%'

          FOR XML PATH('')), 1, 1, ''), 'OK')
----------------------------------------------------------------------------------


update tts_bs_invoice_detail set EvidenciasFaltan = 1 where [Evidencias] <> 'OK' 
update tts_bs_invoice_detail set NoCalc = 1 where MontoFactura = 0  

update tts_bs_invoice_detail set EstatusFactura = 'MFE'   where (EstatusFactura = 'AVL' and EvidenciasFaltan = 1)

delete tts_bs_invoice_detail  where EstatusFactura = 'MFE'  and Estatus = 'AVL'

delete tts_bs_invoice_detail  where EvidenciasFaltan = 1

insert into tts_bs_invoice

select 
cliente,
count(*) as ordenes,
round(sum(MontoFactura),0) as monto,
avg(BillLag) as lag,
0,  --AVLNum
0,  --AVLMonto
0,  --AVLPerc
0,  --AVLLag
0,  --HDLNum
0,  --HLDMonto
0,  --HLDPerc
0,  --HLDLag
0,  --PRNNum
0,  --PRNMonto
0,  --PRNPerc
0,  --PRNLag
0,  --RTPNum
0,  --RTPMonto
0,  --RTPPerc
0,  --RTPLag
0,  --HLANum
0,  --HLAMonto
0,  --HLAPerc
0,  --HLaLag
ord_EC
from tts_bs_invoice_detail
group by cliente, ord_EC

update tts_bs_invoice 

set AVLCount = (select isnull(count(   *      ),0) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'AVL'),
    AVLMonto = (select isnull(sum(MontoFactura),0) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'AVL'),
    AVLPerc  =  case when (select  sum(MontoFactura)  from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente) = 0 then 0 else
	            round((select cast(isnull(sum(   MontoFactura     ),0) as float) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'AVL')/
	           (select  cast(sum(MontoFactura) as float)  from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente),2) end,
    AVLLag   = (select isnull(avg(  BillLag   ),0) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura  = 'AVL'),


    HLDCount = (select isnull(count(   *      ),0) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'HLD'),
    HLDMonto = (select isnull(sum(MontoFactura),0) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'HLD'),
    HLDPerc  = case when (select  sum(MontoFactura)  from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente) = 0 then 0 else
	            round((select cast(isnull(sum(   MontoFactura     ),0) as float) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'HLD')/
	           (select  cast(sum(MontoFactura) as float)  from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente),2) end,
    HLDLag   = (select isnull(avg(  BillLag   ),0) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'HLD'),

	RTPCount = (select isnull(count(   *      ),0) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'RTP'),
    RTPMonto = (select isnull(sum(MontoFactura),0) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'RTP'),
    RTPPerc  = case when (select  sum(MontoFactura)  from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente) = 0 then 0 else
	            round((select cast(isnull(sum(   MontoFactura     ),0) as float) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'RTP')/
	           (select  cast(sum(MontoFactura) as float)  from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente),2) end,
    RTPLag   = (select isnull(avg(  BillLag   ),0) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'RTP'),

	PRNCount = (select isnull(count(   *      ),0) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'PRN'),
    PRNMonto = (select isnull(sum(MontoFactura),0) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'PRN'),
    PRNPerc  =  case when (select  sum(MontoFactura)  from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente) = 0 then 0 else
	            round((select cast(isnull(sum(   MontoFactura     ),0) as float) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'PRN')/
	           (select  cast(sum(MontoFactura) as float)  from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente),2) end,
    PRNLag   = (select isnull(avg(  BillLag   ),0) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'PRN'),
    
	HLACount = (select isnull(count(   *      ),0) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'HLA'),
    HLAMonto = (select isnull(sum(MontoFactura),0) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'HLA'),
    HLAPerc  = case when (select  sum(MontoFactura)  from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente) = 0 then 0 else
	            round((select cast(isnull(sum(   MontoFactura     ),0) as float) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'HLA')/
	           (select  cast(sum(MontoFactura) as float)  from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente),2) end,
    HLALag   = (select isnull(avg(  BillLag   ),0) from tts_bs_invoice_detail where tts_bs_invoice_detail.cliente  = tts_bs_invoice.cliente and EstatusFactura = 'HLA')

	
if (@modo = 'snap')
 begin
   select @modo = 'snap'

  insert into [172.24.16.113].TMW_DWLive.dbo.invoiceperformance_bm
 
  select
  getdate(),
  cliente,
  count(orden) as ordenes,
  30 as Lag,
  sum(MontoFactura) as Monto,
  ord_EC
  from tts_bs_invoice_detail
  where billlag > 30
  group by cliente,ord_EC


   /*
  select getdate(),
  Cliente,
  Ordenes,
  Lag,
  Monto
  from tts_bs_invoice
  */


end


GO
