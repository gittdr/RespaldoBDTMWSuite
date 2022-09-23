SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
ejemplo consulta:

exec sp_factconceptos 'SIGMAALI','2016-05-01','2016-05-23'
*/

CREATE proc [dbo].[sp_factconceptos] 
(@billto varchar (10),
@fechaini datetime,
@fechafin datetime)

as
(
select cht_itemcode, sum(ivd_charge) as monto from invoicedetail (nolock)
where ivd_billto = @billto
and ivh_hdrnumber in (select ivh_hdrnumber from invoiceheader (nolock)
where ivh_billto = @billto and ivh_deliverydate  between @fechaini and @fechafin)
group by cht_itemcode


)


GO
