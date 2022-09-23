SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


--select top 500 * from vSSRSRB_OrderFinalTrip
CREATE View [dbo].[vSSRSRB_OrderFinalTrip]

as
/**
 *
 * NAME:
 * dbo.vSSRSRB_OrderFinalTrip
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View Creation for SSRS Report Library
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 MREED created 
 **/
select ord_number as [Order Number],
		ord_hdrnumber as [Order Header Number],
       ord_shipper as [Shipper ID],
       ord_consignee as [Consignee ID],
       DriverID = (select a.lgh_driver1 
			from legheader a WITH (NOLOCK) 
			where a.lgh_number = (select max(c.lgh_number) from stops c WITH (NOLOCK) 
										where c.stp_arrivaldate = (select max(b.stp_arrivaldate) 
													from stops b WITH (NOLOCK) where b.ord_hdrnumber = orderheader.ord_hdrnumber))),
       ord_startdate as [Ship Date],
       (Cast(Floor(Cast(ord_startdate as float))as smalldatetime)) as [Ship Date Only],
       ord_completiondate as [Delivery Date],
       (Cast(Floor(Cast(ord_completiondate as float))as smalldatetime)) as [Delivery Date Only]

       
From   orderheader WITH (NOLOCK)



GO
GRANT DELETE ON  [dbo].[vSSRSRB_OrderFinalTrip] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_OrderFinalTrip] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_OrderFinalTrip] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_OrderFinalTrip] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_OrderFinalTrip] TO [public]
GO
