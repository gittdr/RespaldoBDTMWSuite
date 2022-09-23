SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[ds_stl_3pp_tripseg_sp]
@ord_hdrnumber int,
@currency char(12)
as
/**
 * 
 * NAME:
 * dbo.ds_stl_3pp_tripseg_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Proc for the datastore that gathers all pay for the % of profit pay calculation.
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
 * JG  37850 9/20/07 patch to imporve performance. Add ord_hdrnumber > 0.
 * PTS 53531 8/25/2010 - IF paytype.pyt_exclude_3pp = 'Y' then exclude from 3PP calculation
**/

declare @i integer
declare @pyd_currency char(12)
declare @ex_rate float
declare @ivh_currencydate datetime
declare @pyd_amount float
DECLARE @max_date datetime
Declare @SyncFetchStatus as int

SELECT lgh_number,   
         pyd_amount,   
         pyd_pretax,   
-- 36019 BDH Getting default currency from ini in nvo_autotrippay which is now in @currency.
	 isnull(pyd_currency, @currency) pyd_currency,
--         isnull(pyd_currency, 'US$') pyd_currency,
--         isnull(pyd_currency, 'CDN$') pyd_currency,
         pyd_status,
          -- PTS 53531 - add itemcode & pyt_exclude_3pp 
         pyt_itemcode,    
         (Select Isnull(paytype.pyt_exclude_3pp,'N') from paytype where paytype.pyt_itemcode = paydetail.pyt_itemcode) 'pyt_exclude_3pp'
    INTO #temp  
    FROM paydetail
-- PTS 42323 where lgh_number in (select lgh_number from legheader where mov_number in (select distinct mov_number from stops where ord_hdrnumber = @ord_hdrnumber and ord_hdrnumber > 0 and asgn_type <> 'TPR'))
    where lgh_number in (select lgh_number from legheader where mov_number in (select distinct mov_number from stops where ord_hdrnumber = @ord_hdrnumber and ord_hdrnumber > 0) and asgn_type <> 'TPR')

Delete from #temp where pyt_exclude_3pp = 'Y'		-- PTS 53531    

select @ivh_currencydate = (select max(ivh_currencydate) from invoiceheader where ord_hdrnumber = @ord_hdrnumber)
select @ivh_currencydate = isnull(@ivh_currencydate,(select max(ivh_deliverydate) from invoiceheader where ord_hdrnumber = @ord_hdrnumber))

DECLARE CurrencyCursor CURSOR FOR
Select pyd_amount, pyd_currency from #temp

Open CurrencyCursor

Fetch next from CurrencyCursor
into @pyd_amount, @pyd_currency
select @SyncFetchStatus = @@fetch_status

-- Update the total with the converted currency if necessary.
While @SyncFetchStatus = 0
begin
	-- 36019 BDH.  Default goes to arg.
	if @pyd_currency = 'UNK'
		select @pyd_currency = @currency

	if @pyd_currency <> @currency
	begin
--		if @pyd_currency = 'UNK'
--			select @pyd_currency = 'US$'
--			select @pyd_currency = 'CDN$'
	
		select @max_date = (select Max(cex_date)  from currency_exchange
			where (cex_date <= @ivh_currencydate)
			And (cex_from_curr = @pyd_currency)
			And (cex_to_curr = @currency))
	
		select @ex_rate = cex_rate
			from currency_exchange
			where 	(cex_date = @max_date)
				And (cex_from_curr = @pyd_currency)
				And (cex_to_curr = @currency)
	
			select @ex_rate = isnull(@ex_rate, 1)
			select @pyd_amount = @pyd_amount * @ex_rate
			update #temp set pyd_amount = @pyd_amount where current of CurrencyCursor
	end
	Fetch next from CurrencyCursor
	into @pyd_amount, @pyd_currency
	select @SyncFetchStatus = @@fetch_status
end

    -- PTS 53531    
    --SELECT * FROM #TEMP
    SELECT lgh_number, pyd_amount, pyd_pretax, pyd_currency, pyd_status FROM #TEMP    
    
    Close CurrencyCursor
    Deallocate CurrencyCursor
    DROP TABLE #TEMP
GO
GRANT EXECUTE ON  [dbo].[ds_stl_3pp_tripseg_sp] TO [public]
GO
