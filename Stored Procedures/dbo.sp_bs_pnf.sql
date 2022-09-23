SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/**********************************
Autor: Emilio Olvera Yanez
Fecha: 25 oct 2018 2.2pm COR

SP que llena las tablas para generar reporte 
de estado de PNF general

Sentencia de prueba

exec [sp_bs_pnf]

exec [sp_bs_pnf] 'snap'


select * from tts_bs_pnf_detail where evidencias <> 'Mesa'
select * from tts_bs_pnf


************************************/


CREATE proc [dbo].[sp_bs_pnf] (@modo varchar(5) = NULL)

as

delete tts_bs_pnf_detail
delete tts_bs_pnf



insert into tts_bs_pnf_detail

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
		  'Fact' Estado,
		  case when datediff(dd,o.ord_completiondate,getdate()) <=10 then '10' 
		       when datediff(dd,o.ord_completiondate,getdate()) between 11 and 20 then '20'
			   when datediff(dd,o.ord_completiondate,getdate()) between 21 and 30 then '30'
			   when datediff(dd,o.ord_completiondate,getdate()) > 30 then 'mas'
		     end as DtBucket

from orderheader o 
where ord_status = 'CMP'  
and o.ord_hdrnumber not in (select ord_hdrnumber from invoiceheader where ivh_invoicestatus  in ('XFR','NTP','PPD','MFE') )
and ord_invoicestatus not in ('XIN','MFE','AMC')
order by cliente,billlag desc 

---SE actualiza la tabla con el detalle de  las evidencias faltantes-------------
update tts_bs_pnf_detail set evidencias = 

 isnull(STUFF((SELECT '; ' + DocTypeName 

          FROM AllPaperworkView

          where OrderNumber = Orden

          and Required = 'Yes' and ReceivedMultiple = 'N'

          FOR XML PATH('')), 1, 1, ''), 'OK')
----------------------------------------------------------------------------------


update tts_bs_pnf_detail set EvidenciasFaltan = 1 where [Evidencias] <> 'OK' 
update tts_bs_pnf_detail set NoCalc = 1 where MontoFactura = 0  

update tts_bs_pnf_detail set Estado = 'Mesa'   where (EstatusFactura = 'AVL' and EvidenciasFaltan = 1)
update tts_bs_pnf_detail set Estado = 'Mesa'   where (EvidenciasFaltan = 1)
update tts_bs_pnf_detail set Estado = 'Mesa'   where (referenciasFaltan= 1)
update tts_bs_pnf_detail set Estado = 'Fact'   where  ( (select distinct count(not_viewlevel) from notes where  ntb_table = 'orderheader' and not_type = 'EVI'  and nre_tablekey = tts_bs_pnf_detail.Orden) = 2 )
update tts_bs_pnf_detail set Estado = 'Mesa'   where  ( (select distinct count(not_viewlevel) from notes where  ntb_table = 'orderheader' and not_type = 'EVI'  and nre_tablekey = tts_bs_pnf_detail.Orden) = 1 )


insert into tts_bs_pnf

select 
cliente,

count(*) as ordenes,
round(sum(MontoFactura),0) as monto,
avg(BillLag) as lag,

0 as ordenesMesa,
0 as montoMesa,
0 as lagMesa,

0 as ordenesFact,
0 as montoFact,
0 as lagFact,

0 as ordenesMesadiez,
0 as montoMesadiez,
0 as lagMesadiez,
0 as ordenesFactdiez,
0 as montoFactdiez,
0 as lagFactdiez,

0 as ordenesMesaveinte,
0 as montoMesaveinte,
0 as lagMesaveinte,
0 as ordenesFactveinte,
0 as montoFactveinte,
0 as lagFactveinte,

0 as ordenesMesatreinta,
0 as montoMesatreinta,
0 as lagMesatreinta,
0 as ordenesFacttreinta,
0 as montoFacttreinta,
0 as lagFacttreinta,

0 as ordenesMesamas,
0 as montoMesamas,
0 as lagMesamas,
0 as ordenesFactmas,
0 as montoFactmas,
0 as lagFacttmas

from tts_bs_pnf_detail
group by cliente

update tts_bs_pnf 

set 

    ordenesMesa        = (select isnull(count(   *      ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and Estado = 'Mesa'),
    montoMesa          = (select isnull(sum(MontoFactura),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and Estado = 'Mesa'),
    lagMesa            = (select isnull(avg(  BillLag   ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and Estado = 'Mesa'),

	ordenesFact        = (select isnull(count(   *      ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and Estado = 'Fact'),
    montoFact          = (select isnull(sum(MontoFactura),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and Estado = 'Fact'),
    lagFact            = (select isnull(avg(  BillLag   ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and Estado = 'Fact'),

    ordenesMesadiez    = (select isnull(count(   *      ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '10' and Estado = 'Mesa'),
    montoMesadiez      = (select isnull(sum(MontoFactura),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '10' and Estado = 'Mesa'),
    lagMesadiez        = (select isnull(avg(  BillLag   ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '10' and Estado = 'Mesa'),

	ordenesFactdiez    = (select isnull(count(   *      ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '10' and Estado = 'Fact'),
    montoFactdiez      = (select isnull(sum(MontoFactura),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '10' and Estado = 'Fact'),
    lagFactdiez        = (select isnull(avg(  BillLag   ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '10' and Estado = 'Fact'),

	ordenesMesaveinte  = (select isnull(count(   *      ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '20' and Estado = 'Mesa'),
    montoMesaveinte    = (select isnull(sum(MontoFactura),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '20' and Estado = 'Mesa'),
    lagMesaveinte      = (select isnull(avg(  BillLag   ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '20' and Estado = 'Mesa'),

	ordenesFactveinte  = (select isnull(count(   *      ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '20' and Estado = 'Fact'),
    montoFactveinte    = (select isnull(sum(MontoFactura),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '20' and Estado = 'Fact'),
    lagFactveinte      = (select isnull(avg(  BillLag   ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '20' and Estado = 'Fact'),
	
	ordenesMesatreinta = (select isnull(count(   *      ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '30' and Estado = 'Mesa'),
    montoMesatreinta   = (select isnull(sum(MontoFactura),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '30' and Estado = 'Mesa'),
    lagMesatreinta     = (select isnull(avg(  BillLag   ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '30' and Estado = 'Mesa'),

	ordenesFacttreinta = (select isnull(count(   *      ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '30' and Estado = 'Fact'),
    montoFacttreinta   = (select isnull(sum(MontoFactura),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '30' and Estado = 'Fact'),
    lagFacttreinta     = (select isnull(avg(  BillLag   ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = '30' and Estado = 'Fact'),

	ordenesMesamas     = (select isnull(count(   *      ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = 'mas' and Estado = 'Mesa'),
    montoMesamas       = (select isnull(sum(MontoFactura),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = 'mas' and Estado = 'Mesa'),
    lagMesamas         = (select isnull(avg(  BillLag   ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = 'mas' and Estado = 'Mesa'),

	ordenesFactmas     = (select isnull(count(   *      ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = 'mas' and Estado = 'Fact'),
    montoFactmas       = (select isnull(sum(MontoFactura),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = 'mas' and Estado = 'Fact'),
    lagFactmas         = (select isnull(avg(  BillLag   ),0) from tts_bs_pnf_detail where tts_bs_pnf_detail.Cliente  = tts_bs_pnf.cliente and dtbucket = 'mas' and Estado = 'Fact')





	
/*

if (@modo = 'snap')
 begin
   select @modo = 'snap'

  insert into [172.24.16.113].TMW_DWLive.dbo.invoiceperformance_bm
 
  select getdate(),
  Cliente,
  Ordenes,
  Lag,
  Monto
  from tts_bs_invoice

end

^*/
GO
