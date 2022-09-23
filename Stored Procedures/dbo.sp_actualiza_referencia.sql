SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE  proc [dbo].[sp_actualiza_referencia]
        @invoice varchar(12),
        @referencia varchar(6),
        @p_ivh_ordhdrnum int,
	@time timestamp
as
 
/*
-- Some minor parameter cleanup so I don't have to isnull them everywhere else (-1 makes sure they cannot actually match anything).
SELECT @p_ivd_lghnum = ISNULL(@p_ivd_lghnum, -1), @p_ivh_ordhdrnum = isnull(@p_ivh_ordhdrnum, -1)

-- On the other hand, itemcode is absolutely required.
if ISNULL(@p_cht_itemcode, '') = ''
    BEGIN
    -- If it is missing, pass some bogus data back to caller.
    SELECT @p_final_alloc_method = 'ERROR', @p_final_alloc_criteria = 'ERROR', @p_final_alloc_data = 'ChargeType not set'
    RETURN
    END

-- Get desired allocation method and criteria.
select @p_final_alloc_method = cht_allocation_method, @p_final_alloc_criteria = cht_allocation_criteria 
  from chargetype 
 where chargetype.cht_itemcode = @p_cht_itemcode

-- The legheader that was passed in does not exist.  Are there any legheaders associated with the order?
IF EXISTS (SELECT * FROM stops WHERE ord_hdrnumber = @p_ivh_ordhdrnum AND ISNULL(lgh_number, 0)>0 AND stops.lgh_number NOT IN (select lgh_number from actg_temp_excludedlegs where sp_id = @@spid) /*PTS 32559 CGK 6/19/2006*/)
    BEGIN
    -- It does.  Take any one and say it has a quantity of 1.
    INSERT actg_temp_prorate (sp_id, cht_allocation_method, cht_allocation_criteria, cht_allocation_data, section_quantity, lgh_number)
    SELECT @@spid, @p_final_alloc_method, @p_final_alloc_criteria, @p_final_alloc_data, 1, min(lgh_number)
    FROM stops WHERE ord_hdrnumber = @p_ivh_ordhdrnum AND ISNULL(lgh_number, 0) > 0

    RETURN
    END

-- OK, time to give up.  Just make one for no legheader.
INSERT actg_temp_prorate (sp_id, cht_allocation_method, cht_allocation_criteria, cht_allocation_data, section_quantity, lgh_number)
VALUES (@@spid, @p_final_alloc_method, @p_final_alloc_criteria, @p_final_alloc_data, 1, 0)
*/
-- Done
RETURN

GO
