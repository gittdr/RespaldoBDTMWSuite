SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[Casetas_efectivo]
as
select * from paydetail
where pyd_description like 'Caseta%'
AND pyt_itemcode NOT IN ( 'ANTOP', 'IVA2')
AND ord_hdrnumber IN (SELECT ord_hdrnumber FROM ORDERHEADER WHERE ord_bookdate > = '2020-01-01')
GO
