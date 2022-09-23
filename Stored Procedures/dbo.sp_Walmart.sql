SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--select getdate()
CREATE procedure [dbo].[sp_Walmart] 
--prueba de ejecucion  exec sp_Walmart '2013-10-21', '2013-10-22'

--variables que recibira el sp como parametros con su tipo de dato
@fechaini datetime, 
@fechafin datetime

--sintaxis como obligatoria y el count off para no alojar memoria
as --inicio codigo del sp

BEGIN

	SET NOCOUNT ON

	--creamos la tabla temporal seguida de sus tipos de datos de cada columna
	CREATE TABLE  #tempwl (	fecha datetime,	factura varchar(10), referencia varchar(13), orden int, subtotal int, total int)

	--insertamos los valores del select en la tabla temporal
	insert into #tempwl

select ivh_billdate,ivh_ref_number,ivh_invoicenumber,orderheader.ord_hdrnumber,ivh_charge,ivh_totalcharge 
from orderheader left join invoiceheader on invoiceheader.ord_hdrnumber = orderheader. ord_hdrnumber   where  ivh_billto = 'WALMART'  and (ivh_billdate between @fechaini and @fechafin)
and orderheader.ord_hdrnumber in (select invoiceheader.ord_hdrnumber from invoiceheader  where ivh_invoicenumber not like 'S%') and ivh_billto = 'WALMART'    
--and ivh_invoicestatus in ('HLD','HLA')
and orderheader.ord_status != 'CAN' and ivh_invoicenumber not like 'S%'

    --updateamos el valor fecha
     update #tempwl set fecha =  (select ivh_billdate
from orderheader left join invoiceheader on invoiceheader.ord_hdrnumber = orderheader. ord_hdrnumber   where  ivh_billto = 'WALMART'  and (ivh_billdate between @fechaini and @fechafin)
and orderheader.ord_hdrnumber in (select invoiceheader.ord_hdrnumber from invoiceheader  where ivh_invoicenumber not like 'S%') and ivh_billto = 'WALMART'    
--and ivh_invoicestatus in ('HLD','HLA')
and orderheader.ord_status != 'CAN' and ivh_invoicenumber not like 'S%')
     
    --updateamos el valor de referencia
    update #tempwl set referencia = (select ivh_ref_number
from orderheader left join invoiceheader on invoiceheader.ord_hdrnumber = orderheader. ord_hdrnumber   where  ord_billto = 'WALMART'  and (ivh_billdate between @fechaini and @fechafin)
and orderheader.ord_hdrnumber in (select invoiceheader.ord_hdrnumber from invoiceheader  where ivh_invoicenumber not like 'S%') and ivh_billto = 'WALMART'    
--and ivh_invoicestatus in ('HLD','HLA')
and orderheader.ord_status != 'CAN' and ivh_invoicenumber not like 'S%')
  
   --updateamos el valor de factura
   update #tempwl set factura = (select ivh_invoicenumber
from orderheader left join invoiceheader on invoiceheader.ord_hdrnumber = orderheader. ord_hdrnumber   where  ord_billto = 'WALMART'  and (ivh_billdate between @fechaini and @fechafin)
and orderheader.ord_hdrnumber in (select invoiceheader.ord_hdrnumber from invoiceheader  where ivh_invoicenumber not like 'S%') and ivh_billto = 'WALMART'    
--and ivh_invoicestatus in ('HLD','HLA')
and orderheader.ord_status != 'CAN' and ivh_invoicenumber not like 'S%')

   --updateamos el valor de orden
   update #tempwl set orden = (select orderheader.ord_hdrnumber
from orderheader left join invoiceheader on invoiceheader.ord_hdrnumber = orderheader. ord_hdrnumber   where  ord_billto = 'WALMART'  and (ivh_billdate between @fechaini and @fechafin)
and orderheader.ord_hdrnumber in (select invoiceheader.ord_hdrnumber from invoiceheader  where ivh_invoicenumber not like 'S%') and ivh_billto = 'WALMART'    
--and ivh_invoicestatus in ('HLD','HLA')
and orderheader.ord_status != 'CAN' and ivh_invoicenumber not like 'S%')

   --updateamos el valor de subtotal
   update #tempwl set subtotal = (select ivh_charge
from orderheader left join invoiceheader on invoiceheader.ord_hdrnumber = orderheader. ord_hdrnumber   where  ord_billto = 'WALMART'  and (ivh_billdate between @fechaini and @fechafin)
and orderheader.ord_hdrnumber in (select invoiceheader.ord_hdrnumber from invoiceheader  where ivh_invoicenumber not like 'S%') and ivh_billto = 'WALMART'    
--and ivh_invoicestatus in ('HLD','HLA')
and orderheader.ord_status != 'CAN' and ivh_invoicenumber not like 'S%')

   --updateamos el valor de total
   update #tempwl set total = (select ivh_totalcharge
from orderheader left join invoiceheader on invoiceheader.ord_hdrnumber = orderheader. ord_hdrnumber   where  ord_billto = 'WALMART'  and (ivh_billdate between @fechaini and @fechafin)
and orderheader.ord_hdrnumber in (select invoiceheader.ord_hdrnumber from invoiceheader  where ivh_invoicenumber not like 'S%') and ivh_billto = 'WALMART'    
--and ivh_invoicestatus in ('HLD','HLA')
and orderheader.ord_status != 'CAN' and ivh_invoicenumber not like 'S%')
    

	--hacemos la consulta final de la tabla temporal agrupando por el campo que creamos de fecha, y hacemos la suma de kms
	select fecha,factura,referencia,orden,subtotal,total from #tempwl where fecha between @fechaini and @fechafin order by Fecha

	--no olvidar darle drop para sacarla de memoria
	drop table #tempwl
END
GO
