SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogParameterForEmailDisplayLookup] (@WatchName varchar(255))
AS
	SET NOCOUNT ON

	SELECT ParameterName, ParameterValue 
	FROM WatchDogParameter(NOLOCK) 
	WHERE Heading = 'WatchDogStoredProc'
          AND SubHeading = @WatchName 
		  AND ParameterValue IS NOT NULL
          AND ISNULL(DisplayOnEmail, 0) = 1
GO
GRANT EXECUTE ON  [dbo].[WatchdogParameterForEmailDisplayLookup] TO [public]
GO
