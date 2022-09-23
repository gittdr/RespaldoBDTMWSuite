SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[actg_calc_one_prorate_sp]
	@p_chargeroundoff int,      -- The number of decimal places to round off charges to.
	@p_rateroundoff int,        -- The number of decimal places to round off rates to.
	@p_ivh_number int,          -- The invoiceheader number to use in the resultset.
	@p_ivh_ordhdrnum int,       -- The orderheader number off the invoiceheader.  Used only if the chargetype specifies to.
	@p_ivh_curcode varchar(6),  -- The currency code off the invoiceheader.
	@p_ivd_number int,          -- The invoicedetail number to use in the resultset.
	@p_ivd_lghnum int,          -- The legheader number off the invoicedetail.
	@p_ivd_rate money,          -- The rate off the invoicedetail.
	@p_ivd_amount money,        -- The charge amount off the invoicedetail.
	@p_ivd_glnum varchar(32),   -- The gl number from the invoicedetail.
	@p_cht_itemcode varchar(6), -- The chargetype from the invoicedetail.
	@p_sequence int OUT         -- On call, specifies the last sequence before the one that should be on the first record returned.
                                    --          On return will be the last sequence returned.
as
set nocount on
set transaction isolation level read uncommitted
declare @alloc_method varchar(6),
        @alloc_criteria varchar(6),
        @alloc_data varchar(30),
        @alloc_groupby varchar(6),
        @alloc_total money,
        @alloc_count int

-- Collect the allocation data into #prorate
exec dbo.actg_find_cht_prorate_data2_sp @p_cht_itemcode, @p_ivd_lghnum, @p_ivh_ordhdrnum, @p_ivd_number, @alloc_method OUT, @alloc_criteria OUT, @alloc_data OUT

IF @alloc_method = 'ERROR'
    BEGIN
    RAISERROR ('Allocation data collection failed: %s', 16, 1, @alloc_data)
    RETURN
    END

-- Find out what the groupby criteria is.
select @alloc_groupby = ISNULL(cht_allocation_groupby, 'NONE') from chargetype where cht_itemcode = @p_cht_itemcode

-- Check if this criteria has already been collected.
if not exists (
    SELECT * from actg_temp_groupedprorates
     WHERE sp_id = @@spid
       AND cht_allocation_method = @alloc_method
       AND cht_allocation_criteria = @alloc_criteria
       AND cht_allocation_data = @alloc_data
       AND cht_allocation_groupby = @alloc_groupby)
    BEGIN
    -- This groupby has not yet been done.  Collect it now.
    IF @alloc_groupby = 'NONE'
        -- The simplest case.  All allocations are sent across unaltered.
        INSERT INTO actg_temp_groupedprorates (sp_id, cht_allocation_method, cht_allocation_criteria, cht_allocation_data, cht_allocation_groupby, prorate_quantity, prorate_minlgh, prorate_item)
        SELECT @@spid, @alloc_method, @alloc_criteria, @alloc_data, @alloc_groupby, section_quantity, lgh_number, isnull(section_item, lgh_number)
          FROM actg_temp_prorate
         WHERE sp_id = @@spid
	   AND cht_allocation_method = @alloc_method
           AND cht_allocation_criteria = @alloc_criteria
           AND cht_allocation_data = @alloc_data

    ELSE IF @alloc_groupby = 'DRV'
        -- Driver on the legheader
        INSERT INTO actg_temp_groupedprorates (sp_id, cht_allocation_method, cht_allocation_criteria, cht_allocation_data, cht_allocation_groupby, prorate_quantity, prorate_minlgh, prorate_item)
        SELECT @@spid, @alloc_method, @alloc_criteria, @alloc_data, @alloc_groupby, sum(section_quantity), min(actg_temp_prorate.lgh_number), CASE WHEN ISNULL(legheader.lgh_driver1, 'UNKNOWN') = '' THEN 'UNKNOWN' ELSE ISNULL(legheader.lgh_driver1, 'UNKNOWN') END
          FROM actg_temp_prorate
               LEFT OUTER JOIN legheader ON actg_temp_prorate.lgh_number = legheader.lgh_number
         WHERE actg_temp_prorate.sp_id = @@spid
	   AND cht_allocation_method = @alloc_method
           AND cht_allocation_criteria = @alloc_criteria
           AND cht_allocation_data = @alloc_data
         GROUP BY CASE WHEN ISNULL(legheader.lgh_driver1, 'UNKNOWN') = '' THEN 'UNKNOWN' ELSE ISNULL(legheader.lgh_driver1, 'UNKNOWN') END

    ELSE IF @alloc_groupby = 'TRC'
        -- Tractor on the legheader
        INSERT INTO actg_temp_groupedprorates (sp_id, cht_allocation_method, cht_allocation_criteria, cht_allocation_data, cht_allocation_groupby, prorate_quantity, prorate_minlgh, prorate_item)
        SELECT @@spid, @alloc_method, @alloc_criteria, @alloc_data, @alloc_groupby, sum(section_quantity), min(actg_temp_prorate.lgh_number), CASE WHEN ISNULL(legheader.lgh_tractor, 'UNKNOWN') = '' THEN 'UNKNOWN' ELSE ISNULL(legheader.lgh_tractor, 'UNKNOWN') END
          FROM actg_temp_prorate
              LEFT OUTER JOIN legheader ON actg_temp_prorate.lgh_number = legheader.lgh_number
         WHERE actg_temp_prorate.sp_id = @@spid
	   AND cht_allocation_method = @alloc_method
           AND cht_allocation_criteria = @alloc_criteria
           AND cht_allocation_data = @alloc_data
         GROUP BY CASE WHEN ISNULL(legheader.lgh_tractor, 'UNKNOWN') = '' THEN 'UNKNOWN' ELSE ISNULL(legheader.lgh_tractor, 'UNKNOWN') END

    ELSE IF @alloc_groupby = 'DRVT1'
        -- Tractor on the legheader
        INSERT INTO actg_temp_groupedprorates (sp_id, cht_allocation_method, cht_allocation_criteria, cht_allocation_data, cht_allocation_groupby, prorate_quantity, prorate_minlgh, prorate_item)
        SELECT @@spid, @alloc_method, @alloc_criteria, @alloc_data, @alloc_groupby, sum(section_quantity), min(actg_temp_prorate.lgh_number), manpowerprofile.mpp_type1
          FROM actg_temp_prorate
               LEFT OUTER JOIN legheader ON actg_temp_prorate.lgh_number = legheader.lgh_number
               LEFT OUTER JOIN manpowerprofile ON legheader.lgh_driver1 = manpowerprofile.mpp_id
         WHERE actg_temp_prorate.sp_id = @@spid
	   AND cht_allocation_method = @alloc_method
           AND cht_allocation_criteria = @alloc_criteria
           AND cht_allocation_data = @alloc_data
         GROUP BY manpowerprofile.mpp_type1

    ELSE -- Unrecognized GroupBy
        RAISERROR ('Unrecognized GroupBy %s', 16, 1, @alloc_groupby)
    END

-- Sequence the entries.
UPDATE actg_temp_groupedprorates
   SET prorate_sequence = (
           SELECT COUNT(*)
             FROM actg_temp_groupedprorates sub WITH (NOLOCK)
            WHERE (sub.prorate_minlgh < actg_temp_groupedprorates.prorate_minlgh
                  OR sub.prorate_minlgh = actg_temp_groupedprorates.prorate_minlgh AND sub.gpr_identity < actg_temp_groupedprorates.gpr_identity)
	      AND sub.sp_id = @@spid
              AND sub.cht_allocation_method = @alloc_method
              AND sub.cht_allocation_criteria = @alloc_criteria
              AND sub.cht_allocation_data = @alloc_data
              AND sub.cht_allocation_groupby = @alloc_groupby)
 WHERE actg_temp_groupedprorates.sp_id = @@spid
   AND cht_allocation_method = @alloc_method
   AND cht_allocation_criteria = @alloc_criteria
   AND cht_allocation_data = @alloc_data
   AND cht_allocation_groupby = @alloc_groupby

-- Calculate the total prorate quantity and get the number of sequences used.
SELECT @alloc_total = SUM(prorate_quantity), @alloc_count = MAX(prorate_sequence)
  FROM actg_temp_groupedprorates
 WHERE actg_temp_groupedprorates.sp_id = @@spid
   AND cht_allocation_method = @alloc_method
   AND cht_allocation_criteria = @alloc_criteria
   AND cht_allocation_data = @alloc_data
   AND cht_allocation_groupby = @alloc_groupby

-- Calculate the rate and amount for all entries but the last.
UPDATE actg_temp_groupedprorates
   SET prorate_rate = ROUND(prorate_quantity * @p_ivd_rate / @alloc_total, @p_rateroundoff),
       prorate_amount = ROUND(prorate_quantity * @p_ivd_amount / @alloc_total, @p_chargeroundoff)
 WHERE actg_temp_groupedprorates.sp_id = @@spid
   AND cht_allocation_method = @alloc_method
   AND cht_allocation_criteria = @alloc_criteria
   AND cht_allocation_data = @alloc_data
   AND cht_allocation_groupby = @alloc_groupby
   AND prorate_sequence <> @alloc_count

-- The last entry gets the remaining balance, whatever that may be.
UPDATE actg_temp_groupedprorates
   SET prorate_rate =
           @p_ivd_rate -
           (SELECT ISNULL(SUM(other.prorate_rate), 0)
              FROM actg_temp_groupedprorates other
             WHERE sp_id = @@spid
	       AND other.cht_allocation_method = @alloc_method
               AND other.cht_allocation_criteria = @alloc_criteria
               AND cht_allocation_data = @alloc_data
               AND cht_allocation_groupby = @alloc_groupby
               AND prorate_sequence <> @alloc_count),
       prorate_amount =
           @p_ivd_amount -
           (SELECT ISNULL(SUM(other.prorate_amount), 0)
              FROM actg_temp_groupedprorates other
             WHERE sp_id = @@spid
	       AND other.cht_allocation_method = @alloc_method
               AND other.cht_allocation_criteria = @alloc_criteria
               AND cht_allocation_data = @alloc_data
               AND cht_allocation_groupby = @alloc_groupby
               AND prorate_sequence <> @alloc_count)
 WHERE actg_temp_groupedprorates.sp_id = @@spid
   AND cht_allocation_method = @alloc_method
   AND cht_allocation_criteria = @alloc_criteria
   AND cht_allocation_data = @alloc_data
   AND cht_allocation_groupby = @alloc_groupby
   AND prorate_sequence = @alloc_count

--CGK IF allocation method is pooled then return a cht_itemcode of pooled.
IF @alloc_method = 'POOLED'
	SELECT @p_cht_itemcode = 'POOLED'

-- OK, now have all the data together.  Time to return the results!
SELECT @@spid as sp_id,
    @p_ivh_number                  ivh_number,
    @p_ivd_number                  ivd_number,
    prorate_minlgh                 lgh_number,
    NULL                           thr_id,
    prorate_quantity               ral_proratequantity,
    @alloc_total                   ral_totalprorates,
    prorate_rate                   ral_rate,
    prorate_amount                 ral_amount,
    @p_ivh_curcode                 cur_code,
    CONVERT(money, 1.0)            ral_conversion_rate,
    @p_cht_itemcode                cht_itemcode,
    prorate_sequence + @p_sequence ral_sequence,
    prorate_rate                   ral_converted_rate,
    prorate_amount                 ral_converted_amount,
    @p_ivd_glnum                   ral_glnum,
	prorate_item                   ral_prorateitem
  FROM actg_temp_groupedprorates
 WHERE actg_temp_groupedprorates.sp_id = @@spid
   AND cht_allocation_method = @alloc_method
   AND cht_allocation_criteria = @alloc_criteria
   AND cht_allocation_data = @alloc_data
   AND cht_allocation_groupby = @alloc_groupby

-- Update @p_sequence
SELECT @p_sequence = @p_sequence + @alloc_count + 1

-- Done
RETURN
set nocount off
GO
GRANT EXECUTE ON  [dbo].[actg_calc_one_prorate_sp] TO [public]
GO
