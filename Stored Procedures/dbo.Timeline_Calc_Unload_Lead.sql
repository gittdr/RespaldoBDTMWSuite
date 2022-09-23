SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[Timeline_Calc_Unload_Lead]
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
 * dbo.Timeline_Calc_Unload_Lead
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Lead date calculator. Given a date, time, Direction, and Lead days calculate the trip start or end.
 * This only applys to drop based timelines.
 *
 * Trailer unloads are a different than pickup and drop calcuations.
 * The lead days still work the same way, subtract the but if the resulting date is a holiday it needs to shift 
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
 * 10/17/2008.01 - MRH ? Created
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
declare @debug int

--Select @debug = 0 -- Debug on!
Select @debug = 1 -- Debug off

SELECT @ERROR = 0

select	@tlh_direction = tlh_direction,
	@tlh_saturday = tlh_saturday,
	@tlh_sunday = tlh_sunday,
	@lead_basis = tlh_leadbasis,
	@total_lead = tlh_leaddays
	from timeline_header
	where tlh_number = @tlh_number

-- MRH For web we assume that actual # lead days is passed in.
--if @lead_basis > 0 
--	select @lead = @lead - 1

	-- Direction flag does not matter. In all cases we move the unload to a later date.
	-- Trucate the time off the date
	select @chardate = substring(convert(char, @BaseDate, 101), 1, 10)

	-- Truncate the date off the time
	select @chartime = substring(convert(char, @BaseTime, 108), 1, 8)
	
	-- Add the date and time together
	select @chardatetime = @chardate + ' ' + @chartime
	SELECT @begindate = CAST(@chardatetime AS DATETIME)
	select @enddate = DATEADD(d, @lead, @begindate)	
	
	select @PrimarySeq = 'N' -- Can't have any other kind.

	if isnull(@tld_saturday, 'N') = 'Y'
		select @tlh_saturday = @tld_saturday

	if isnull(@tld_sunday, 'N') = 'Y'
		select @tlh_sunday = @tld_sunday

	if @debug = 0 print 'Begin: ' + convert(varchar(30), @begindate)
	if @debug = 0 print 'End: ' + convert(varchar(30), @enddate)
	if @debug = 0 print 'Lead: ' + convert(varchar(30), @lead)


	Exec Timeline_holidays_unload_sp 'D', @branch, @tlh_number, @tlh_saturday, @tlh_sunday, @PrimarySeq, @begindate output, @enddate output, @holidays output
	if @holidays < 0
		SELECT @ERROR = -1

	if @debug = 0 print 'Result end: ' + convert(varchar(30), @enddate)
	
	select @BaseDate = @enddate

GO
GRANT EXECUTE ON  [dbo].[Timeline_Calc_Unload_Lead] TO [public]
GO
