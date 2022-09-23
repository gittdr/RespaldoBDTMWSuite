SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[RevenueConvoy360] as

select car.car_name,oh.*,(ord_totalcharge)/1.12 as Cargo from orderheader oh inner join carrier car on car.car_id = oh.ord_carrier
where ord_carrier <> 'unknown'
and ord_completiondate >= '2018-01-01' and ord_completiondate <= '2020-01-31'
and ord_status = 'CMP' and ord_billto <> 'SAE' and ord_carrier in (select car_id from carrier
where car_type3 = 'conv' )
--order by 1 desc



GO
