SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/**********************************
Autor: Emilio Olvera Yanez
Fecha: 1 OCT 2018 2.2pm COR

SP que llena las tablas para generar reporte 
de estado de mesa de control

Sentencia de prueba

exec [dbo].[sp_bs_mesacontrol]

exec [dbo].[sp_bs_mesacontrol] 'snap'

select * from tts_bs_mc_detail where re
select * from tts_bs_mc

************************************/


CREATE proc [dbo].[sp_bs_mesacontrol] (@modo varchar(5) = NULL)

as

delete tts_bs_mc_detail
delete tts_bs_mc


insert into tts_bs_mc_detail

select 
 --(select name from labelfile (nolock) where labeldefinition = 'revtype3' and abbr  =o.ord_revtype3) as Proyecto,
 o.ord_billto as Proyecto,
 (select mpp_tractornumber + ' | ' + isnull(mpp_id,'') + ' | ' + isnull(mpp_firstname,'')  + ' ' + isnull(mpp_lastname,'') from manpowerprofile (nolock) where mpp_id = o.ord_driver1) as Operador,
 ord_billto as Cliente,
 o.ord_hdrnumber as Orden,
 case when year(o.ord_completiondate) < 2018  then o.ord_bookdate else o.ord_completiondate end  as Fecha,
  datediff(day,( case when year(o.ord_completiondate) < 2018  then o.ord_bookdate else o.ord_completiondate end ),getdate()) as   indexlag,
  case when datediff(dd,o.ord_completiondate,getdate()) < 5 then '<5' else '>5' end  as Estatus,
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
		  
		  0 as FaltanEvidencias,
		  case when ord_refnum is null then 1 else 0 end  as FaltanReferencias,
		  0 as Nocalc,
		  case when ord_invoicestatus = 'AMC' then 1 else 0 end as regresada,
		  o.ord_revtype4 as ord_EC
from orderheader o 
where ord_status = 'CMP'  
and o.ord_hdrnumber not in (select ord_hdrnumber from invoiceheader where ivh_invoicestatus  in ('XFR','NTP','RTP','PRN') )
and ord_invoicestatus not in ('XIN')
and  ( (select distinct count(not_viewlevel) from notes where  ntb_table = 'orderheader' and not_type = 'EVI'  and nre_tablekey = o.ord_hdrnumber) = 0  or (select distinct count(not_viewlevel) from notes where  ntb_table = 'orderheader' and not_type = 'EVI'  and nre_tablekey = o.ord_hdrnumber) = 1 )

--jr
union

select 
 --(select name from labelfile (nolock) where labeldefinition = 'revtype3' and abbr  =o.ord_revtype3) as Proyecto,
 o.ord_billto as Proyecto,
 (select mpp_tractornumber + ' | ' + isnull(mpp_id,'') + ' | ' + isnull(mpp_firstname,'')  + ' ' + isnull(mpp_lastname,'') from manpowerprofile (nolock) where mpp_id = o.ord_driver1) as Operador,
 ord_billto as Cliente,
 o.ord_hdrnumber as Orden,
 case when year(o.ord_completiondate) < 2018  then o.ord_bookdate else o.ord_completiondate end  as Fecha,
  datediff(day,( case when year(o.ord_completiondate) < 2018  then o.ord_bookdate else o.ord_completiondate end ),getdate()) as   indexlag,
  case when datediff(dd,o.ord_completiondate,getdate()) < 5 then '<5' else '>5' end  as Estatus,
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
		  
		  0 as FaltanEvidencias,
		  case when ord_refnum is null then 1 else 0 end  as FaltanReferencias,
		  0 as Nocalc,
		  case when ord_invoicestatus = 'AMC' then 1 else 0 end as regresada,
		  o.ord_revtype4 as ord_EC
from orderheader as O
	where ord_invoicestatus  in ('PPD')  and ord_status in ( 'CMP') and O.ord_completiondate > '06-06-2022'
	 and (SELECT count(OrderNumber) FROM AllPaperworkView as A  where A.OrderNumber = o.ord_hdrnumber and Required = 'Yes' and ReceivedMultiple like '%N%' ) > 0
order by cliente, indexlag desc 

---SE actualiza la tabla con el detalle de  las evidencias faltantes-------------
update tts_bs_mc_detail set Evidencias =

 isnull(STUFF((SELECT '; ' + DocTypeName 

          FROM AllPaperworkView

          where OrderNumber = Orden

          and Required = 'Yes' and ReceivedMultiple like '%N%'

          FOR XML PATH('')), 1, 1, ''), 'OK')

--------------------------------------------------------------------------------

update tts_bs_mc_detail set regresada = 1 where  ((select distinct count(not_viewlevel) from notes where  ntb_table = 'orderheader' and not_type = 'EVI'  and nre_tablekey = tts_bs_mc_detail.Orden) = 1 )
update tts_bs_mc_detail set EvidenciasFaltan = 1 where [Evidencias] <> 'OK' 
update tts_bs_mc_detail set NoCalc = 1 where MontoFactura = 0  

delete tts_bs_mc_detail where ( EvidenciasFaltan  = 0 and ReferenciasFaltan  = 0 and regresada = 0)
--delete tts_bs_mc_detail where ( ReferenciasFaltan  = 0)


insert into tts_bs_mc
select 
Proyecto,
Operador,
Cliente,
count(*) as ordenes,
round(sum(MontoFactura),0) as monto,
avg(IndexLag) as lag,
0,  --menos 5 Num
0,  --menos 5 Monto
0,  --menos 5 Perc
0,  --menos 5 Lag
0,  --menos 5 regresadas
0,  --mas   5 Num
0,  --mas   5 Monto
0,  --mas   5 Perc
0,  --mas   5 Lag
0   --mas   5 regresadas
,ord_EC
from tts_bs_mc_detail
group by Proyecto,Operador,Cliente,ord_EC

update tts_bs_mc

set [5Count]      = (select isnull(count(   *      ),0)   from tts_bs_mc_detail where tts_bs_mc_detail.Proyecto  = tts_bs_mc.Proyecto  and tts_bs_mc_detail.Operador = tts_bs_mc.Operador and tts_bs_mc_detail.Cliente = tts_bs_mc.Cliente and Estatus = '<5'),
    [5Monto]      = (select isnull(sum(MontoFactura),0)   from tts_bs_mc_detail where tts_bs_mc_detail.Proyecto  = tts_bs_mc.Proyecto and tts_bs_mc_detail.Operador = tts_bs_mc.Operador and tts_bs_mc_detail.Cliente = tts_bs_mc.Cliente and Estatus = '<5'),
    [5Perc]       = case when (select  sum(MontoFactura) from tts_bs_mc_detail where tts_bs_mc_detail.Proyecto  = tts_bs_mc.Proyecto and tts_bs_mc_detail.Operador = tts_bs_mc.Operador and tts_bs_mc_detail.Cliente = tts_bs_mc.Cliente) = 0 then 0 else
	                 round((select cast(isnull(sum(   MontoFactura     ),0) as float) from tts_bs_mc_detail where tts_bs_mc_detail.Proyecto  = tts_bs_mc.Proyecto  and tts_bs_mc_detail.Operador = tts_bs_mc.Operador and tts_bs_mc_detail.Cliente = tts_bs_mc.Cliente and Estatus = '<5')/
	                (select  cast(sum(MontoFactura) as float)  from tts_bs_mc_detail where tts_bs_mc_detail.Proyecto  = tts_bs_mc.Proyecto and tts_bs_mc_detail.Operador = tts_bs_mc.Operador and tts_bs_mc_detail.Cliente = tts_bs_mc.Cliente),2) end,
    [5Lag]        = (select isnull(avg(  IndexLag   ),0)   from tts_bs_mc_detail where tts_bs_mc_detail.Proyecto  = tts_bs_mc.Proyecto and tts_bs_mc_detail.Operador = tts_bs_mc.Operador and tts_bs_mc_detail.Cliente = tts_bs_mc.Cliente and Estatus  = '<5'),
	[Regresadas5] = (select isnull(sum(  regresada   ),0)   from tts_bs_mc_detail where tts_bs_mc_detail.Proyecto  = tts_bs_mc.Proyecto and tts_bs_mc_detail.Operador = tts_bs_mc.Operador and tts_bs_mc_detail.Cliente = tts_bs_mc.Cliente and Estatus  = '<5'),

	[mas5Count]       = (select isnull(count(   *      ),0)   from tts_bs_mc_detail where tts_bs_mc_detail.Proyecto  = tts_bs_mc.Proyecto and tts_bs_mc_detail.Operador = tts_bs_mc.Operador and tts_bs_mc_detail.Cliente = tts_bs_mc.Cliente and Estatus = '>5'),
    [mas5Monto]       = (select isnull(sum(MontoFactura),0)   from tts_bs_mc_detail where tts_bs_mc_detail.Proyecto  = tts_bs_mc.Proyecto and tts_bs_mc_detail.Operador = tts_bs_mc.Operador and tts_bs_mc_detail.Cliente = tts_bs_mc.Cliente and Estatus = '>5'),
    [mas5Perc]        =  case when (select  sum(MontoFactura) from tts_bs_mc_detail where tts_bs_mc_detail.Proyecto  = tts_bs_mc.Proyecto and tts_bs_mc_detail.Operador = tts_bs_mc.Operador and tts_bs_mc_detail.Cliente = tts_bs_mc.Cliente) = 0 then 0 else
	                  round((select cast(isnull(sum(   MontoFactura     ),0) as float) from tts_bs_mc_detail where tts_bs_mc_detail.Proyecto  = tts_bs_mc.Proyecto  and tts_bs_mc_detail.Operador = tts_bs_mc.Operador and tts_bs_mc_detail.Cliente = tts_bs_mc.Cliente and Estatus = '>5')/
	                  (select  cast(sum(MontoFactura) as float)  from tts_bs_mc_detail where tts_bs_mc_detail.Proyecto  = tts_bs_mc.Proyecto and tts_bs_mc_detail.Operador = tts_bs_mc.Operador and tts_bs_mc_detail.Cliente = tts_bs_mc.Cliente),2) end,
    [mas5Lag]         = (select isnull(avg(  IndexLag   ),0)   from tts_bs_mc_detail where tts_bs_mc_detail.Proyecto  = tts_bs_mc.Proyecto and tts_bs_mc_detail.Operador = tts_bs_mc.Operador and tts_bs_mc_detail.Cliente = tts_bs_mc.Cliente and Estatus  = '>5'),
	[Regresadasmas5]  = (select isnull(sum(  regresada   ),0)   from tts_bs_mc_detail where tts_bs_mc_detail.Proyecto  = tts_bs_mc.Proyecto and tts_bs_mc_detail.Operador = tts_bs_mc.Operador and tts_bs_mc_detail.Cliente = tts_bs_mc.Cliente and Estatus  = '>5')




 --pend	
if (@modo = 'snap')
 begin
   select @modo = 'snap'

  insert into [172.24.16.113].TMW_DWLive.dbo.mcperformance_bm
 
  select getdate(),
  Proyecto,
  Operador,
  Cliente,
  Ordenes,
  Lag,
  mas5Lag,
  mas5Count,
  mas5Monto,
  Monto,
  ord_EC
  from tts_bs_mc
  

end


/*

select * from [172.24.16.113].TMW_DWLive.dbo.mcperformance_bm
delete [172.24.16.113].TMW_DWLive.dbo.mcperformance_bm

*/

GO
