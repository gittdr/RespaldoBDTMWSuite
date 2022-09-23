SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[actg_calcproratesorder_sp]
	@p_ord_hdrnumber int,
	@p_chargeroundoff int,
	@p_rateroundoff int,
        @p_alloc_sequence int OUT

as
set nocount on 

declare @ivd_sequence int,
	@ivh_hdrnumber int,       -- The orderheader number off the invoiceheader.  Used only if the chargetype specifies to.
	@ivh_curcode varchar(6),  -- The currency code off the invoiceheader.
	@ivd_number int,          -- The invoicedetail number to use in the resultset.
	@ivd_lghnum int,          -- The legheader number off the invoicedetail.
	@ivd_rate money,          -- The rate off the invoicedetail.
	@ivd_amount money,        -- The charge amount off the invoicedetail.
	@ivd_glnum varchar(32),   -- The gl number from the invoicedetail.
	@cht_itemcode varchar(6),  -- The chargetype from the invoicedetail.
	@count integer,
	@countcredit integer

-- The following two tables are used as a data cache and as a workspace by the helper routines that construct the entries for each detail.
-- This table collects the proration quantities.  There will be a collection of records for each cht_itemcode with a unique combination of 
--    cht_allocation_method and cht_allocation_criteria and in some cases additionally the data used by that rule.

--PTS 34889 CGK 10/27/2006 Remove Temp Tables since causing a recompile
delete from actg_temp_prorate where sp_id = @@spid
-- create table #prorate(	
--         cht_allocation_method varchar (6) NULL,  -- The chargetype allocation method for which this quantity was collected.
--         cht_allocation_criteria varchar(6) NULL, -- The chargetype allocation criteria for which this quantity was collected.
--         cht_allocation_data varchar(30) NULL,    -- The chargetype allocation data subset for which this quantity was collected (for example, for ASN* loads, this would be the matched legheader, if there was one).
-- 	section_quantity float NULL,             -- The quantity for this proration.
-- 	lgh_number int NULL)                     -- The legheader this quantity was collected for.

-- This table is used to collect the grouped proration quantities.  There will be a collection of records for each cht_itemcode with a unique combination of
--    cht_allocation_method, cht_allocation_criteria, and cht_allocation_groupby.

--PTS 34889 CGK 10/27/2006 Remove Temp Tables since causing a recompile
delete from actg_temp_groupedprorates where sp_id = @@spid
-- create table #groupedprorates(
--         gpr_identity int identity(1,1),         -- A primary key field used when sequencing.
--         cht_allocation_method varchar(6) NULL,   -- The chargetype allocation method for which this quantity was collected.
--         cht_allocation_criteria varchar(6) NULL, -- The chargetype allocation criteria for which this quantity was collected.
--         cht_allocation_data varchar(30) NULL,    -- The chargetype allocation data subset for which this quantity was collected (for example, for ASN* loads, this would be the matched legheader, if there was one).
--         cht_allocation_groupby varchar(6) NULL,  -- The chargetype allocation groupby for which this quantity was collected.
-- 	prorate_quantity float NULL,	            -- The quantity for this proration.
-- 	prorate_minlgh int NULL,                 -- One of the legheaders this quantity was collected for.
-- 
--         -- The remaining columns are not actually part of the cache, but instead prevent the necessity of an additional calculation table.
--         prorate_rate money NULL,            -- The rate that this entry will end up with.
--         prorate_amount money NULL,          -- The amount that this entry will end up with.
--         prorate_sequence int  NULL)               -- The sequence that this entry will end up with.

--PTS 34889 CGK 10/27/2006 Remove Temp Tables since causing a recompile
delete from actg_temp_excludedlegs where sp_id = @@spid
--create table #excludedlegs (lgh_number int NULL)

-- Init allocation sequences
SELECT @p_alloc_sequence = 1

-- Get the invoiceheader data needed.
SELECT @ivh_curcode = ord_currency
  FROM orderheader
 WHERE ord_hdrnumber = @p_ord_hdrnumber


select @ivh_hdrnumber = IsNull (Min (ivh_hdrnumber), 0) from invoicedetail where IsNull (ivh_hdrnumber, 0) >= 0 AND ord_hdrnumber = @p_ord_hdrnumber
select @ivh_hdrnumber = IsNull (@ivh_hdrnumber, -1) 


while @ivh_hdrnumber > -1
begin
	-- Skip Invoices with Credit Memo's and Credit Memo's
	IF @ivh_hdrnumber > 0 Begin
		select @count = count (*) from invoiceheader where ord_hdrnumber = @p_ord_hdrnumber and ivh_cmrbill_link = @ivh_hdrnumber and ivh_creditmemo = 'Y'
		select @countcredit = count (*) from invoiceheader where ivh_hdrnumber = @ivh_hdrnumber and ivh_creditmemo = 'Y'
	End
	Else Begin
		select @count = 0
		select @countcredit = 0
	End
	IF @count = 0 AND @countcredit = 0 Begin

		delete from actg_temp_excludedlegs where sp_id = @@spid --PTS 32559 CGK 6/19/2006
		-- Find the first sequence.
		SELECT @ivd_sequence = MIN(ivd_sequence) from invoicedetail where ivh_hdrnumber = @ivh_hdrnumber and ord_hdrnumber = @p_ord_hdrnumber
		
		-- Iterate through each sequence
		WHILE (ISNULL(@ivd_sequence, 0) <> 0)
		 BEGIN
		
		    -- Find the first detail for that sequence.
		    SELECT @ivd_number = MIN(ivd_number) FROM invoicedetail WHERE ivh_hdrnumber = @ivh_hdrnumber AND ivd_sequence = @ivd_sequence and ord_hdrnumber = @p_ord_hdrnumber
		
		    -- Iterate through each detail for each sequence
		    WHILE (ISNULL(@ivd_number, 0) <> 0)
		        BEGIN
		        -- Collect detail info
		        SELECT @ivd_lghnum = ivd_paylgh_number,
		               @ivd_rate = ivd_rate,
		               @ivd_amount = ivd_charge,
		               @ivd_glnum = ivd_glnum,
		               @cht_itemcode = cht_itemcode
		          FROM invoicedetail
		         WHERE ivd_number = @ivd_number
		
		        -- Build detail records
		        INSERT actg_temp_workrevalloc (sp_id, ivh_number, ivd_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_sequence, ral_converted_rate, ral_converted_amount, ral_glnum)
		          EXEC dbo.actg_calc_one_prorate_sp @p_chargeroundoff, @p_rateroundoff, @ivh_hdrnumber, @p_ord_hdrnumber, @ivh_curcode, @ivd_number, @ivd_lghnum, @ivd_rate, @ivd_amount, @ivd_glnum, @cht_itemcode, @p_alloc_sequence OUT
		
		        -- Find the next detail for the sequence
		        SELECT @ivd_number = MIN(ivd_number) FROM invoicedetail WHERE ivh_hdrnumber = @ivh_hdrnumber AND ivd_sequence = @ivd_sequence AND ord_hdrnumber = @p_ord_hdrnumber AND ivd_number > @ivd_number
		        END
		
		    -- Find the next sequence
		    SELECT @ivd_sequence = MIN(ivd_sequence) from invoicedetail where ivh_hdrnumber = @ivh_hdrnumber AND ivd_sequence > @ivd_sequence
		  END
		exec dbo.actg_calcpooled_sp @ivh_hdrnumber, @p_ord_hdrnumber, @p_chargeroundoff, @p_rateroundoff, @ivh_curcode
	End

	select @ivh_hdrnumber = IsNull (Min (ivh_hdrnumber), -1) from invoicedetail where ord_hdrnumber = @p_ord_hdrnumber and IsNull (ivh_hdrnumber, 0) > @ivh_hdrnumber
	select @ivh_hdrnumber = IsNull (@ivh_hdrnumber, -1) 
End

set nocount off
GO
GRANT EXECUTE ON  [dbo].[actg_calcproratesorder_sp] TO [public]
GO
