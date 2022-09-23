SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Retrieves the most recent login before the specified Date.
-- Only searches shifts within a week of the specified Date.
CREATE function [dbo].[tmail_get_current_shift_for_date] (
	@driver varchar(8),
	@baseDate datetime)
	RETURNS integer
as
begin
DECLARE @targetDate datetime, @RetVal int
SELECT @targetDate=ISNULL(@baseDate, GETDATE())
SELECT @RetVal = MAX(ss_id) FROM ShiftSchedules 
	where ss_date<=DATEADD(dd,7,@targetDate) and ss_date>=DATEADD(dd,-7,@targetDate)
	and mpp_id = @driver 
	and ISNULL(ss_logindate, '19500101')>'19500101' 
	and ss_logindate<=@targetDate
	and ss_date = 
		(SELECT max(ss_date) FROM ShiftSchedules 
		where ss_date<=DATEADD(dd,7,@targetDate) and ss_date>=DATEADD(dd,-7,@targetDate)
		and mpp_id = @driver 
		and ISNULL(ss_logindate, '19500101')>'19500101' 
		and ISNULL(ss_logoutdate, '20491231')>='20491231'
		and ss_logindate<=@targetDate
		)
RETURN @RetVal
end
GO
GRANT EXECUTE ON  [dbo].[tmail_get_current_shift_for_date] TO [public]
GO
