SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[timeline_holiday_check]
	@tlh_number int,		-- Current timeline
	@Branch varchar(12),		-- Branch
	@TestDate datetime,			-- date
	@Holidays int output			-- Return: 0 = no holiday, 1 = Holiday, -1 = Error
AS

/**
 * 
 * NAME:
 * dbo.timeline_holiday_check
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 	Validate given date is not on a weekend / holiday
 *
 * RETURNS: 
 *	@Holiday int output			-- Return: 0 = no holiday, 1 = Holiday, -1 = Error
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 
 * REVISION HISTORY:
 * 06/04/2009 - MRH ? Created
 *
 **/

Declare @Exception int
declare @chardate char(10)
Declare @SatException int
Declare @SunException int
Declare @tlh_saturday char(1)
Declare @tlh_sunday char(1)
Declare @Dow int

SET DATEFIRST 1

select @tlh_saturday = isnull(tlh_saturday, 'N'), @tlh_sunday = isnull(tlh_sunday, 'N')
	from timeline_header where tlh_number = @tlh_number

-- Get the drop date part
select @chardate = substring(convert(char, @TestDate, 101), 1, 10)
select @TestDate = cast(@chardate as DATETIME)

-- Is loopdate a holiday?
select @holidays = isnull(count(0), 0) from branch_holiday 
	where brh_branch = @Branch and brh_date = cast(@TestDate as Datetime)

-- Is it an exception?
select @Exception = isnull(count(0), 0) from TimeLine_holiday_exceptions 
	where tlh_number = @tlh_number and holiday = @TestDate

-- Get the day of the week
select @Dow = datepart(dw, @TestDate)

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
if @Holidays > 0
begin
	if @Exception > 0
		select @Holidays = @Holidays - @Exception
	else	-- Is it a satuday or sunday
	begin
		if (select datepart(dw, @TestDate)) = 6
			select @Holidays = @Holidays - @SatException
		if (select datepart(dw, @TestDate)) = 7
			select @Holidays = @Holidays - @SunException
	end
end
GO
GRANT EXECUTE ON  [dbo].[timeline_holiday_check] TO [public]
GO
