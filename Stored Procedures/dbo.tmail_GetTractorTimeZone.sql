SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_GetTractorTimeZone] 
	(@sTractor VARCHAR(8))

AS
	/*
		2011.11.10 - PTS 59317 - VMS
		This stored proc will retrieve the tractor timezone information from
        the tractorprofile table where available.

		Inputs - sTractor - The trc_number value

		Ouptut - Dataset containing the trc_timezone value for the trator requested.
	*/

	-- If there is a trc_timezone column in the tractorprofile table then use it
	-- otherwise return a blank to indicate that tractor timezones will not be used.
	IF EXISTS (
		SELECT name 
		  FROM syscolumns (NOLOCK)
		 WHERE id = OBJECT_ID('dbo.tractorprofile')
		   AND name = 'trc_timezone'
		) 
		BEGIN 
			SELECT ISNULL(trc_timezone,'') AS 'TractorTZ'
			  FROM tractorprofile (NOLOCK)
			 WHERE trc_number = @sTractor
		END
	ELSE
		BEGIN
			SELECT '' AS 'TractorTZ'
		END

GO
GRANT EXECUTE ON  [dbo].[tmail_GetTractorTimeZone] TO [public]
GO
