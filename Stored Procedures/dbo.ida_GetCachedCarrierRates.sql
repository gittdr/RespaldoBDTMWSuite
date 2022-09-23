SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create proc [dbo].[ida_GetCachedCarrierRates]
	@ord_number varchar(12),
	@DefaultCurrency varchar(6),
	@BaseCurrency varchar(6)
as

declare @TheDate datetime
set @TheDate=GetDate()

-- Get the carrier rate info for the order
select 
	ocr.ord_number,
	ocr.car_id,
	ocr.ocr_rate,
	ocr.ocr_charge,
	case when isnull(car.car_currency, 'UNK') like 'UNK%' then @DefaultCurrency else car.car_currency end as currency
into #rates
from ordercarrierrates as ocr (NOLOCK)
left join carrier as car (NOLOCK)
on ocr.car_id = car.car_id
where ord_number = @ord_number
-- select * from #rates -- Show the table for debugging

-- Get the date of the most recent applicable exchange rate(s), as needed
select distinct
	ce.cex_from_curr,
	ce.cex_to_curr,
	max(ce.cex_date) as cex_date
into #exchangedates
from currency_exchange as ce (NOLOCK)
inner join #rates as r
on ce.cex_from_curr=r.currency
where
	ce.cex_to_curr=@BaseCurrency
	and cex_date<=@TheDate
group by ce.cex_to_curr, ce.cex_from_curr
-- select * from #exchangedates -- Show the table for debugging

-- Apply the exchange rate(s)
select
	r.*,
	case when r.currency=@BaseCurrency then 1.0 else ce.cex_rate end as cex_rate,
	case when r.currency=@BaseCurrency then null else ce.cex_date end as cex_date,
	(r.ocr_charge*case when r.currency=@BaseCurrency then 1.0 else ce.cex_rate end) as ConvertedCharge,
	@BaseCurrency as ConvertedCurrency
from #rates as r
left join #exchangedates as e
on	r.currency=e.cex_from_curr
left join currency_exchange as ce (NOLOCK)
on
	e.cex_from_curr=ce.cex_from_curr
	and e.cex_to_curr=ce.cex_to_curr
	and e.cex_date=ce.cex_date

drop table #rates
drop table #exchangedates


GO
GRANT EXECUTE ON  [dbo].[ida_GetCachedCarrierRates] TO [public]
GO
