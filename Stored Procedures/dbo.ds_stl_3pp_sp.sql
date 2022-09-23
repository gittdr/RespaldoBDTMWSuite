SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[ds_stl_3pp_sp]
@ord_hdrnumber int,
@currency char(12)
as

/**
 * 
 * NAME:
 * dbo.ds_stl_3pp_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Proc for the datastore that gathers all revenue for the % of profit pay calculation.
 *
 * RETURNS:
 * dw result set
 *
 * PARAMETERS:
 * .....
 * 01 - @ord_hdrnumber int	order header number
 * 02 - @currency char(12)	Currency
 * 
 * REVISION HISTORY:
 * MRH 31225 2/10/06 3rd party pay % of profit.
 * BDH 36019 5/1/07 Use arg for default currency.
 **/

declare @i integer
declare @ord_currency char(12)
declare @ex_rate float
declare @ivh_currencydate datetime
declare @ivh_totalcharge float
DECLARE @max_date datetime

--MRH 11/22/05 Fixes
--Added the ivh_hdrnumber to get all invoices
--Make credit memo's negative
--Select the sum of the result
SELECT ord_hdrnumber,
	 ivh_hdrnumber,  
        (invoiceheader.ivh_totalcharge -
	(SELECT isnull(SUM(ivd_charge), 0) from invoicedetail where invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber and isnull(cht_itemcode, '') in (select cht_itemcode from chargetype where cht_basis = 'TAX'))) as ivh_totalcharge,
	ivh_currencydate,
	-- 36019 BDH using arg as default currency, not US$.
	--isnull(ivh_currency, 'US$') ivh_currency,
	isnull(ivh_currency, @currency) ivh_currency,
	ivh_creditmemo,
	IDENTITY (int) AS temp_id 
    into #temp FROM invoiceheader  
   WHERE ord_hdrnumber <> 0 and ord_hdrnumber in (select distinct ord_hdrnumber from stops where lgh_number in (select lgh_number from stops where ord_hdrnumber = @ord_hdrnumber)) --AND
	--invoiceheader.ivh_hdrnumber = (select max(ivh_hdrnumber) from invoiceheader a where a.ord_hdrnumber = invoiceheader.ord_hdrnumber)

-- Update the total with the converted currency if necessary.
select @i = (select min(temp_id) from #temp)
while @i <= (select max(temp_id) from #temp)
begin
	select @ord_currency = (select ivh_currency from #temp where temp_id = @i)
	if @ord_currency = 'UNK'
		-- 36019 BDH using arg as default currency, not US$.
		-- select @ord_currency = 'US$'
		select @ord_currency = @currency

	if @ord_currency <> @currency
	begin
		select @ivh_currencydate = (select ivh_currencydate from #temp where temp_id = @i)

		select @max_date = (select Max(cex_date)  from currency_exchange
		   	   where (cex_date <= @ivh_currencydate)
		   	   And (cex_from_curr = @ord_currency)
		   	   And (cex_to_curr = @currency))

		select @ex_rate = cex_rate 
			from currency_exchange
			where 	(cex_date = @max_date)
				And (cex_from_curr = @ord_currency)
				And (cex_to_curr = @currency)

		select @ivh_totalcharge = (select ivh_totalcharge from #temp where temp_id = @i)
		select @ex_rate = isnull(@ex_rate, 1)
		select @ivh_totalcharge = @ivh_totalcharge * @ex_rate
		update #temp set ivh_totalcharge = @ivh_totalcharge where temp_id = @i
	end	
	select @i = (select min(temp_id) from #temp where temp_id > @i)
end

select ord_hdrnumber, sum(ivh_totalcharge) as ivh_totalcharge from #temp group by ord_hdrnumber
drop table #temp
GO
GRANT EXECUTE ON  [dbo].[ds_stl_3pp_sp] TO [public]
GO
