SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create proc [dbo].[actg_find_cht_prorate_data2_sp]
        @p_cht_itemcode varchar(6),
        @p_ivd_lghnum int,
        @p_ivh_ordhdrnum int,
        @p_ivd_num int,
        @p_final_alloc_method varchar(6) OUT,
        @p_final_alloc_criteria varchar(6) OUT,
        @p_final_alloc_data varchar(30) OUT
as
declare @sCustomProc varchar(255),
        @v_mov_number int,
	@v_lgh_number int,
	@sAccountingSystem varchar (255),
	@sreceivables_distributions int,
	@sProcUsesIvd varchar(30)

set nocount on 

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

-- Determine true allocation method and criteria
SELECT @p_final_alloc_data = ''
IF ISNULL(@p_final_alloc_method, '') = '' Begin
	SELECT @p_final_alloc_method = 'NOT'         -- Treat Null or blank method as Not Allocated.

	select @sAccountingSystem = Upper (gi_string1)
	from generalinfo
	where gi_name = 'AccountingSystem'
	select @sAccountingSystem = IsNull (@sAccountingSystem, '')

	IF @sAccountingSystem = 'GREATPLAINS' Begin
		select @sreceivables_distributions = receivables_distributions from gpdefaults
		select @sreceivables_distributions = IsNull (@sreceivables_distributions, 0)
		IF @sreceivables_distributions = 1 SELECT @p_final_alloc_method = 'ALLOC' /*set @p_final_alloc_method to Allocated if No allocation mehthod on charge type, Great Plains is Accounting System and and @receivables_distributions setting is 1*/
		
	End
END
IF ISNULL(@p_final_alloc_criteria, '') = '' SELECT @p_final_alloc_criteria = 'LOADML'  -- Treat Null or blank criteria as LOADML

--CGK Since @p_ivd_lghnum = -1 means unassigned, I changed the logic to > 0
--IF @p_final_alloc_method = 'ASNALL' AND @p_ivd_lghnum <> 0                    -- ASNALL with an assignment is treated as ASN
IF @p_final_alloc_method = 'ASNALL' AND @p_ivd_lghnum > 0
    SELECT @p_final_alloc_method = 'ASN'
--CGK changed logic to <= 0
--IF @p_final_alloc_method = 'ASNALL' AND @p_ivd_lghnum = 0                     -- ASNALL without an assignment is treated as ALLOC
IF @p_final_alloc_method = 'ASNALL' AND @p_ivd_lghnum <= 0
    SELECT @p_final_alloc_method = 'ALLOC'
--CGK Added logic for Pooled
IF @p_final_alloc_method = 'ASNPOL' AND @p_ivd_lghnum > 0			-- ASNPOL with an assignment is treated as ASN
    SELECT @p_final_alloc_method = 'ASN'
--CGK changed logic to <= 0
--IF @p_final_alloc_method = 'ASNALL' AND @p_ivd_lghnum = 0                     -- ASNPOL without an assignment is treated as POOLED
IF @p_final_alloc_method = 'ASNPOL' AND @p_ivd_lghnum <= 0
    SELECT @p_final_alloc_method = 'POOLED'

--CGK changed logic to <= 0
--IF @p_final_alloc_method = 'ALLOC' AND @p_ivh_ordhdrnum = 0                   -- An Allocation without an order is treated as ASN
IF @p_final_alloc_method = 'ALLOC' AND @p_ivh_ordhdrnum <= 0
    SELECT @p_final_alloc_method = 'ASN'
--CGK changed logic to <= 0
--IF @p_final_alloc_method = 'ASN' AND @p_ivd_lghnum = 0                        -- ASN without an assignment is treated as NOT
IF @p_final_alloc_method = 'ASN' AND @p_ivd_lghnum <= 0
    SELECT @p_final_alloc_method = 'NOT'
IF @p_final_alloc_method = 'ASN'                                              -- ASN has the legheader as its alloc data.
    SELECT @p_final_alloc_data = CONVERT(varchar(20), @p_ivd_lghnum)

IF @p_final_alloc_method = 'NOT' OR @p_final_alloc_method = 'ASN'             -- Criteria does not matter for NOT or ASN.  Set it to a constant.
    SELECT @p_final_alloc_criteria = 'LOADML'

-- If the custom allocation criteria is active, then redirect this call to the stored proc specified by the CustomRevAlloc General Info string 1 and leave.
IF @p_final_alloc_method = 'ALLOC' AND @p_final_alloc_criteria = 'CUSTOM'
    BEGIN
    SELECT @sCustomProc = ISNULL(gi_string1, ''), @sProcUsesIvd = ISNULL(gi_string2, 'N') FROM generalinfo WHERE gi_name = 'CustomRevAlloc'
    IF @sCustomProc = ''
        SELECT @p_final_alloc_method = 'ERROR', @p_final_alloc_criteria = 'ERROR', @p_final_alloc_data = 'CUSTOM w/o CustomRevAlloc'
    ELSE If @sProcUsesIvd = 'Y'
        EXEC @sCustomProc @p_cht_itemcode, @p_ivd_lghnum, @p_ivh_ordhdrnum, @p_ivd_num, @p_final_alloc_method OUT, @p_final_alloc_criteria OUT, @p_final_alloc_data OUT
	ELSE
        EXEC @sCustomProc @p_cht_itemcode, @p_ivd_lghnum, @p_ivh_ordhdrnum, @p_final_alloc_method OUT, @p_final_alloc_criteria OUT, @p_final_alloc_data OUT
    RETURN
    END

-- See if this allocation method, criteria, and data have already been looked up.
if exists (
  select * 
    from actg_temp_prorate 
    where actg_temp_prorate.sp_id = @@spid and
	  cht_allocation_method = @p_final_alloc_method and 
          cht_allocation_criteria = @p_final_alloc_criteria and 
          ISNULL(cht_allocation_data, '') = ISNULL(@p_final_alloc_data, ''))
    RETURN

-- For the TRIPML, XTRIPM, LOADML, and XLOADM routines, there might also be an entry saved for this specific legheader number.
if @p_final_alloc_method = 'ALLOC' 
    AND @p_final_alloc_criteria IN ('XTRIPM', 'TRIPM', 'XLOADM', 'LOADML')
    AND exists 
        (select *
           from actg_temp_prorate
          where actg_temp_prorate.sp_id = @@spid
	    AND cht_allocation_method = @p_final_alloc_method
            AND cht_allocation_criteria = @p_final_alloc_criteria
            AND ISNULL(cht_allocation_data, '') = CONVERT(varchar(20), @p_ivd_lghnum))
    BEGIN
    SELECT @p_final_alloc_data = CONVERT(varchar(20), @p_ivd_lghnum)
    RETURN
    END

-- No match found.  Need to lookup the proration quantities myself.

-- The NOT and ASN allocation methods are very simple.  1 record for everything.  If that is what this is, then generate that record and exit.
if @p_final_alloc_method = 'NOT' or @p_final_alloc_method = 'ASN' 
    BEGIN
    IF NOT exists (select * from actg_temp_excludedlegs where sp_id = @@spid and lgh_number = @p_ivd_lghnum) BEGIN
	    INSERT actg_temp_prorate (sp_id, cht_allocation_method, cht_allocation_criteria, cht_allocation_data, section_quantity, lgh_number)
	    VALUES (@@spid, @p_final_alloc_method, 'LOADML', @p_final_alloc_data, 1, @p_ivd_lghnum)
	    RETURN
	END
    END

-- CGK The POOLED allocation methods is simple at this point.  1 record for everything.  If that is what this is, then generate that record and exit.
if @p_final_alloc_method = 'POOLED'
    BEGIN
    INSERT actg_temp_prorate (sp_id, cht_allocation_method, cht_allocation_criteria, cht_allocation_data, section_quantity, lgh_number)
    VALUES (@@spid, @p_final_alloc_method, 'LOADML', @p_final_alloc_data, 1, @p_ivd_lghnum)
    RETURN
    END

-- For this version of the code, that just leaves the ALLOC method.  This is the only method that actually looks at the Criteria.
SELECT @p_final_alloc_data = '' -- This is actually already true, but just in case, since later code will rely on this...

-- If a trip custom allocation criteria is active, then pull the proc name from CustomRevAlloc General Info string 2
-- This is currently not implemented.  The developer who needs to use this first will code it.
IF @p_final_alloc_criteria = 'TRIPCU' OR @p_final_alloc_criteria = 'XTRIPC'
    BEGIN
    SELECT @sCustomProc = ISNULL(gi_string2, '') FROM generalinfo WHERE gi_name = 'CustomRevAlloc'
    IF @sCustomProc = ''
        BEGIN
        SELECT @p_final_alloc_method = 'ERROR', @p_final_alloc_criteria = 'ERROR', @p_final_alloc_data = @p_final_alloc_criteria + ' w/o CustomRevAlloc'
        RETURN
        END
    END

-- First determine what legheaders we need to look at.
IF @p_final_alloc_criteria = 'XLOADM' OR @p_final_alloc_criteria = 'XTRIPM' OR @p_final_alloc_criteria = 'XTRIPC'
    INSERT actg_temp_prorate (sp_id, cht_allocation_method, cht_allocation_criteria, cht_allocation_data, section_quantity, lgh_number)
           SELECT DISTINCT @@spid, @p_final_alloc_method, @p_final_alloc_criteria, @p_final_alloc_data, 0, alltripstops.lgh_number 
             FROM stops alltripstops INNER JOIN stops ordstops ON alltripstops.mov_number = ordstops.mov_number
            WHERE ordstops.ord_hdrnumber = @p_ivh_ordhdrnum
              AND ISNULL(alltripstops.lgh_number, 0) > 0
	     AND alltripstops.lgh_number NOT IN (select lgh_number from actg_temp_excludedlegs where sp_id = @@spid) /*PTS 32559 CGK 6/19/2006*/
ELSE IF @p_final_alloc_criteria = 'LOADML' OR @p_final_alloc_criteria = 'TRIPML' OR @p_final_alloc_criteria = 'TRIPCU'
    INSERT actg_temp_prorate (sp_id, cht_allocation_method, cht_allocation_criteria, cht_allocation_data, section_quantity, lgh_number)
           SELECT DISTINCT @@spid, @p_final_alloc_method, @p_final_alloc_criteria, @p_final_alloc_data, 0, stops.lgh_number 
             FROM stops INNER JOIN orderheader ON stops.mov_number = orderheader.mov_number
            WHERE orderheader.ord_hdrnumber = @p_ivh_ordhdrnum
              AND ISNULL(stops.lgh_number, 0) > 0
              AND iSNULL(orderheader.mov_number, 0) > 0
	      AND stops.lgh_number NOT IN (select lgh_number from actg_temp_excludedlegs where sp_id = @@spid) /*PTS 32559 CGK 6/19/2006*/
ELSE 
    BEGIN
    SELECT @p_final_alloc_method = 'ERROR', @p_final_alloc_data = 'Unknown Criteria:'+@p_final_alloc_criteria, @p_final_alloc_criteria = 'ERROR'
    RETURN
    END

-- Handle the trip custom criteria.
IF @p_final_alloc_criteria = 'TRIPCU' OR @p_final_alloc_criteria = 'XTRIPC'
    BEGIN
    EXEC @sCustomProc @p_cht_itemcode, @p_ivd_lghnum, @p_ivh_ordhdrnum, @p_final_alloc_method OUT, @p_final_alloc_criteria OUT, @p_final_alloc_data OUT
    RETURN
    END

IF @p_final_alloc_criteria = 'TRIPML' OR @p_final_alloc_criteria = 'XTRIPM'
    UPDATE actg_temp_prorate 
       SET section_quantity = 
           (SELECT ISNULL(SUM(stops.stp_lgh_mileage), 0) 
              FROM stops 
             WHERE stops.lgh_number = actg_temp_prorate.lgh_number
               AND ISNULL(stops.stp_lgh_mileage, 0) > 0
		AND stops.lgh_number NOT IN (select lgh_number from actg_temp_excludedlegs where sp_id = @@spid)) /*PTS 32559 CGK 6/19/2006*/
     WHERE actg_temp_prorate.sp_id = @@spid
       AND cht_allocation_method = @p_final_alloc_method
       AND cht_allocation_criteria = @p_final_alloc_criteria
       AND cht_allocation_data = @p_final_alloc_data

IF @p_final_alloc_criteria = 'LOADML' OR @p_final_alloc_criteria = 'XLOADM'
    BEGIN
    -- LOADML and XLOADM need the stop loadstatus to be set. Find a move which has not yet had its loadstatus'es checked.
    SELECT @v_mov_number = ISNULL(MIN(testlgh.mov_number), 0)
      FROM actg_temp_prorate testalloc WITH (NOLOCK)
           INNER JOIN legheader testlgh WITH (NOLOCK) on testalloc.lgh_number = testlgh.lgh_number
     WHERE testalloc.sp_id = @@spid
       AND testalloc.cht_allocation_method = @p_final_alloc_method
       AND testalloc.cht_allocation_criteria = @p_final_alloc_criteria
       AND testalloc.cht_allocation_data = @p_final_alloc_data
       AND NOT EXISTS (SELECT * 
                         FROM actg_temp_prorate searchalloc WITH (NOLOCK) 
                              INNER JOIN legheader searchlgh WITH (NOLOCK) ON searchalloc.lgh_number = searchlgh.lgh_number
                        WHERE searchalloc.sp_id = @@spid
			  AND searchalloc.cht_allocation_method = 'ALLOC' 
                          AND searchalloc.cht_allocation_criteria IN ('LOADML', 'XLOADM') 
                          AND (searchalloc.cht_allocation_method <> @p_final_alloc_method
                               OR searchalloc.cht_allocation_criteria <> @p_final_alloc_criteria
                               OR searchalloc.cht_allocation_data <> @p_final_alloc_data)
                          AND searchlgh.mov_number = testlgh.mov_number)
    WHILE @v_mov_number > 0
        BEGIN
    
        -- Go set that legheader's stop loadstatuses.
        EXEC dbo.UpdateStopLoadStatuses @v_mov_number
    
        -- And find the next unprocessed legheader.
        SELECT @v_mov_number = ISNULL(MIN(testlgh.mov_number), 0)
          FROM actg_temp_prorate testalloc WITH (NOLOCK)
               INNER JOIN legheader testlgh WITH (NOLOCK) on testalloc.lgh_number = testlgh.lgh_number
         WHERE testalloc.sp_id = @@spid
	   AND testlgh.mov_number > @v_mov_number
           AND testalloc.cht_allocation_method = @p_final_alloc_method
           AND testalloc.cht_allocation_criteria = @p_final_alloc_criteria
           AND testalloc.cht_allocation_data = @p_final_alloc_data
           AND NOT EXISTS (SELECT * 
                             FROM actg_temp_prorate searchalloc WITH (NOLOCK) 
                                  INNER JOIN legheader searchlgh WITH (NOLOCK) ON searchalloc.lgh_number = searchlgh.lgh_number
                            WHERE searchalloc.sp_id = @@spid
			      AND searchalloc.cht_allocation_method = 'ALLOC' 
                              AND searchalloc.cht_allocation_criteria IN ('LOADML', 'XLOADM') 
                              AND (searchalloc.cht_allocation_method <> @p_final_alloc_method
                                   OR searchalloc.cht_allocation_criteria <> @p_final_alloc_criteria
                                   OR searchalloc.cht_allocation_data <> @p_final_alloc_data)
                              AND searchlgh.mov_number = testlgh.mov_number)
        END

    -- Now that those are set, we can set the quantities.
    UPDATE actg_temp_prorate 
           SET section_quantity = 
           (SELECT ISNULL(SUM(stops.stp_lgh_mileage), 0) 
              FROM stops 
             WHERE stops.lgh_number = actg_temp_prorate.lgh_number
               AND ISNULL(stops.stp_lgh_mileage, 0) > 0
               AND stops.stp_loadstatus = 'LD'
	       AND stops.lgh_number NOT IN (select lgh_number from actg_temp_excludedlegs where sp_id = @@spid)) /*PTS 32559 CGK 6/19/2006*/
     WHERE actg_temp_prorate.sp_id = @@spid
       AND cht_allocation_method = @p_final_alloc_method
       AND cht_allocation_criteria = @p_final_alloc_criteria
       AND cht_allocation_data = @p_final_alloc_data
    END

-- If there are now any nonzero prorations, delete all the 0 ones and we are done.
IF EXISTS (SELECT * FROM actg_temp_prorate
            WHERE actg_temp_prorate.sp_id = @@spid
	      AND cht_allocation_method = @p_final_alloc_method
              AND cht_allocation_criteria = @p_final_alloc_criteria
              AND cht_allocation_data = @p_final_alloc_data
              AND section_quantity > 0)
    BEGIN
    DELETE FROM actg_temp_prorate
     WHERE actg_temp_prorate.sp_id = @@spid
       AND cht_allocation_method = @p_final_alloc_method
       AND cht_allocation_criteria = @p_final_alloc_criteria
       AND cht_allocation_data = @p_final_alloc_data
       AND section_quantity = 0
    RETURN
    END

-- Everything is 0!  Treat all entries as though they were equal (which they are!) by setting a constant quantity on all of them, and prorate accordingly.
UPDATE actg_temp_prorate 
   SET section_quantity = 1
 WHERE actg_temp_prorate.sp_id = @@spid
   AND cht_allocation_method = @p_final_alloc_method
   AND cht_allocation_criteria = @p_final_alloc_criteria
       AND cht_allocation_data = @p_final_alloc_data

IF (SELECT isnull(sum(section_quantity), 0) from actg_temp_prorate
     WHERE sp_id = @@spid
       AND cht_allocation_method = @p_final_alloc_method
       AND cht_allocation_criteria = @p_final_alloc_criteria
       AND cht_allocation_data = @p_final_alloc_data) <> 0
    RETURN

-- The only way we can get here is if there are no proration records at all!  The result is now going to be dependent on the legheader passed in.  Update the return values accordingly.
SELECT @p_final_alloc_data = CONVERT(varchar(20), @p_ivd_lghnum)

-- Does the legheader that was passed in exist?
IF EXISTS (SELECT * FROM legheader wHERE lgh_number = @p_ivd_lghnum AND @p_ivd_lghnum > 0 AND lgh_number NOT IN (select lgh_number from actg_temp_excludedlegs where sp_id = @@spid) /*PTS 32559 CGK 6/19/2006*/)
    BEGIN
    -- Just make an entry for that legheader.
    INSERT actg_temp_prorate (sp_id, cht_allocation_method, cht_allocation_criteria, cht_allocation_data, section_quantity, lgh_number)
    VALUES (@@spid, @p_final_alloc_method, @p_final_alloc_criteria, @p_final_alloc_data, 1, @p_ivd_lghnum)
    RETURN
    END

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

-- Done
RETURN
GO
GRANT EXECUTE ON  [dbo].[actg_find_cht_prorate_data2_sp] TO [public]
GO
