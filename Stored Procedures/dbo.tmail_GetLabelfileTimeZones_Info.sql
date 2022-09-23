SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[tmail_GetLabelfileTimeZones_Info] 
	(@sTimeZoneAbbr varchar(8))
AS
	/*
		2011.11.07 - PTS 59317 - VMS
		This stored proc will retrieve the time zone information stored in the 
		labelfile table under the labeldefinition = "TimeZones"

		Input - The Timezone abbreviation

		Output - The absolute value of the Greenwich Mean Time Adjustment factor.
	*/
	SELECT abbr AS 'TZ', ABS(label_extrastring1) AS 'GMTDelta'
		FROM labelfile (NOLOCK)
		WHERE labeldefinition = 'TimeZones'
		  AND abbr = @sTimeZoneAbbr

GO
GRANT EXECUTE ON  [dbo].[tmail_GetLabelfileTimeZones_Info] TO [public]
GO
