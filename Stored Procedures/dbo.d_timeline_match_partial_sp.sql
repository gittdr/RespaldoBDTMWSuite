SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_timeline_match_partial_sp] (@poh_identity int, @tlh_number int)
AS

/**
 * 
 * NAME:
 * dbo.proc for dw d_timeline_match_partial
 *
 * TYPE:
 * [StoredProcedure|
 *
 * DESCRIPTION:
 * proc for dw d_timeline_match_partial
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * dw result set
 *
 * PARAMETERS:
 * 			@poh_identity int, partorder_header number
 *			@tlh_number int	timeline number
 *
 * 
 * REVISION HISTORY:
 * 08/10/05	LOR	PTS# 29095	
 * 8/17/05 DSK 29317
 * 8/29/05 MRH Added support for hard-set-dates
 * 09/16/2005 - MRH fixed a problem with destination based dates.
 * 09/27/2005 - MRH Fix problem where Lead columns were transposed
 * 05/04/2006 - MRH Updated to mactch udpates to the timeline_match_sp
 * 09/10/2008 - MRH Rewrite to use new timeline_lead_calc proc.
 *
 **/

declare @deliverdate datetime,
		@pickupdate datetime,
 		@tld_master_ordnum varchar(12),
		@tld_origin varchar(8),
		@tld_dest varchar(8),
		@min_sequence int,
		@tld_org_arrive datetime,
		@tld_dest_arrive datetime,
		@tlh_direction char(1),
		@por_begindate datetime,
		@por_enddate datetime,
		@lead int,
		@holidays int,
		@org_arrive_time datetime,
		@tlh_saturday char(1),
		@tlh_sunday char(1),
		@chardate char(10),
		@chartime char (8),
		@chardatetime char(22),
		@ord	int,
		@route 	varchar(15),
		@status varchar(6),
		@s_from 	varchar(12),
		@l_from	int,
		@tlh_name	varchar(32),
		@lead_basis	int,
		@total_lead int,
		@tld_arrive_yard datetime
declare @prior_begindate datetime
declare @prior_enddate datetime
declare @first_sequence int
declare @origin_arrive_lead int
declare @origin_depart_lead int
declare @dest_depart_lead int
declare @dest_arrive_lead int
declare @por_sequence int
declare @last_sequence int
declare @Totalholidays int
declare @PrimarySeq CHAR(1)
declare @branch varchar(12)
declare @tld_trl_unload_dt datetime
declare @tld_trl_unload_lead int
declare @por_trl_unload_dt datetime
declare @trl_unload_holidays int
declare @BaseDate datetime,	-- Vars for Timeline_Calc_Lead proc
	@BaseTime datetime,
	@ERROR int,
	@CalcDate datetime,
	@tld_saturday char(1),
	@tld_sunday char(1)




CREATE TABLE #route(
		poh_identity INT NOT NULL,
		por_master_ordhdr INT NULL,
		por_ordhdr INT NULL,
		por_origin	varchar(8) null,
		por_begindate	datetime null,
		por_destination	varchar(8) null,
		por_enddate	datetime null,
		route 	varchar(15) null,
		status varchar(6) null,
		s_from 	varchar(12) null,
		l_from	int null,
		ord_number	varchar(12) null,
		tlh_name	varchar(32) null,
		por_sequence INT NULL,
		por_trl_unload_dt datetime)

---------
-- We have a timeline, fill in the part order routing table.
---------
select 	@deliverdate = poh_deliverdate,
	@pickupdate = poh_pickupdate,
	@branch = poh_branch
from partorder_header
where poh_identity = @poh_identity

---------
-- For each timeline detail.
-- Get the timeline values
---------

select @TotalHolidays = 0

--EXEC gettmwuser @v_user OUTPUT

--- Get the direction from the header
select	@tlh_direction = tlh_direction,
		@tlh_saturday = tlh_saturday,
		@tlh_sunday = tlh_sunday,
		@tlh_name = tlh_name,
		@lead_basis = tlh_leadbasis,
		@total_lead = tlh_leaddays
from timeline_header
where tlh_number = @tlh_number

 	select @por_sequence = 0

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
			@route = tld_route,
			@tld_saturday = tld_saturday,
			@tld_sunday = tld_sunday
			from timeline_detail 
			where tlh_number = @tlh_number
				and tld_sequence = @min_sequence

		if isnull(@route, '') = ''
			select @ord = ord_hdrnumber,
				@route = ord_route,
				@status = ord_status,
				@s_from = IsNull(ord_fromorder, ''),
				@l_from = IsNull((select o.ord_hdrnumber 
							from orderheader o 
							where o.ord_number = orderheader.ord_fromorder), 0)
			from orderheader 
			where ord_number = @tld_master_ordnum

		-------
		-- Sort out the dates
		-------

		-- Hard set dates override.
		if substring(convert(char, @tld_org_arrive, 101), 1, 10) <> '01/01/1950'
			select @BaseDate = @tld_org_arrive
		if substring(convert(char, @tld_arrive_yard, 101), 1, 10) <> '01/01/1950'
			select @BaseDate = @tld_arrive_yard

		-- MRH 9/22/08 If drop is on a weekend or holiday allow it to deliver
		--pickup date
		select @CalcDate = @BaseDate
		Exec Timeline_Calc_Lead @CalcDate output, @tld_org_arrive, @origin_arrive_lead, @branch, @tlh_number, @tld_saturday, @tld_sunday, @ERROR output
		select @por_begindate = @CalcDate

		if @ERROR >= 0
		begin
			--drop date
			select @CalcDate = @BaseDate
			if @tlh_direction = 'D' 
			begin
				--if @min_sequence = @last_sequence -- Verify that the drop at the plant is not a weekend or holiday.
				--begin
				--	Exec Timeline_Calc_Lead @CalcDate output, @tld_dest_arrive, @dest_arrive_lead, @branch, @tlh_number, 'N', 'N', @ERROR output
				--end
				--else
				--begin
					-- Logic change. Drop will always follow the pickup by the # of lead days.
					-- calculate the lead days without considering holidays and weekends.
					select @chardate = substring(convert(char, @por_begindate, 101), 1, 10)
					-- Truncate the date off the time
					select @chartime = substring(convert(char, @tld_dest_arrive, 108), 1, 8)
					-- Add the date and time together
					select @chardatetime = @chardate + ' ' + @chartime
					SELECT @CalcDate = CAST(@chardatetime AS DATETIME)
					select @CalcDate = dateadd(dd, (@origin_arrive_lead - @dest_arrive_lead), @CalcDate)
				--end
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
				if @tlh_direction = 'D'
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

-- 				--Trailer unload
-- 				select @CalcDate = @BaseDate
-- 				if @tlh_direction = 'D' 
-- 				begin
-- 					if @min_sequence = @last_sequence -- Verify that the drop at the plant is not a weekend or holiday.
-- 					begin
-- 						if @tld_trl_unload_dt <> '1900-01-01 00:00:00' and @tld_trl_unload_lead is not null
-- 							Exec Timeline_Calc_Lead @CalcDate output, @tld_trl_unload_dt, @tld_trl_unload_lead, @branch, @tlh_number, 'N', 'N', @ERROR output
-- 						else
-- 							Exec Timeline_Calc_Lead @CalcDate output, @tld_dest_arrive, @dest_arrive_lead, @branch, @tlh_number, 'N', 'N', @ERROR output
-- 					end
-- 					else
-- 					begin -- calculate the lead days without considering holidays and weekends.
-- 						select @chardate = substring(convert(char, @por_begindate, 101), 1, 10)
-- 						if @tld_trl_unload_dt <> '1900-01-01 00:00:00' and @tld_trl_unload_lead is not null
-- 							select @chartime = substring(convert(char, @tld_trl_unload_dt, 108), 1, 8)
-- 						else
-- 							select @chartime = substring(convert(char, @tld_dest_arrive, 108), 1, 8)
-- 						-- Add the date and time together
-- 						select @chardatetime = @chardate + ' ' + @chartime
-- 						SELECT @CalcDate = CAST(@chardatetime AS DATETIME)
-- 						if @tld_trl_unload_dt <> '1900-01-01 00:00:00' and @tld_trl_unload_lead is not null
-- 							select @CalcDate = dateadd(dd, (@origin_arrive_lead - @tld_trl_unload_lead), @CalcDate)
-- 						else
-- 							select @CalcDate = dateadd(dd, (@origin_arrive_lead - @dest_arrive_lead), @CalcDate)
-- 					end
-- 				end
-- 				else
-- 				begin	-- pickup based.
-- 					if @tld_trl_unload_dt <> '1900-01-01 00:00:00' and @tld_trl_unload_lead is not null
-- 						Exec Timeline_Calc_Lead @CalcDate output, @tld_trl_unload_dt, @tld_trl_unload_lead, @branch, @tlh_number, 'N', 'N', @ERROR output
-- 					else
-- 						Exec Timeline_Calc_Lead @CalcDate output, @tld_dest_arrive, @dest_arrive_lead, @branch, @tlh_number, 'N', 'N', @ERROR output
-- 				end
-- 				select @por_trl_unload_dt = @CalcDate
			end -- Error on drop date
		end	-- Error on pickup date

--		if @contract = 'TMMC'
--			if @imported_poh_pickupdate <> @por_begindate or @imported_poh_deliverdate <> @por_enddate
--				select @ERROR = -1

		if @ERROR >= 0
		begin
			insert into #route (
						poh_identity
						,por_master_ordhdr
						,por_ordhdr
						,por_origin
						,por_begindate
						,por_destination
						,por_enddate,
						route,
						status,
						s_from,
						l_from,
						ord_number,
						tlh_name,
						por_sequence,
						por_trl_unload_dt) -- 29317
			Values (
						@poh_identity
						,@tld_master_ordnum
						,0
						,@tld_origin
						,@por_begindate
						,@tld_dest
						,@por_enddate,
						@route,
						@status,
						@s_from,
						@l_from,
						@tld_master_ordnum,
						@tlh_name,
						@por_sequence,
						@por_trl_unload_dt)	-- 29317

			-- Set the begining to the end of the prior trip so we are ready to calc the next trip.
			select @prior_enddate = @por_enddate
			select @por_sequence = @por_sequence +1
			select @min_sequence = min(tld_sequence) 
			from timeline_detail 
			where tlh_number = @tlh_number and 
				tld_sequence > @min_sequence
		end
		else -- Holiday exeption error
		begin
			delete from #route
			BREAK -- Don't bother to process any other segments.
		end
	end

select * from #route

GO
GRANT EXECUTE ON  [dbo].[d_timeline_match_partial_sp] TO [public]
GO
