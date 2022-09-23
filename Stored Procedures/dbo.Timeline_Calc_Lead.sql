SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[Timeline_Calc_Lead]
	@BaseDate datetime OUTPUT,
	@BaseTime datetime,
	@lead	integer,
	@branch varchar(12),
	@tlh_number int,
	@tld_saturday char(1),
	@tld_sunday char(1),
	@ERROR int OUTPUT
AS

/**
 * 
 * NAME:
 * dbo.Timeline_Calc_Lead
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Lead date calculator. Given a date, time, Direction, and Lead days calculate the trip start or end.
 *
 * RETURNS:
 *   @CalcDate datetime
 *   on succes
 *		cacluated datetime
 *
 * PARAMETERS:
 *	@BaseDate datetime	- Date part of input date (use same value for both if you have a true datetime)
 * 	@BaseTime datetime	- Time part of input date
 *	@lead	integer		- Number of lead days
 *	@branch varchar(12),	- Branch used for holiday table
 *	@tlh_number int,	- Timeline number
 *	@ERROR int OUTPUT	- Error return
 * 					0 = Success
 *					-1 = Failure
 * 
 * REVISION HISTORY:
 * 08/15/2008.01 - MRH ? Created
 */

declare @CalcDate	datetime
declare @Holidays	integer
declare @tlh_direction	char(1)
declare @chardate	char(10)
declare @chartime	char (8)
declare @chardatetime	char(22)
declare @tlh_saturday	char(1)
declare @tlh_sunday 	char(1)
declare @lead_basis	int
declare @total_lead 	int
declare @enddate	datetime
declare @begindate	datetime
declare @PrimarySeq	char(1)



select	@tlh_direction = tlh_direction,
	@tlh_saturday = tlh_saturday,
	@tlh_sunday = tlh_sunday,
	@lead_basis = tlh_leadbasis,
	@total_lead = tlh_leaddays
	from timeline_header
	where tlh_number = @tlh_number

if @lead_basis > 0 
	select @lead = @lead - 1

if @tlh_direction <> 'P' -- Drop based
begin

	-- Trucate the time off the date
	select @chardate = substring(convert(char, @BaseDate, 101), 1, 10)

	-- Truncate the date off the time
	select @chartime = substring(convert(char, @BaseTime, 108), 1, 8)
	
	-- Add the date and time together
	select @chardatetime = @chardate + ' ' + @chartime
	SELECT @enddate = CAST(@chardatetime AS DATETIME)	--Drop based, end of trip is fixed.
	select @begindate = DATEADD(d, -@lead, @enddate)	
	
	if @ERROR = 99	-- Flag indicating that this is the drop at the plant and should error if the resulting date is a holiday
		select @PrimarySeq = 'Y' 
	else
		select @PrimarySeq = 'N'
	
	SELECT @ERROR = 0

	if isnull(@tld_saturday, 'N') = 'Y'
		select @tlh_saturday = @tld_saturday

	if isnull(@tld_sunday, 'N') = 'Y'
		select @tlh_sunday = @tld_sunday

	Exec Timeline_holidays_sp 'D', @branch, @tlh_number, @tlh_saturday, @tlh_sunday, @PrimarySeq, @begindate output, @enddate output, @holidays output
	if @holidays < 0
		SELECT @ERROR = -1
	
	select @BaseDate = @begindate

end
else	-- Pickup based timeline
begin
	SELECT @ERROR = 0

	-- Trucate the time off the date
	select @chardate = substring(convert(char, @BaseDate, 101), 1, 10)

	-- Truncate the date off the time
	select @chartime = substring(convert(char, @BaseTime, 108), 1, 8)
	
	-- Add the date and time together
	select @chardatetime = @chardate + ' ' + @chartime
	SELECT @enddate = CAST(@chardatetime AS DATETIME)	--PUP based, start of trip is fixed.
	select @begindate = DATEADD(d, @lead, @enddate)	
	
	select @PrimarySeq = 'Y' -- Can't have any other kind.

	if isnull(@tld_saturday, 'N') = 'Y'
		select @tlh_saturday = @tld_saturday

	if isnull(@tld_sunday, 'N') = 'Y'
		select @tlh_sunday = @tld_sunday
	
	Exec Timeline_holidays_sp 'P', @branch, @tlh_number, @tlh_saturday, @tlh_sunday, @PrimarySeq, @begindate output, @enddate output, @holidays output
	if @holidays < 0
		SELECT @ERROR = -1
	
	select @BaseDate = @enddate

end

GO
GRANT EXECUTE ON  [dbo].[Timeline_Calc_Lead] TO [public]
GO
