SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE view [dbo].[KmRecorridos_BI] as

select FORMAT (ord_startdate, 'yyyy-MM-dd')  AS FECHA, datepart(week, ord_startdate)-1 AS semana ,sum(ord_totalmiles) as miles, ord_revtype3,ord_billto
from orderheader
where 
ord_startdate > '2019-01-01' and ord_status = 'cmp'
group by  FORMAT (ord_startdate, 'yyyy-MM-dd') ,datepart(week, ord_startdate)-1 ,ord_revtype3,ord_billto



GO
