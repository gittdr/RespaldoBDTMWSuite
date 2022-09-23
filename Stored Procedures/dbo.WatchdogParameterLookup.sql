SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogParameterLookup] (@WatchName varchar(255), @ParameterName varchar(255), @AddIfNotExistYN varchar(1) )
AS
	SET NOCOUNT ON

	DECLARE @Exists int, @ParameterValue varchar(255), @DisplayOnEmail int

	SELECT @Exists = 1, @ParameterValue = ParameterValue,
			@DisplayOnEmail = DisplayOnEmail
		FROM watchdogparameter WHERE Heading = 'watchdogstoredproc' AND SubHeading = @WatchName AND ParameterName = @ParameterName

	IF @AddIfNotExistYN = 'Y'
	BEGIN
		IF (ISNULL(@Exists, 0) = 0)
		BEGIN
			INSERT INTO watchdogparameter (Heading, Subheading, ParameterName, ParameterValue, ParameterDescription, ParameterSort, DisplayOnEmail)
			SELECT 'watchdogstoredproc', @WatchName, @ParameterName, @ParameterValue, @WatchName + ', ' + @ParameterName, 0, 0
		END
	END

	SELECT [Exists] = ISNULL(@Exists, 0), ParameterValue = ISNULL(@ParameterValue, ''), DisplayOnEmail = ISNULL(@DisplayOnEmail, 0)
GO
GRANT EXECUTE ON  [dbo].[WatchdogParameterLookup] TO [public]
GO
