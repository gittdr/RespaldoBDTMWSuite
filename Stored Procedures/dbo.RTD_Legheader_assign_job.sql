SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[RTD_Legheader_assign_job]

as

/*	
*	PTS 43872 - DJM - Round Trip Dispatch
*	PTS 57799 - DJM - Converted this from a trigger to a Job so that it can pick up legheaders
*					that were not complete at the time the lgh_type value was set to indicate a 
*					new RTD was required.
*/
if exists(select 1 from generalinfo where gi_name = 'TrackTRCRTD' and left(gi_string1,1) = 'Y')
BEGIN
	Declare @RTD_lghtype	varchar(10),
		@RTD_value			varchar(12),
		@RTD_ignore			varchar(12),
		@updated			integer,
		@rtdid				integer,
		@typevalue			varchar(12),
		@v_sql				nvarchar(500),
		@trcid				varchar(13),
		@oo_trc				varchar(10),
		@RTD_startdate		datetime,
		@currentrtd			integer,
		@changed			integer,
		@BeginLgh			integer,
		@BeginTrc			varchar(8),
		@BeginDate			datetime,
		@PriorLghDate		datetime,
		@seq				integer
		
		
	Declare @rtdleg Table(
		seq			integer	identity,
		lgh_number	integer,
		lgh_startdate	datetime,
		lgh_tractor		varchar(8),
		lgh_type1	varchar(6),
		lgh_type2	varchar(6),
		lgh_type3	varchar(6), 
		lgh_type4	varchar(6)
		)	 

	select @updated = 0

/*
*	PTS 43872 - Get the GI settings for the RTD Functionality.
*		gi_String1 = value will indicate which lgh_type field to use (1-4)
*		gi_string2 = the abbr code from the Labelfile that indicates a trip BEGINS a new RTD.
*		gi_string3 = the abbr code from the Labelfile that indicates that Leg should be EXCLUDED from ALL RTDs.
*		gi_date1 = The lgh_startdate to start using the RTD logic.  Legheaders with an lgh_startdate prior to this date will not be included.
*/
	Select @RTD_lghtype = gi_string1,
		@RTD_value = gi_string2,
		@RTD_ignore = gi_string3,
		@RTD_startdate = gi_date1
	from generalinfo where gi_name = 'TRCRTDTracking'

	---- Check to verify that the required field was updated, the required value was entered, and that the value actually changed.
	--if @RTD_lghtype = 'lgh_type1' AND update(lgh_type1) AND exists (select 1 from inserted join deleted on inserted.lgh_number = deleted.lgh_number and isnull(deleted.lgh_type1,'ZZZ') <> isnull(inserted.lgh_type1,'ZZZ'))
	--	Begin
	--		select @updated = 1
	--		select @typevalue = lgh_type1 from inserted
	--	End
	--if @RTD_lghtype = 'lgh_type2' AND update(lgh_type2) AND exists (select 1 from inserted join deleted on inserted.lgh_number = deleted.lgh_number and isnull(deleted.lgh_type2,'ZZZ') <> isnull(inserted.lgh_type2,'ZZZ'))
	--	Begin
	--		select @updated = 1
	--		select @typevalue = lgh_type2 from inserted
	--	End
	--if @RTD_lghtype = 'lgh_type3' AND update(lgh_type3) AND exists (select 1 from inserted join deleted on inserted.lgh_number = deleted.lgh_number and isnull(deleted.lgh_type3,'ZZZ') <> isnull(inserted.lgh_type3,'ZZZ'))
	--	Begin
	--		select @updated = 1
	--		select @typevalue = lgh_type3 from inserted
	--	End
	--if @RTD_lghtype = 'lgh_type4' AND update(lgh_type4) AND exists (select 1 from inserted join deleted on inserted.lgh_number = deleted.lgh_number and isnull(deleted.lgh_type4,'ZZZ') <> isnull(inserted.lgh_type4,'ZZZ'))
	--	Begin
	--		select @updated = 1
	--		select @typevalue = lgh_type4 from inserted
	--	End
	
	-- Build a temp table of all the legs that need to be evaluated for an RTD
	Insert into @rtdleg
	select lgh_number,
		lgh_startdate,
		lgh_tractor,
		lgh_type1,
		lgh_type2,
		lgh_type3,
		lgh_type4
	from legheader
	where Isnull(legheader.lgh_rtd_id,0) = 0
		and isNull(lgh_tractor ,'UNKNOWN') <> 'UNKNOWN'
		and lgh_startdate >= @RTD_startdate
		and (Case @RTD_lghtype
				when 'lgh_type1' then legheader.lgh_type1 
				when 'lgh_type2' then legheader.lgh_type2 
				when 'lgh_type3' then legheader.lgh_type3
				when 'lgh_type4' then legheader.lgh_type4
			End) = @RTD_value
	order by lgh_startdate
		
	-- Loop through the legs found and find any prior legs that should be assigned to a new RTD
	Begin
		Select @BeginLgh = lgh_number,
			@seq = seq
		from @rtdleg
		where lgh_number > 0
			and seq = (select MIN(seq) from @rtdleg where seq > 0)

		-- Begin looping through the legs that START a new RTD and look at legs prior to it for legs
		--	that need an RTD assigned.
		While @BeginLgh > 0
			Begin
			
				Select @trcid = lgh_tractor,
					@BeginDate = lgh_startdate
				from @rtdleg
				where lgh_number = @BeginLgh
				
				-- Get the Tractor Id and accounting type for the Tractor to verify that it's an Owner/Operator.
				--select @trcid = lgh_tractor from legheader l where l.lgh_number = @BeginLgh
				select @oo_trc = isNull((select trc_actg_type from tractorprofile trc where trc.trc_number = @trcid and trc_actg_type = 'A'),'N')
				
				-- Verify that the Tractor for the trip was an Owner Operator and that lgh_type value indicates a new RTD is starting
				if (@oo_trc = 'A') --and (@typevalue = @RTD_value) 
					Begin	

							
						
						-- Find the last leg prior to the current 'Begin' leg that does NOT 
						--	have an RTD AND has the 'Begin' lgh_type value set.
						select @PriorLghDate = isnull(max(lgh_startdate),'1950-01-01')
						from legheader
						where legheader.lgh_tractor = @trcid
							and legheader.lgh_startdate < @BeginDate
							and legheader.lgh_outstatus = 'CMP'
							and (Case @RTD_lghtype
									when 'lgh_type1' then legheader.lgh_type1 
									when 'lgh_type2' then legheader.lgh_type2 
									when 'lgh_type3' then legheader.lgh_type3
									when 'lgh_type4' then legheader.lgh_type4
								End) = @RTD_value
							and isNull(legheader.lgh_rtd_id,0) = 0
							
							
						if not exists (
							select 1 
							from legheader
							where legheader.lgh_tractor = @trcid
							and legheader.lgh_startdate < @BeginDate
							and legheader.lgh_outstatus != 'CMP'
							and (Case @RTD_lghtype
									when 'lgh_type1' then legheader.lgh_type1 
									when 'lgh_type2' then legheader.lgh_type2 
									when 'lgh_type3' then legheader.lgh_type3
									when 'lgh_type4' then legheader.lgh_type4
								End) <> @RTD_ignore
							and isNull(legheader.lgh_rtd_id,0) = 0
							and legheader.lgh_startdate >= @PriorLghDate)
							
							-- Begin Updating legheaders with RTD ID
							Begin

								-- Create the RTD Record
								Insert Into tractor_rtd (rtd_trcid) values (@trcid)
								if @@error = 0 
								
								-- Get the Identity key for the new tractor_rtd record
								select @rtdid = scope_identity() 
																			
								-- Update any prior trips that should belong to this RTD.
								Update legheader
								set lgh_rtd_id = @rtdid
								where legheader.lgh_tractor = @trcid
									and legheader.lgh_startdate < @BeginDate
									and legheader.lgh_outstatus = 'CMP'
									and (Case @RTD_lghtype
											when 'lgh_type1' then legheader.lgh_type1 
											when 'lgh_type2' then legheader.lgh_type2 
											when 'lgh_type3' then legheader.lgh_type3
											when 'lgh_type4' then legheader.lgh_type4
										End) <> @RTD_ignore
									and isNull(legheader.lgh_rtd_id,0) = 0
									and legheader.lgh_startdate >= @PriorLghDate
							End	
							-- end Updating legheaders with RTD ID
													
						if @@error <> 0 
							Begin
								RAISERROR ('Error setting RTD ID: %s on Legheader(s) record for Tractor: %d', 16, 1, @rtdid, @trcid)  
								Return
							End
				--else
					--Begin
					--	RAISERROR ('Error inserting new RTD record for Tractor: %s', 16, 1, @trcid)  
					--	Return
					--end
				end
					
		
			-- Must check for Max sequence. Going to infinite loop otherwise
			if @seq = (select MAX(seq) from @rtdleg)
				select @BeginLgh = 0
			else
				Begin
					
					Select @BeginLgh = isnull(lgh_number,0), 
						@seq = seq 
					from @rtdleg 
					where @BeginLgh <> lgh_number
						and seq = (@seq+1)
					
				end
			End	
			
		End	-- End Legheader loop
			
		
	End
	
GO
