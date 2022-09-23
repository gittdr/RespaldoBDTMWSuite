SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[actg_calcprorates_sp]
	@p_ivh_hdrnumber int,
	@p_chargeroundoff int,
	@p_rateroundoff int,
        @p_alloc_sequence int OUT

as
set nocount on 

declare @ivd_sequence int,
	@ivh_ordhdrnum int,       -- The orderheader number off the invoiceheader.  Used only if the chargetype specifies to.
	@ivh_curcode varchar(6),  -- The currency code off the invoiceheader.
	@ivd_number int,          -- The invoicedetail number to use in the resultset.
	@ivd_lghnum int,          -- The legheader number off the invoicedetail.
	@ivd_rate money,          -- The rate off the invoicedetail.
	@ivd_amount money,        -- The charge amount off the invoicedetail.
	@ivd_glnum varchar(32),   -- The gl number from the invoicedetail.
	@cht_itemcode varchar(6)  -- The chargetype from the invoicedetail.
declare @targetivh int, @IVDCount int, @CMIvdSeq int, @TgtIvdSeq int

-- An internal temp table.to track related details on credit memos and their targets.
CREATE TABLE #ivd_relationships (
	main_ivd int,
	target_ivd int,
	main_seq int,
	target_seq int)

-- The following two tables are used as a data cache and as a workspace by the helper routines that construct the entries for each detail.
--    Both tables should really be in the tmp db, but need to be shared with other procs (which cannot be done without recompile issues).
-- This table collects the proration quantities.  There will be a collection of records for each cht_itemcode with a unique combination of 
--    cht_allocation_method and cht_allocation_criteria and in some cases additionally the data used by that rule.
--        create table actg_temp_prorate(	
--         cht_allocation_method varchar (6) NULL,  -- The chargetype allocation method for which this quantity was collected.
--         cht_allocation_criteria varchar(6) NULL, -- The chargetype allocation criteria for which this quantity was collected.
--         cht_allocation_data varchar(30) NULL,    -- The chargetype allocation data subset for which this quantity was collected (for example, for ASN* loads, this would be the matched legheader, if there was one).
--         section_quantity float NULL,             -- The quantity for this proration.
--         lgh_number int NULL)                     -- The legheader this quantity was collected for.
-- This table is used to collect the grouped proration quantities.  There will be a collection of records for each cht_itemcode with a unique combination of
--    cht_allocation_method, cht_allocation_criteria, and cht_allocation_groupby.
--        create table actg_temp_groupedprorates(
--         gpr_identity int identity(1,1),         -- A primary key field used when sequencing.
--         cht_allocation_method varchar(6) NULL,   -- The chargetype allocation method for which this quantity was collected.
--         cht_allocation_criteria varchar(6) NULL, -- The chargetype allocation criteria for which this quantity was collected.
--         cht_allocation_data varchar(30) NULL,    -- The chargetype allocation data subset for which this quantity was collected (for example, for ASN* loads, this would be the matched legheader, if there was one).
--         cht_allocation_groupby varchar(6) NULL,  -- The chargetype allocation groupby for which this quantity was collected.
--         prorate_quantity float NULL,	            -- The quantity for this proration.
--         prorate_minlgh int NULL,                 -- One of the legheaders this quantity was collected for.
-- 
--         -- The remaining columns are not actually part of the cache, but instead prevent the necessity of an additional calculation table.
--         prorate_rate money NULL,            -- The rate that this entry will end up with.
--         prorate_amount money NULL,          -- The amount that this entry will end up with.
--         prorate_sequence int  NULL)               -- The sequence that this entry will end up with.

-- Clean up the temp tables.
delete from actg_temp_prorate where sp_id = @@spid
delete from actg_temp_groupedprorates where sp_id = @@spid
delete from actg_temp_excludedlegs where sp_id = @@spid

-- Before we start repopulating the actg_temp tables, check if the invoice is a standard credit memo (an exact reversal of an invoice).
--    If so, the allocation should not be recalculated, but instead should just be a reversal of the original one.
if (select COUNT(*) from invoiceheader main inner join invoiceheader target on main.ivh_applyto = target.ivh_invoicenumber 
where main.ivh_creditmemo = 'Y' and main.ivh_totalcharge = -target.ivh_totalcharge and main.ivh_hdrnumber = @p_ivh_hdrnumber) = 1
	BEGIN
	-- Looks like it might be a reversal.  Get the target's ivh_hdrnumber.
	SELECT @targetivh = target.ivh_hdrnumber 
		FROM invoiceheader main inner join invoiceheader target on main.ivh_applyto = target.ivh_invoicenumber 
		where main.ivh_hdrnumber = @p_ivh_hdrnumber and main.ivh_totalcharge = -target.ivh_totalcharge 
	-- Then build a correspondence table for the details.
	SELECT @IVDCount = COUNT(*) FROM invoicedetail where ivh_hdrnumber = @p_ivh_hdrnumber
	if (select count(distinct ivd_sequence) FROM invoicedetail where ivh_hdrnumber = @p_ivh_hdrnumber) = @IVDCount AND
		(select count(distinct ivd_sequence) FROM invoicedetail where ivh_hdrnumber = @targetivh) = @IVDCount AND
		(select count(*) FROM invoicedetail where ivh_hdrnumber = @targetivh) = @IVDCount AND
		(Select count(*) from revenueallocation where revenueallocation.ivh_number = @targetivh) > 0
		BEGIN
		-- The count of both sets of invoicedetails must match, and all of them must have distinct ivd sequences for 
		--	correspondence table builder routine to work.
		WHILE(1=1)
			BEGIN
			SELECT @CMIvdSeq = min(ivd_sequence) FROM invoicedetail WHERE 
				ivh_hdrnumber = @p_ivh_hdrnumber AND
				not exists (Select * from #ivd_relationships WHERE main_seq = ivd_sequence)
			IF @CMIvdSeq IS NULL BREAK
			SELECT @TgtIvdSeq = min(tgt.ivd_sequence) FROM invoicedetail tgt, invoicedetail cm WHERE 
				cm.ivd_sequence = @CMIvdSeq AND
				tgt.ivh_hdrnumber = @targetivh AND
				cm.ivh_hdrnumber = @p_ivh_hdrnumber AND
				cm.ivd_charge = -tgt.ivd_charge AND
				cm.cht_itemcode = tgt.cht_itemcode AND
				not exists (Select * from #ivd_relationships WHERE target_seq = tgt.ivd_sequence)
			IF @TgtIvdSeq IS NULL BREAK
			INSERT INTO #ivd_relationships (main_ivd, target_ivd, main_seq, target_seq) 
			SELECT cm.ivd_number, tgt.ivd_number, @CMIvdSeq, @TgtIvdSeq FROM invoicedetail cm, invoicedetail tgt WHERE
				cm.ivd_sequence = @CMIvdSeq AND
				cm.ivh_hdrnumber = @p_ivh_hdrnumber AND
				tgt.ivd_sequence = @TgtIvdSeq AND
				tgt.ivh_hdrnumber = @targetivh
			END
		-- Assuming that the correspondence table built properly (1 to 1 to 1 correspondence between ivd's distinct ivd's in table and
		--    distinct relationsship ivd's in table).
		if (SELECT COUNT(*) FROM #ivd_relationships) = @IVDCount

		BEGIN
			-- Then just cut the credit memo revenue allocations, as reversals of those of the original, then get out.
			INSERT INTO revenueallocation (ivh_number, ivd_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_sequence, ral_converted_rate, ral_converted_amount, ral_glnum, ral_chtrule, ral_distindex, ral_prorateitem)
				SELECT @p_ivh_hdrnumber, #ivd_relationships.main_ivd, revenueallocation.lgh_number, revenueallocation.thr_id, -revenueallocation.ral_proratequantity, -revenueallocation.ral_totalprorates, revenueallocation.ral_rate, -revenueallocation.ral_amount, revenueallocation.cur_code, revenueallocation.ral_conversion_rate, revenueallocation.cht_itemcode, revenueallocation.ral_sequence, revenueallocation.ral_converted_rate, -revenueallocation.ral_converted_amount, revenueallocation.ral_glnum, revenueallocation.ral_chtrule, revenueallocation.ral_distindex, revenueallocation.ral_prorateitem
				FROM revenueallocation INNER JOIN #ivd_relationships ON revenueallocation.ivd_number = #ivd_relationships.target_ivd and revenueallocation.ivh_number = @targetivh
			RETURN
			END
		END
	END

-- Init allocation sequences
SELECT @p_alloc_sequence = 1

-- Get the invoiceheader data needed.
SELECT @ivh_ordhdrnum = ord_hdrnumber,
       @ivh_curcode = ivh_currency
  FROM invoiceheader
 WHERE ivh_hdrnumber = @p_ivh_hdrnumber

-- Find the first sequence.
SELECT @ivd_sequence = MIN(ivd_sequence) from invoicedetail where ivh_hdrnumber = @p_ivh_hdrnumber

-- Iterate through each sequence
WHILE (ISNULL(@ivd_sequence, 0) <> 0)
    BEGIN

    -- Find the first detail for that sequence.
    SELECT @ivd_number = MIN(ivd_number) FROM invoicedetail WHERE ivh_hdrnumber = @p_ivh_hdrnumber AND ivd_sequence = @ivd_sequence

    -- Iterate through each detail for each sequence
    WHILE (ISNULL(@ivd_number, 0) <> 0)
        BEGIN
        -- Collect detail info
        SELECT @ivd_lghnum = ivd_paylgh_number,
               @ivd_rate = ivd_rate,
               @ivd_amount = ivd_charge,
               @ivd_glnum = '',
               @cht_itemcode = cht_itemcode
          FROM invoicedetail
         WHERE ivd_number = @ivd_number


	/*PTS 34769 KPM 10/09/2006*/
	SELECT @ivd_glnum = cht_glnum
	FROM chargetype
	WHERE cht_itemcode = @cht_itemcode
        -- Build detail records
        INSERT actg_temp_workrevalloc (sp_id, ivh_number, ivd_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_sequence, ral_converted_rate, ral_converted_amount, ral_glnum, ral_prorateitem)
          EXEC dbo.actg_calc_one_prorate_sp @p_chargeroundoff, @p_rateroundoff, @p_ivh_hdrnumber, @ivh_ordhdrnum, @ivh_curcode, @ivd_number, @ivd_lghnum, @ivd_rate, @ivd_amount, @ivd_glnum, @cht_itemcode, @p_alloc_sequence OUT

        -- Find the next detail for the sequence
        SELECT @ivd_number = MIN(ivd_number) FROM invoicedetail WHERE ivh_hdrnumber = @p_ivh_hdrnumber AND ivd_sequence = @ivd_sequence AND ivd_number > @ivd_number
        END

    -- Find the next sequence
    SELECT @ivd_sequence = MIN(ivd_sequence) from invoicedetail where ivh_hdrnumber = @p_ivh_hdrnumber AND ivd_sequence > @ivd_sequence
    END

exec dbo.actg_calcpooled_sp @p_ivh_hdrnumber, @ivh_ordhdrnum, @p_chargeroundoff, @p_rateroundoff, @ivh_curcode

set nocount off
GO
GRANT EXECUTE ON  [dbo].[actg_calcprorates_sp] TO [public]
GO
