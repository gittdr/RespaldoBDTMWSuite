SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



--select top 500 * from vTTSTMW_OrderFinalTrip
CREATE View [dbo].[vTTSTMW_OrderFinalTrip]

as

select ord_number as [OrderNumber],
       ord_shipper as [Shipper],
       ord_consignee as [Consignee],
       DriverID = (select a.lgh_driver1 from legheader a WITH (NOLOCK) where a.lgh_number = (select max(c.lgh_number) from stops c WITH (NOLOCK) where c.stp_arrivaldate = (select max(b.stp_arrivaldate) from stops b WITH (NOLOCK) where b.ord_hdrnumber = orderheader.ord_hdrnumber))),
       ord_startdate as [Ship Date],
       ord_completiondate as [Delivery Date]

       
From   orderheader WITH (NOLOCK)




GO
GRANT SELECT ON  [dbo].[vTTSTMW_OrderFinalTrip] TO [public]
GO
