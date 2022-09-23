SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[Timeline_holidays_sp]
	@Direction char(1),		-- P or D (Pick up or Drop based dates)
	@Branch varchar(12),		-- Branch
	@tlh_number int,		-- Current timeline
	@tlh_saturday char(1),		-- Saturday exeption from the timeline
	@tlh_sunday char(1),		-- Sunday exeption from the timeline
	@PrimarySegment char(1),	-- Is this the 'Primay' segment (First on pup, last on drp)
	@PupDate datetime output,	-- First date
	@DrpDate datetime output,	-- Last date
	@TotalHolidays int output	-- Total holidays in the segment and Error return
AS

/**
 * 
 * NAME:
 * dbo.Timeline_holidays_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Figure out how many days to add or subtract because of holidays.
 * 	Validate given date is not on a weekend / holiday
 * 	Check number of holidays in a given range.
 *
 * RETURNS: 
 *	Date
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 
 * REVISION HISTORY:
 * 04/27/2005 - MRH ? Created
 *
 **/

Declare @holidays int
Declare @Exception int
Declare @SatException int
Declare @SunException int
Declare @ReturnPupDate datetime
Declare @ReturnDrpDate datetime
Declare @LoopDate datetime
Declare @LoopEnd datetime
Declare @DateChange int
Declare @Dow int
declare @chardate char(10)
declare @FirstCharTime char (8)
declare @LastCharTime char (8)
declare @chardatetime char(22)
declare @maxloop int
declare @loopcount int

set DATEFIRST 1
select @TotalHolidays = 0
select @maxloop = 90 -- Max trip lenght 90 days.
select @loopcount = 0 

-- Get the date part
select @chardate = substring(convert(char, @PupDate, 101), 1, 10)
-- Get the time part and save it for the return
select @FirstCharTime = substring(convert(char, @PupDate, 108), 1, 8)
select @PupDate = cast(@chardate as DATETIME)

-- Get the date part
select @chardate = substring(convert(char, @DrpDate, 101), 1, 10)
-- Get the time part and save it for the return
select @LastCharTime = substring(convert(char, @DrpDate, 108), 1, 8)
select @DrpDate = cast(@chardate as DATETIME)

select @ReturnPupDate = @PupDate
select @ReturnDrpDate = @DrpDate

if @Direction = 'P'
begin
	select @LoopDate = @PupDate
	select @LoopEnd = @DrpDate
	select @DateChange = 1
end
else
begin
	select @LoopDate = @DrpDate
	select @LoopEnd = @PupDate
	select @DateChange = -1
end

-- Loop through each date in the range
while 1=1 -- Exit test at the end of the loop.
begin
	-- Is loopdate a holiday?
	select @holidays = isnull(count(0), 0) from branch_holiday 
		where brh_branch = @Branch and brh_date = cast(@LoopDate as Datetime)

	-- Is it an exception?
	select @Exception = isnull(count(0), 0) from TimeLine_holiday_exceptions 
		where tlh_number = @tlh_number and holiday = @LoopDate

	-- Get the day of the week
	select @Dow = datepart(dw, @LoopDate)

	-- Is it a SatException?
	if @tlh_saturday = 'Y' and @Dow = 6
		select @SatException = 1 
		else 
		select @SatException = 0

	-- Is it a SunException?
	If @tlh_sunday = 'Y' and @Dow = 7
		select @SunException = 1 
		else 
		select @SunException = 0

	-- Test to see if it is actually a holiday or if there is an exception
	if @holidays > 0
	begin
		if @Exception > 0
			select @holidays = @holidays - @Exception
--		else	-- Is it a satuday or sunday
--		begin
--			if (select datepart(dw, @LoopDate)) = 6
--				select @holidays = @holidays - @SatException
--			if (select datepart(dw, @LoopDate)) = 7
--				select @holidays = @holidays - @SunException
--		end
	end

	-- If @holidays > 0 then it is a non delivery date, shift the date or reject the PO.
	if @holidays > 0
	begin

		-- Holiday delivery failures
 		If @PrimarySegment = 'Y' and ((@Direction = 'P' and @LoopDate = @PupDate) or (@Direction = 'D' and @LoopDate = @DrpDate))
		begin
			if (select datepart(dw, @LoopDate)) = 6 and @SatException = 0
				GOTO FAILEXIT
 
			if (select datepart(dw, @LoopDate)) = 7 and @SunException = 0
				GOTO FAILEXIT

			if @Exception = 0
				GOTO FAILEXIT
		end
--
		else
		begin
			if ((@Direction = 'P' and @LoopDate = @ReturnPupDate) or (@Direction = 'D' and @LoopDate = @ReturnDrpDate))
			Begin
				if (@Direction = 'P' and @LoopDate = @ReturnPupDate)
				begin	-- Move to the next day but do not extend the total duration.
					if ((select datepart(dw, @LoopDate)) = 6 and @SatException = 0) or ((select datepart(dw, @LoopDate)) = 7 and @SunException = 0) or @Exception = 0
	 					select @ReturnPupDate = dateadd(d, @DateChange, @ReturnPupDate)
				end
	
				if (@Direction = 'D' and @LoopDate = @ReturnDrpDate)
				begin
					if ((select datepart(dw, @LoopDate)) = 6 and @SatException = 0) or ((select datepart(dw, @LoopDate)) = 7 and @SunException = 0) or @Exception = 0
	 					select @ReturnDrpDate = dateadd(d, @DateChange, @ReturnDrpDate)
				end
			End
		end
--
		--If @PrimarySegment <> 'Y' and @Direction = 'P' --and @LoopDate = @PupDate
		if @Direction = 'D'
		begin  -- Push the date through the holiday / weekend
--			select @ReturnPupDate = dateadd(d, @DateChange, @ReturnPupDate)
--			select @LoopEnd = DateAdd(d, @DateChange, @LoopEnd)	-- Add a day to the loop for the holiday 
			if (((select datepart(dw, @LoopDate)) = 6 and @SatException = 1)
			 OR ((select datepart(dw, @LoopDate)) = 7 and @SunException = 1)) 
			 AND @LoopDate <= @LoopEnd 
			Begin --Don't push thru if this is the end date and its flagged for override
				select @holidays = @holidays - 1
			End
			Else
			Begin
				select @ReturnPupDate = dateadd(d, @DateChange, @ReturnPupDate)
				select @LoopEnd = DateAdd(d, @DateChange, @LoopEnd)	-- Add a day to the loop for the holiday 
			End
		end
		else
		--If @PrimarySegment <> 'Y' and @Direction = 'D' --and @LoopDate = @DrpDate
		begin
			select @ReturnDrpDate = dateadd(d, @DateChange, @ReturnDrpDate)
			select @LoopEnd = DateAdd(d, @DateChange, @LoopEnd)	-- Add a day to the loop for the holiday 
		end
	end
	
	select @TotalHolidays = @TotalHolidays + @holidays
	select @loopcount = @loopcount + 1

	-- Loop control
	if @Direction = 'P' and @LoopDate >= @LoopEnd and @holidays = 0
		BREAK
	if @Direction = 'D' and @LoopDate <= @LoopEnd and @holidays = 0
		BREAK
	if @loopcount >= @maxloop -- More than 90 days. It is a bad timeline.
		GOTO FAILEXIT

	Select @LoopDate = DateAdd(d, @DateChange, @LoopDate)

end

-- Add the time portion of the orginal datatime back on to the date
-- Add the date and time together
select @chardate = substring(convert(char, @ReturnPupDate, 101), 1, 10)
select @chardatetime = @chardate + ' ' + @FirstCharTime
SELECT @ReturnPupDate = CAST(@chardatetime AS DATETIME)

select @chardate = substring(convert(char, @ReturnDrpDate, 101), 1, 10)
select @chardatetime = @chardate + ' ' + @LastCharTime
SELECT @ReturnDrpDate = CAST(@chardatetime AS DATETIME)


-- Return the dates
select @PupDate = @ReturnPupDate
select @DrpDate = @ReturnDrpDate

GOTO THEEXIT
-- Error exit. Come here if it is a Holiday delivery failure.
FAILEXIT:
select @TotalHolidays = -1

THEEXIT:

GO
GRANT EXECUTE ON  [dbo].[Timeline_holidays_sp] TO [public]
GO
