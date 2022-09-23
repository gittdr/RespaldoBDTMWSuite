SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[Timeline_match_sp]
	@poh_identity int
AS

/**
 * 
 * NAME:
 * dbo.Timeline_match_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Link part orders to the orders on which they ride
 *
 * RETURNS: 
 *	-1
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_ordhdr int
 *       This parameter indicates the specific part order to link
 *       zero or null indicates link all non-linked part orders
 * 
 * REVISION HISTORY:
 * 07/26/2005.01 - MRH ? Created
 * 08/05/2005.02 - MRH - Fixed a problem with ord_number vs ord_hdrnumber
 * 08/17/2005 - DSK - add sequence to por
 * 08/24/2005 - MRH Add support for hard-set-dates in the timeline.
 * 09/08/2005 - MRH Add logic for timelines to be active by branch.
 * 09/08/2005 - MRH Allow dock to be null on match. 
 * 09/13/2005 - DPH Insert into partorder_routing_history table when creating a new route
 * 09/16/2005 - MRH fixed a problem with destination based dates. Included 'UNK' in dock.
 * 09/23/2005 - MRH Change charindex on dock to =
 * 09/27/2005 - MRH Fix problem where Lead columns were transposed
 * 10/21/2005 - DSK Dates not getting set right based on provided lead days in the timeline
 * 04/18/2006 - MRH Holiday changes.
 * 05/16/2006 - MRH Holiday Error Handling.
 * 07/03/2006 - MRH Added trailer unload.
 * 07/06/2006 - MRH 'TMMC' import logic.
 * 07/06/2006 - MRH removed the -24 hrs check on the dates for single timeline matching.
 * 04/16/2008 - MRH Removed the partorder header update of the original date of delivery or pickup (depending on direction)
 * 04/16/2008 - MRH Drop based timelines where not using the lead days on the drop.
 * 09/09/2008 - MRH Changed to use external lead day calcualtion proc for consistancy. HUGE CLEAN UP.
 *
 ********************** NOTE: *******************
 * IF YOU UPDATE THIS PROC YOU MUST ALSO UPDATE:
 * 	timeline_match_find_sp
 * 	d_timeline_match_partial_sp
 ************************************************
 **/


Declare @min_po int
Declare @startdate DateTime
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
declare @tlh_number int
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
declare @origin_arrive_lead int
declare @origin_depart_lead int
declare @dest_depart_lead int
declare @dest_arrive_lead int
declare @holidays int
declare @Totalholidays int
declare @org_arrive_time datetime
declare @tlh_saturday char(1)
declare @tlh_sunday char(1)
declare @chardate char(10)
declare @chartime char (8)
declare @chardatetime char(22)
declare @ord_hdrnumber int
declare @lead_basis	int
declare @total_lead int
declare @tld_arrive_yard datetime
--DPH PTS 29749
declare	@por_group_identity int
--DPH PTS 29749
declare @prior_begindate datetime
declare @prior_enddate datetime
declare @first_sequence int
declare @last_sequence int
declare @ReturnValue int
declare @Active VARCHAR(6) -- 30581
declare @Direction CHAR(1) -- 30696
declare @PrimarySeq CHAR(1)
declare @EffeiveBasis CHAR(1)
declare @tld_trl_unload_dt datetime
declare @tld_trl_unload_lead int
declare @por_trl_unload_dt datetime
declare @trl_unload_holidays int
declare @imported_poh_pickupdate datetime
declare @imported_poh_deliverdate datetime
declare @contract varchar(10)
declare @por_route varchar(15)
declare @poh_status varchar(6)
declare @BaseDate datetime,	-- Vars for Timeline_Calc_Lead proc
	@BaseTime datetime,
	@ERROR int,
	@CalcDate datetime,
	@tld_saturday char(1),
	@tld_sunday char(1)

CREATE TABLE #temp_po (
	  poh_identity INT
	, active VARCHAR(6)) -- 30581 add column to table

select @ReturnValue = 1
-- Start at midnight
select @startdate = dateadd(dd, -1, convert(datetime,substring(convert(char,getdate(),101), 1, 10), 101))
--select @startdate = '1/1/05'
-------
-- Build a temp table of all part orders to be handled.
-------
IF not isnull(@poh_identity, 0) = 0
begin -- 30581 redo the query to alias
	INSERT INTO #temp_po
	SELECT poh_identity, cmp_othertype1
	FROM partorder_header p
	INNER JOIN company_alternates ca ON ca.ca_id = p.poh_supplier
	INNER JOIN company alias ON alias.cmp_id = ca.ca_alt AND alias.cmp_revtype1 = p.poh_branch
	WHERE poh_identity = @poh_identity
	AND poh_type <> '!TLMD!'
	AND ((poh_deliverdate = '19000101 00:00:00') 
		or (poh_pickupdate = '19000101 00:00:00')
		OR poh_direction IN ('D', 'P'))
	AND convert(int, poh_status) < '50'
end
else
begin -- 30581 redo the query to alias
	INSERT INTO #temp_po 
	SELECT poh_identity, cmp_othertype1
	FROM partorder_header p
	INNER JOIN company_alternates ca ON ca.ca_id = p.poh_supplier
	INNER JOIN company alias ON alias.cmp_id = ca.ca_alt AND alias.cmp_revtype1 = p.poh_branch
	WHERE isnull(poh_timelineid, 0) = 0 
	AND poh_type <> '!TLMD!'
	AND ((poh_pickupdate > @startdate and poh_deliverdate = '19000101 00:00:00') 
		or (poh_deliverdate > @startdate and poh_pickupdate = '19000101 00:00:00')
		OR poh_direction IN ('D', 'P'))
	AND convert(int, poh_status) < '50'
end

-- 30581 
EXEC gettmwuser @v_user OUTPUT
SET @v_user = LEFT(@v_user, 10) --30581

select @min_po = min(poh_identity) from #temp_po

while isnull(@min_po, 0) > 0
begin
-- 30581 move this out of loop
--	EXEC gettmwuser @v_user OUTPUT 
	--------
	-- match timeline on Branch, supplier, plant, dock, Jit or Seq, day of week
	--------
	select @branch = poh_branch, @supplier = poh_supplier, 
		@plant = poh_plant, @dock = poh_dock, @jit = poh_jittime, 
		@sequence = poh_sequence, @deliverdate = poh_deliverdate,
		@pickupdate = poh_pickupdate, @dow_del = datepart(dw, poh_deliverdate),
		@dow_pup = datepart(dw, poh_pickupdate),
		@Active = active, -- 30581
		@direction = poh_direction,
		@EffeiveBasis = poh_effective_basis,
		@poh_status = poh_status --fix UPO addon status.
		from partorder_header ph
		INNER JOIN #temp_po t ON t.poh_identity = ph.poh_identity -- 30581
		where ph.poh_identity = @min_po

	if (@deliverdate <> '19000101 00:00:00' and @pickupdate <> '19000101 00:00:00' and @EffeiveBasis is NOT NULL)
	begin
		select @contract = 'TMMC'
		select @imported_poh_pickupdate = @pickupdate
		select @imported_poh_deliverdate = @deliverdate
		if @EffeiveBasis = 'P'
			select @direction = 'P'
		if @EffeiveBasis = 'D'
			select @direction = 'D'
	end
	else
		select @contract = ''

	UPDATE partorder_header
	SET poh_direction = 'P'
	WHERE	poh_identity = @min_po
	AND	poh_deliverdate = '19000101 00:00:00'
	AND 	poh_direction IS NULL

	UPDATE partorder_header
	SET poh_direction = 'D'
	WHERE	poh_identity = @min_po
	AND	poh_pickupdate = '19000101 00:00:00'
	AND 	poh_direction IS NULL

	DELETE partorder_routing
	WHERE poh_identity = @min_po

-- 30581
	IF @Active = 'ACTV'
	BEGIN
		-------
		-- Check for a single day timeline
		-------
	-- 29317
	--	if @pickupdate is null
		if @pickupdate = '19000101 00:00:00' OR @direction = 'D'
		begin
			Select @tlh_number = max(tlh_number) from timeline_header 
				where @branch = tlh_branch and @supplier = tlh_supplier
				and @plant = tlh_plant --and @dock = tlh_dock
				and (tlh_dock = @dock or @dock = '' or @dock IS NULL or @dock = 'UNK' or tlh_dock = '' or tlh_dock IS NULL)
				and DATEADD(DAY, DATEDIFF(DAY, 0, @deliverdate), 0) = tlh_effective and DATEADD(DAY, DATEDIFF(DAY, 0, @deliverdate), 0) = tlh_expires
				--and @deliverdate = tlh_effective and @deliverdate = tlh_expires
				-- 30581
--				and @jit = tlh_jittime and @sequence = tlh_sequence
				and ISNULL(@jit, 0) = ISNULL(tlh_jittime, 0) and ISNULL(@sequence, 0) = ISNULL(tlh_sequence, 0)
	--			and ((@jit = tlh_jittime and tlh_jittime <> 0)or (@sequence = tlh_sequence and tlh_sequence <> 0))
				and @dow_del = tlh_dow and tlh_direction = 'D'
		end else IF @deliverdate = '19000101 00:00:00' OR @direction = 'P'
		begin 
			Select @tlh_number = max(tlh_number) from timeline_header 
				where @branch = tlh_branch and @supplier = tlh_supplier
				and @plant = tlh_plant --and @dock = tlh_dock
				and (tlh_dock = @dock or @dock = '' or @dock IS NULL or @dock = 'UNK' or tlh_dock = '' or tlh_dock IS NULL)
				and DATEADD(DAY, DATEDIFF(DAY, 0, @pickupdate), 0) = tlh_effective and DATEADD(DAY, DATEDIFF(DAY, 0, @pickupdate), 0) = tlh_expires
				--and @pickupdate = tlh_effective and @pickupdate = tlh_expires
				-- 30581
--				and @jit = tlh_jittime and @sequence = tlh_sequence
				and ISNULL(@jit, 0) = ISNULL(tlh_jittime, 0) and ISNULL(@sequence, 0) = ISNULL(tlh_sequence, 0)
				and @dow_pup = tlh_dow and tlh_direction = 'P'
		end
	
		-------
		-- No single day timeline, check for a specific day of the week timeline
		-------
		if @tlh_number is null
		begin
	-- 29317
	--	if @pickupdate is null
		if @pickupdate = '19000101 00:00:00' OR @direction = 'D'
			begin
				Select @tlh_number = max(tlh_number) from timeline_header 
					where @branch = tlh_branch and @supplier = tlh_supplier
					and @plant = tlh_plant --and @dock = tlh_dock
					and (tlh_dock = @dock or @dock = '' or @dock IS NULL or @dock = 'UNK' or tlh_dock = '' or tlh_dock IS NULL)
					and @deliverdate >= tlh_effective and @deliverdate <= tlh_expires
					-- 30581
	--				and @jit = tlh_jittime and @sequence = tlh_sequence
					and ISNULL(@jit, 0) = ISNULL(tlh_jittime, 0) and ISNULL(@sequence, 0) = ISNULL(tlh_sequence, 0)
					and @dow_del = tlh_dow and tlh_direction = 'D'
			end else IF @deliverdate = '19000101 00:00:00' OR @direction = 'P'
			begin 
				Select @tlh_number = max(tlh_number) from timeline_header 
					where @branch = tlh_branch and @supplier = tlh_supplier
					and @plant = tlh_plant --and @dock = tlh_dock
					and (tlh_dock = @dock or @dock = '' or @dock IS NULL or @dock = 'UNK' or tlh_dock = '' or tlh_dock IS NULL)
					and @pickupdate >= tlh_effective and @pickupdate <= tlh_expires
					-- 30581
	--				and @jit = tlh_jittime and @sequence = tlh_sequence
					and ISNULL(@jit, 0) = ISNULL(tlh_jittime, 0) and ISNULL(@sequence, 0) = ISNULL(tlh_sequence, 0)
					and @dow_pup = tlh_dow and tlh_direction = 'P'
			end
		end
	
		---------
		-- If a timeline is not found for a specific day of the week try for any day.
		---------
		if @tlh_number is null
		begin
	-- 29317
	--	if @pickupdate is null
		if @pickupdate = '19000101 00:00:00' OR @direction = 'D'
			begin
				Select @tlh_number = max(tlh_number) from timeline_header 
					where @branch = tlh_branch and @supplier = tlh_supplier
					and @plant = tlh_plant --and @dock = tlh_dock
					and (tlh_dock = @dock or @dock = '' or @dock IS NULL or @dock = 'UNK' or tlh_dock = '' or tlh_dock IS NULL)
					and @deliverdate >= tlh_effective and @deliverdate <= tlh_expires
					-- 30581
	--				and @jit = tlh_jittime and @sequence = tlh_sequence
					and ISNULL(@jit, 0) = ISNULL(tlh_jittime, 0) and ISNULL(@sequence, 0) = ISNULL(tlh_sequence, 0)
					and tlh_dow = 0 and tlh_direction = 'D'
			end else IF @deliverdate = '19000101 00:00:00' OR @direction = 'P'
			begin 
				Select @tlh_number = max(tlh_number) from timeline_header 
					where @branch = tlh_branch and @supplier = tlh_supplier
					and @plant = tlh_plant --and @dock = tlh_dock
					and (tlh_dock = @dock or @dock = '' or @dock IS NULL or @dock = 'UNK' or tlh_dock = '' or tlh_dock IS NULL)
					and @pickupdate >= tlh_effective and @pickupdate <= tlh_expires
					-- 30581
	--				and @jit = tlh_jittime and @sequence = tlh_sequence
					and ISNULL(@jit, 0) = ISNULL(tlh_jittime, 0) and ISNULL(@sequence, 0) = ISNULL(tlh_sequence, 0)
					and tlh_dow = 0 and tlh_direction = 'P'
			end
		end

		----------
		-- Time not found?
		----------
		if @tlh_number is null
		begin
			SELECT @v_mfst = poh_refnum
				FROM partorder_header
				WHERE poh_identity = @min_po
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
				, @v_user
				, @v_msg
				, GETDATE()
				, 10110
				, 'Timeline Match'
				, 'TLM')
			select @ReturnValue = -1
		end else
		begin --tlh_number found
			---------
			-- We have a timeline, fill in the part order routing table.
			---------
			
			---------
			-- For each timeline detail.
			-- Get the timeline values
			---------

			select @TotalHolidays = 0
	
			--- Get the direction from the header
			select	@tlh_direction = tlh_direction,
				@tlh_saturday = tlh_saturday,
				@tlh_sunday = tlh_sunday,
				@lead_basis = tlh_leadbasis,
				@total_lead = tlh_leaddays
				from timeline_header
				where tlh_number = @tlh_number

			Select  @por_group_identity = IDENT_CURRENT('partorder_routing_history') + 1
			
			Insert into partorder_routing_history(
				por_group_identity, 
				por_identity,     
				poh_identity,     
				por_master_ordhdr,
				por_ordhdr,     
				por_origin,     
				por_begindate,  
				por_destination,
				por_enddate,
				por_updatedby,
				por_updatedon  )

			Select	@por_group_identity, 
				por_identity,     
				poh_identity,     
				por_master_ordhdr,
				por_ordhdr,    	 
				por_origin,     
				por_begindate,  
				por_destination,
				por_enddate,
				por_updatedby,
				por_updatedon
			From	partorder_routing
			Where	poh_identity = @poh_identity
			--Insert into partorder_routing_history, DPH PTS 29749	

			if @tlh_direction = 'P'
				select @BaseDate = @pickupdate
			else
				select @BaseDate = @deliverdate

			select @min_sequence = min(tld_sequence) from timeline_detail where tlh_number = @tlh_number
			select @first_sequence = @min_sequence
			select @last_sequence = max(tld_sequence) from timeline_detail where tlh_number = @tlh_number

			while isnull(@min_sequence, 0) > 0
			begin
				select	@tld_master_ordnum = tld_master_ordnum, 
					@tld_origin = tld_origin, 
					@tld_dest = tld_dest,
					@tld_org_arrive = tld_arrive_orig,
					@tld_dest_arrive = tld_arrive_dest,		--MRH Lead basis is handled in the Timeline_Calc_Lead proc
					@origin_arrive_lead = tld_arrive_orig_lead, -- - @lead_basis,  -- Origin arrive lead
					@origin_depart_lead = tld_arrive_dest_lead, -- - @lead_basis,  -- Origin depart lead
					@dest_arrive_lead = tld_arrive_lead, -- - @lead_basis, 	   -- Destination arrive lead
					@dest_depart_lead = tld_depart_orig_lead, -- - @lead_basis,    -- Destination depart lead
					@tld_trl_unload_dt = tld_trl_unload_dt,
					@tld_trl_unload_lead = tld_trl_unload_lead, -- - @lead_basis,
					@por_route = tld_route,
					@tld_saturday = tld_saturday,
					@tld_sunday = tld_sunday
					from timeline_detail 
					where tlh_number = @tlh_number
						and tld_sequence = @min_sequence
				-------
				-- Sort out the dates
				-------

				-- Hard set dates override.
				if substring(convert(char, @tld_org_arrive, 101), 1, 10) <> '01/01/1950'
					select @BaseDate = @tld_org_arrive
				if substring(convert(char, @tld_arrive_yard, 101), 1, 10) <> '01/01/1950'
					select @BaseDate = @tld_arrive_yard

				--pickup date
				select @CalcDate = @BaseDate
				Exec Timeline_Calc_Lead @CalcDate output, @tld_org_arrive, @origin_arrive_lead, @branch, @tlh_number, @tld_saturday, @tld_sunday, @ERROR output
				select @por_begindate = @CalcDate
				if @ERROR >= 0
				begin
					--drop date
					select @CalcDate = @BaseDate
					if @direction = 'D' 
					begin
						if @min_sequence = @last_sequence -- Verify that the drop at the plant is not a weekend or holiday.
						begin
							SELECT @ERROR = 99 -- Set the flag indicating that this is the drop at plant so the date can not move.
							Exec Timeline_Calc_Lead @CalcDate output, @tld_dest_arrive, @dest_arrive_lead, @branch, @tlh_number, 'N', 'N', @ERROR output
						end
						else
						begin
							-- Logic change. Drop will always follow the pickup by the # of lead days.
							-- calculate the lead days without considering holidays and weekends.
							select @chardate = substring(convert(char, @por_begindate, 101), 1, 10)
							-- Truncate the date off the time
							select @chartime = substring(convert(char, @tld_dest_arrive, 108), 1, 8)
							-- Add the date and time together
							select @chardatetime = @chardate + ' ' + @chartime
							SELECT @CalcDate = CAST(@chardatetime AS DATETIME)
							select @CalcDate = dateadd(dd, (@origin_arrive_lead - @dest_arrive_lead), @CalcDate)
						end
					end
					else
					begin		-- Pickup based still works the same way.
						Exec Timeline_Calc_Lead @CalcDate output, @tld_dest_arrive, @dest_arrive_lead, @branch, @tlh_number, 'N', 'N', @ERROR output
					end
					select @por_enddate = @CalcDate

					if @ERROR >= 0
					begin
						--Trailer unload
						select @CalcDate = @BaseDate
						if @direction = 'D' 
						begin
							if @min_sequence = @last_sequence -- Drop at the plant
							begin
								select @chardate = substring(convert(char, @CalcDate, 101), 1, 10)
 								if @tld_trl_unload_dt <> '1900-01-01 00:00:00' and @tld_trl_unload_lead is not null
 									select @chartime = substring(convert(char, @tld_trl_unload_dt, 108), 1, 8)
 								else
 									select @chartime = substring(convert(char, @tld_dest_arrive, 108), 1, 8)
 								-- Add the date and time together
 								select @chardatetime = @chardate + ' ' + @chartime
 								SELECT @CalcDate = CAST(@chardatetime AS DATETIME)
							end
							begin
								if @tld_trl_unload_dt <> '1900-01-01 00:00:00' and @tld_trl_unload_lead is not null
									Exec Timeline_Calc_Unload_Lead @CalcDate output, @tld_trl_unload_dt, @tld_trl_unload_lead, @branch, @tlh_number,'N', 'N', @ERROR output
								else
									Exec Timeline_Calc_Unload_Lead @CalcDate output, @tld_dest_arrive, @dest_arrive_lead, @branch, @tlh_number, 'N', 'N', @ERROR output
							end
						end
						else
						begin	-- pickup based.
							if @tld_trl_unload_dt <> '1900-01-01 00:00:00' and @tld_trl_unload_lead is not null
								Exec Timeline_Calc_Lead @CalcDate output, @tld_trl_unload_dt, @tld_trl_unload_lead, @branch, @tlh_number, 'N', 'N', @ERROR output
							else
								Exec Timeline_Calc_Lead @CalcDate output, @tld_dest_arrive, @dest_arrive_lead, @branch, @tlh_number, 'N', 'N', @ERROR output
						end
						select @por_trl_unload_dt = @CalcDate
					end -- Error on drop date
				end	-- Error on pickup date

				if @contract = 'TMMC'
					if @imported_poh_pickupdate <> @por_begindate or @imported_poh_deliverdate <> @por_enddate
						select @ERROR = -1

				if @ERROR >= 0
				begin
					SELECT @ORD_HDRNUMBER = ORD_HDRNUMBER FROM ORDERHEADER WHERE ORD_NUMBER = @tld_master_ordnum
		
					insert into partorder_routing (
						poh_identity
						,por_master_ordhdr
						,por_ordhdr
						,por_origin
						,por_begindate
						,por_destination
						,por_enddate
						,por_updatedby
						,por_updatedon
						,por_sequence --29317
						,por_trl_unload_dt
						,por_route) 
					Values (
						@min_po
						,@ORD_HDRNUMBER
						,0
						,@tld_origin
						,@por_begindate
						,@tld_dest
						,@por_enddate
						,@v_user
						,getdate()
						,@min_sequence --29317
						,@por_trl_unload_dt
						,@por_route)
					-- Set the begining to the end of the prior trip so we are ready to calc the next trip.
					select @prior_enddate = @por_enddate
					select @min_sequence = min(tld_sequence) from timeline_detail where tlh_number = @tlh_number and tld_sequence > @min_sequence
				end
				else	-- Holiday execption error
				begin
					-- Log the error
					SELECT @v_mfst = poh_refnum
						FROM partorder_header
						WHERE poh_identity = @min_po
					if @contract = 'TMMC'
						set @v_msg = 'Calculated pickup or delivery did not match the partorder.  Reference: ' + @v_mfst + '  Branch: ' + @branch + '  Supplier: ' + @supplier
					else
						SET @v_msg = 'Pickup date on a non workday for part order.  Reference: ' + @v_mfst + '  Branch: ' + @branch + '  Supplier: ' + @supplier
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
						, @v_user
						, @v_msg
						, GETDATE()
						, 10110
						, 'Timeline Match'
						, 'TLM')
					-- Clean up from the error
					select @ReturnValue = -1
					select @tlh_number = NULL
					delete from partorder_routing where poh_identity = @min_po

-- 					update partorder_header 
-- 						set poh_status = '40'
-- 						where poh_identity = @min_po

					BREAK -- Bail out of this timeline
				end	-- Holiday execption
			end -- @min_sequence Loop control

			--------
			-- Update the part order header with the new timeline and set the pickup and delivery dates.
			--------
			if @tlh_number is not NULL
			BEGIN
				if @poh_status <> '40'
					select @poh_status = '10'
				if @tlh_direction = 'P'
					update partorder_header set poh_timelineid = @tlh_number,
						poh_deliverdate = (select max(por_enddate) from partorder_routing where poh_identity = @min_po),
						poh_status = @poh_status
						where poh_identity = @min_po
				else
					update partorder_header set poh_timelineid = @tlh_number,
						poh_pickupdate = (select min(por_begindate) from partorder_routing where poh_identity = @min_po),
						poh_status = @poh_status -- 30581 (may have been 950 which means do-not-handle
						where poh_identity = @min_po

				-- 30706
				EXEC link_partorder 'PO', @min_po
			END
		end -- End tlh_number found
	END
	ELSE -- active = actv 30581
	BEGIN
		UPDATE partorder_header
		SET poh_status = '950'
		WHERE poh_identity = @poh_identity
	END
	--Get the next part order to process
	select @min_po = min(poh_identity) from #temp_po 
		where poh_identity > @min_po
end -- While loop end

--30581 
IF (SELECT COUNT(*) FROM #temp_po) = 0 AND @poh_identity > 0 -- called to match to specific PO, but alias not found
BEGIN
	SELECT @v_mfst = poh_refnum
		FROM partorder_header
		WHERE poh_identity = @min_po
	SET @v_msg = 'No alias match for part order.  Reference: ' + @v_mfst + '  Branch: ' + @branch + '  Supplier: ' + @supplier
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
		, @v_user
		, @v_msg
		, GETDATE()
		, 10112
		, 'Timeline Match'
		, 'TLM')
	SET @ReturnValue = -1
END

drop table #temp_po
return @ReturnValue

GO
GRANT EXECUTE ON  [dbo].[Timeline_match_sp] TO [public]
GO
