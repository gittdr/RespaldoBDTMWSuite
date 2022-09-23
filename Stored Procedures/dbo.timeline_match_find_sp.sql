SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[timeline_match_find_sp]
	@poh_identity int,
	@tlh_number	int output
AS

/**
 * 
 * NAME:
 * dbo.timeline_match_find_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Link part orders to the orders on which they ride
 *
 * RETURNS:
 * timeline number
 *
 * PARAMETERS:
 * 001 - @poh_identity int
 *       This parameter indicates the specific part order to link
 *       zero or null indicates link all non-linked part orders
 * 
 * REVISION HISTORY:
 * 08/10/05	LOR	PTS# 29095
 * 09/09/05	MRH	PTS# 29449
 * 09/16/05	MRH 	PTS# 29823 Added 'UNK' to the dock	
 * 09/23/2005 - MRH Change charindex on dock to =
 *
 **/

Declare @min_po int
declare @branch varchar(12)
declare @supplier varchar(8)
declare @plant varchar(8)
declare @dock varchar(8)
declare @jit int
declare @sequence int
declare @deliverdate datetime
declare @pickupdate datetime
declare @dow_del int
declare @dow_pup int
--declare @tlh_number int
declare @v_user VARCHAR(255)
declare @v_MFST VARCHAR(15)
declare @v_msg VARCHAR(255)
declare @tld_master_ordnum varchar(12)
declare @tld_origin varchar(8)
declare @tld_dest varchar(8)
declare @min_sequence int
declare @tld_org_arrive datetime
declare @tld_dest_arrive datetime
declare @tlh_direction char(1)
declare @por_begindate datetime
declare @por_enddate datetime
declare @lead int
declare @tld_arrive_orig_lead int
declare @tld_arrive_dest_lead int
declare @tld_depart_orig_lead int
declare @tld_arrive_lead int
declare @holidays int
declare @org_arrive_time datetime
declare @tlh_saturday char(1)
declare @tlh_sunday char(1)
declare @chardate char(10)
declare @chartime char (8)
declare @chardatetime char(22)
declare @ord_hdrnumber int
declare @Active VARCHAR(6) -- 30581
declare @EffeiveBasis CHAR(1)


	EXEC gettmwuser @v_user OUTPUT

	--------
	-- match timeline on Branch, supplier, plant, dock, Jit or Seq, day of week
	--------
	select @branch = poh_branch, 
		@supplier = poh_supplier, 
		@plant = poh_plant, 
		@dock = poh_dock, 
		@jit = IsNull(poh_jittime, 0), 
		@sequence = IsNull(poh_sequence, 0), 
		@deliverdate = poh_deliverdate,
		@pickupdate = poh_pickupdate, 
		@dow_del = datepart(dw, poh_deliverdate),
		@dow_pup = datepart(dw, poh_pickupdate),
--		@tlh_direction = tlh_direction
		@tlh_direction = poh_direction,
		@EffeiveBasis = poh_effective_basis
	from partorder_header 
--	LEFT OUTER JOIN timeline_header ON poh_timelineid = tlh_number
	where poh_identity = @poh_identity
		AND poh_status <> '999'

	if @EffeiveBasis = 'P'
		select @tlh_direction = 'P'
	if @EffeiveBasis = 'D'
		select @tlh_direction = 'D'


	UPDATE partorder_header
	SET poh_direction = 'P'
	WHERE	poh_identity = @poh_identity
	AND	poh_deliverdate = '19000101 00:00:00'
	AND 	poh_direction IS NULL

	UPDATE partorder_header
	SET poh_direction = 'D'
	WHERE	poh_identity = @poh_identity
	AND	poh_pickupdate = '19000101 00:00:00'
	AND 	poh_direction IS NULL


-- 29449
	-------
	--- Validate that the supplier is active
	-------
-- 30581
/*	if (SELECT COUNT(*)
		  FROM extra_info_data ex1 (NOLOCK) 
		 INNER JOIN extra_info_data ex2 (NOLOCK) 
		    ON ex1.extra_id = ex2.extra_id 
		   AND ex1.tab_id = ex2.tab_id
		   AND ex1.col_row = ex2.col_row
		   AND ex1.col_id = 1  --column number for branch
		   AND ex2.col_id = 2  --column number for supplier ID
		   AND ex2.table_key = ex1.table_key
		 WHERE ex1.extra_id = 5 
		   AND ex1.tab_id = 1
		   AND ex1.col_data = @branch -- Branch
		   AND ex2.table_key = @supplier ) > 0 -- Supplier ID
*/
	SELECT @Active = alias.cmp_othertype1
	FROM company alias
	INNER JOIN company_alternates ca ON ca.ca_alt = alias.cmp_id
	WHERE alias.cmp_revtype1 = @branch
	  AND ca.ca_id = @supplier

	IF @Active = NULL
	BEGIN
		SELECT @v_mfst = poh_refnum
			FROM partorder_header
			WHERE poh_identity = @poh_identity
		SET @v_msg = 'Alias not found for part order.  Reference: ' + @v_mfst + '  Branch: ' + @branch + '  Supplier: ' + @supplier

		INSERT INTO tts_errorlog (
			  err_batch  
			, err_user_id 
			, err_message                                                                                                                                                                                                                                                    
			, err_date                                               
			, err_number  
			, err_title
			, err_type)
		VALUES (
			  0
			, LEFT(@v_user, 10)
			, @v_msg
			, GETDATE()
			, 10112
			, 'Timeline Match'
			, 'TLM')
	END
	ELSE
	IF @Active = 'INACTV'
	BEGIN
		UPDATE partorder_header
		SET poh_status = '950'
		WHERE poh_identity = @poh_identity
	END
	ELSE
-- 30581 END

	BEGIN -- Active shipper
		-------
		-- Check for a single day timeline
		-------
	-- 29317
		IF @pickupdate <> '1/1/1900' AND @deliverdate <> '1/1/1900' 
			IF @tlh_direction = 'P'
				SET @deliverdate = '1/1/1900'
			ELSE IF @tlh_direction = 'D'
				SET @pickupdate = '1/1/1900'
			
	--	if @pickupdate is null
		if @pickupdate = '1/1/1900'
			Select @tlh_number = max(tlh_number) 
			from timeline_header 
			where tlh_branch = @branch and 
					tlh_supplier = @supplier and
					tlh_plant = @plant and 
	--				tlh_dock = @dock and
					(tlh_dock = @dock or @dock = '' or @dock IS NULL or @dock = 'UNK' or tlh_dock = '' or tlh_dock IS NULL) and
					DATEADD(DAY, DATEDIFF(DAY, 0, @deliverdate), 0) = tlh_effective and DATEADD(DAY, DATEDIFF(DAY, 0, @deliverdate), 0) = tlh_expires
					--tlh_effective = @deliverdate and tlh_expires = @deliverdate
					--and (IsNull(tlh_jittime, 0) = @jit or IsNull(tlh_sequence, 0) = @sequence)
					-- 30581
					--and @jit = tlh_jittime and @sequence = tlh_sequence
					and ISNULL(@jit, 0) = ISNULL(tlh_jittime, 0) and ISNULL(@sequence, 0) = ISNULL(tlh_sequence, 0)
					and tlh_dow = @dow_del 
					and tlh_direction = 'D'
		else
			Select @tlh_number = max(tlh_number) 
			from timeline_header 
			where tlh_branch = @branch and 
					tlh_supplier = @supplier and
					tlh_plant = @plant and 
	--				tlh_dock = @dock and
					(tlh_dock = @dock or @dock = '' or @dock IS NULL or @dock = 'UNK' or tlh_dock = '' or tlh_dock IS NULL) and
					DATEADD(DAY, DATEDIFF(DAY, 0, @pickupdate), 0) = tlh_effective and DATEADD(DAY, DATEDIFF(DAY, 0, @pickupdate), 0) = tlh_expires
					--tlh_effective = @pickupdate and tlh_expires = @pickupdate
					-- 30581
					-- and @jit = tlh_jittime and @sequence = tlh_sequence
					and ISNULL(@jit, 0) = ISNULL(tlh_jittime, 0) and ISNULL(@sequence, 0) = ISNULL(tlh_sequence, 0)
					and tlh_dow = @dow_pup 
					and tlh_direction = 'P'
		-------
		-- No single day timeline, check for a specific day of the week timeline
		-------
		if @tlh_number is null
		begin
	--	29317
	--		if @pickupdate is null
			if @pickupdate = '1/1/1900'
				Select @tlh_number = max(tlh_number) 
				from timeline_header 
				where @branch = tlh_branch and 
					@supplier = tlh_supplier
					and @plant = tlh_plant and 
	--				@dock = tlh_dock
					(tlh_dock = @dock or @dock = '' or @dock IS NULL or @dock = 'UNK' or tlh_dock = '' or tlh_dock IS NULL)
					and @deliverdate >= tlh_effective and 
					@deliverdate <= tlh_expires
					-- 30581
					-- and @jit = tlh_jittime and @sequence = tlh_sequence
					and ISNULL(@jit, 0) = ISNULL(tlh_jittime, 0) and ISNULL(@sequence, 0) = ISNULL(tlh_sequence, 0)
					and @dow_del = tlh_dow and 
					tlh_direction = 'D'
			else
				Select @tlh_number = max(tlh_number) 
				from timeline_header 
				where @branch = tlh_branch and 
					@supplier = tlh_supplier
					and @plant = tlh_plant and 
	--				@dock = tlh_dock
					(tlh_dock = @dock or @dock = '' or @dock IS NULL or @dock = 'UNK' or tlh_dock = '' or tlh_dock IS NULL)
					and @pickupdate >= tlh_effective and 
					@pickupdate <= tlh_expires
					-- 30581
					-- and @jit = tlh_jittime and @sequence = tlh_sequence
					and ISNULL(@jit, 0) = ISNULL(tlh_jittime, 0) and ISNULL(@sequence, 0) = ISNULL(tlh_sequence, 0)
					and @dow_pup = tlh_dow and 
					tlh_direction = 'P'
		end
	
		---------
		-- If a timeline is not found for a specific day of the week try for any day.
		---------
		if @tlh_number is null
		begin
	--	29317
	--		if @pickupdate is null
			if @pickupdate = '1/1/1900'
				Select @tlh_number = max(tlh_number) 
				from timeline_header 
				where @branch = tlh_branch and 
					@supplier = tlh_supplier
					and @plant = tlh_plant and 
	--				@dock = tlh_dock
					(tlh_dock = @dock or @dock = '' or @dock IS NULL or @dock = 'UNK' or tlh_dock = '' or tlh_dock IS NULL)
					and @deliverdate >= tlh_effective and 
					@deliverdate <= tlh_expires
					-- 30581
					-- and @jit = tlh_jittime and @sequence = tlh_sequence
					and ISNULL(@jit, 0) = ISNULL(tlh_jittime, 0) and ISNULL(@sequence, 0) = ISNULL(tlh_sequence, 0)
					and tlh_dow = 0 and 
					tlh_direction = 'D'
			else
				Select @tlh_number = max(tlh_number) 
				from timeline_header 
				where @branch = tlh_branch and 
					@supplier = tlh_supplier
					and @plant = tlh_plant and 
	--				@dock = tlh_dock
					(tlh_dock = @dock or @dock = '' or @dock IS NULL or @dock = 'UNK' or tlh_dock = '' or tlh_dock IS NULL)
					and @pickupdate >= tlh_effective and 
					@pickupdate <= tlh_expires
					-- 30581
					-- and @jit = tlh_jittime and @sequence = tlh_sequence
					and ISNULL(@jit, 0) = ISNULL(tlh_jittime, 0) and ISNULL(@sequence, 0) = ISNULL(tlh_sequence, 0)
					and tlh_dow = 0 and 
					tlh_direction = 'P'
		end 
		--------
		-- Update the part order header with the new timeline
		--------
	--	update partorder_header 
	--	set poh_timelineid = @tlh_number 
	--	where poh_identity = @min_po
	
		----------
		-- Time not found?
		----------
		if @tlh_number is null
		begin
			SELECT @v_mfst = poh_refnum
				FROM partorder_header
				WHERE poh_identity = @poh_identity
			SET @v_msg = 'No timeline match for part order.  Reference: ' + @v_mfst + '  Branch: ' + @branch + '  Supplier: ' + @supplier
	
			INSERT INTO tts_errorlog (
				  err_batch  
				, err_user_id 
				, err_message                                                                                                                                                                                                                                                    
				, err_date                                               
				, err_number  
				, err_title
				, err_type)
			VALUES (
				  0
				, LEFT(@v_user, 10)
				, @v_msg
				, GETDATE()
				, 10110
				, 'Timeline Match'
				, 'TLM')
		end
	END -- Active shipper
SET @tlh_number = IsNull(@tlh_number, 0)

GO
GRANT EXECUTE ON  [dbo].[timeline_match_find_sp] TO [public]
GO
