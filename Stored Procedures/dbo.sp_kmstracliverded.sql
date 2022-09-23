SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc [dbo].[sp_kmstracliverded]
(@fecha varchar(8))
as

-- exec sp_kmstracliverded 2


select ord_tractor as tractor, 
sum(ord_totalmiles) as kmstotales,
count(ord_hdrnumber) as viajes
 from orderheader
where  ord_revtype4 = 'DED'
and ord_billto  in ('LIVERPOL', 'ALMLIVER')
and ord_status in ('STD','CMP')
and cast(month(ord_startdate) as varchar) +'-'+cast(year(ord_startdate) as varchar) = @fecha
group by ord_tractor

union

select '**TOTAL DEL MES***' as tractor, 
sum(ord_totalmiles) as kmstotales,
count(ord_hdrnumber) as viajes
 from orderheader
where  ord_revtype4 = 'DED'
and ord_billto  in ('LIVERPOL', 'ALMLIVER')
and ord_status in ('STD','CMP')
and cast(month(ord_startdate) as varchar) +'-'+cast(year(ord_startdate) as varchar) = @fecha


union

select '**KMS ADICIONALES***' as tractor, 
case  when sum(ord_totalmiles) > 95000 then  sum(ord_totalmiles)-95000 
else 0 end as kmstotales,0
 from orderheader
where  ord_revtype4 = 'DED'
and ord_billto  in ('LIVERPOL', 'ALMLIVER')
and ord_status in ('STD','CMP')
and cast(month(ord_startdate) as varchar) +'-'+cast(year(ord_startdate) as varchar) = @fecha

union

select '**ADICIONAL PORCIENTO***' as tractor, 
case  when sum(ord_totalmiles) > 95000 then  CONVERT(DECIMAL(10,2),(sum(cast(ord_totalmiles as float))-95000) / 95000 * 100)
else 0 end as kmstotales,
0
 from orderheader
where  ord_revtype4 = 'DED'
and ord_billto  in ('LIVERPOL', 'ALMLIVER')
and ord_status in ('STD','CMP')
and cast(month(ord_startdate) as varchar) +'-'+cast(year(ord_startdate) as varchar) = @fecha

order by tractor desc


GO
