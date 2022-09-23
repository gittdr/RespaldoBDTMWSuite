SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[vista_pp_tmw_multien_oo]
as

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
and ord_billto = 'MULTIEN'


GO
