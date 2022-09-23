SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fnc_TMWRN_IsTimeWithinRange] (@CheckDateTime datetime = NULL, @LowDateTime datetime, @HighDateTime datetime)
RETURNS VARCHAR(1)
AS
BEGIN
	DECLARE @Status varchar(1)
	DECLARE @CheckMinsAfterMidnight int
	DECLARE @LowMinsAfterMidnight int
	DECLARE @HighMinsAfterMidnight int
 
	-- Examples:
	--		SELECT dbo.fnc_TMWRN_IsTimeWithinRange(NULL, '04:30', '21:00')
	--		SELECT dbo.fnc_TMWRN_IsTimeWithinRange(NULL, '21:00', '04:30')
	--		SELECT dbo.fnc_TMWRN_IsTimeWithinRange('09:00', '08:30', '09:30')  -- Does 9AM fall between 8:30AM to 9:30AM?  YES
	--		SELECT dbo.fnc_TMWRN_IsTimeWithinRange('02:00', '20:00', '3:00')   -- Does 2AM fall between 8PM to 3AM?  YES
	--		SELECT dbo.fnc_TMWRN_IsTimeWithinRange('03:00', '08:30', '09:30')  -- Does 3AM fall between 8:30AM to 9:30AM?  NO
	--		SELECT dbo.fnc_TMWRN_IsTimeWithinRange('10:00', '08:30', '09:30')  -- Does 10AM fall between 8:30AM to 9:30AM?  NO
	--		SELECT dbo.fnc_TMWRN_IsTimeWithinRange('19:00', '20:00', '3:00')   -- Does 7PM fall between 8PM to 3AM?  NO
	--		SELECT dbo.fnc_TMWRN_IsTimeWithinRange('04:00', '20:00', '3:00')   -- Does 4AM fall between 8PM to 3AM?  NO

	SELECT @CheckMinsAfterMidnight = DATEPART(hour, @CheckDateTime) * 60 + DATEPART(minute, @CheckDateTime)
	SELECT @LowMinsAfterMidnight = DATEPART(hour, @LowDateTime) * 60 + DATEPART(minute, @LowDateTime)
	SELECT @HighMinsAfterMidnight = DATEPART(hour, @HighDateTime) * 60 + DATEPART(minute, @HighDateTime)

	IF @LowMinsAfterMidnight < @HighMinsAfterMidnight -- Like 2AM to 4AM, or 10PM to 11:30PM
	BEGIN
		IF @CheckMinsAfterMidnight BETWEEN @LowMinsAfterMidnight AND @HighMinsAfterMidnight
			SELECT @Status = 'Y'
		ELSE
			SELECT @Status = 'N'
	END
	ELSE	-- Like 11PM to 1AM, or 6PM to 6AM.
	BEGIN
		IF @CheckMinsAfterMidnight BETWEEN @HighMinsAfterMidnight AND @LowMinsAfterMidnight
			SELECT @Status = 'N'
		ELSE
			SELECT @Status = 'Y'
	END
	
	RETURN @Status
END
GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_IsTimeWithinRange] TO [public]
GO
