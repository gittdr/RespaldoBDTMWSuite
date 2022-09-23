SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogGetParmsForConfig](@WatchName varchar(255))
AS
	SELECT Column_name = ParameterName, Ordinal_Position = ParameterSort 
	FROM watchdogparameter WITH (NOLOCK) 
	WHERE Heading = 'watchdogstoredproc' AND SubHeading = @WatchName
GO
GRANT EXECUTE ON  [dbo].[WatchdogGetParmsForConfig] TO [public]
GO
