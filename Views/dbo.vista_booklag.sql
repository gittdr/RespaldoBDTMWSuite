SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[vista_booklag]

as

select ord_billto, ord_bookedby, ord_bookdate, ord_Startdate, datediff(dd,ord_bookdate,ord_Startdate) as difdias 

from tmwsuite.dbo.orderheader
where year(ord_bookdate) >=2014
GO
