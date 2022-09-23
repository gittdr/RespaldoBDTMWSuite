SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogSetParameters](@WatchName varchar(255), @Column_Name varchar(255), @DisplayOnEmail int = 0, @ThisParm varchar(1000), @Ordinal_Position int )
AS
	IF EXISTS(SELECT * FROM watchdogparameter WHERE Heading = 'WatchDogStoredProc' AND SubHeading = @WatchName AND ParameterName = @Column_Name)
		UPDATE watchdogparameter 
		SET DisplayOnEmail = @DisplayOnEmail, 
			ParameterValue = CASE WHEN @ThisParm = '' THEN NULL ELSE @ThisParm END 
		WHERE Heading = 'WatchDogStoredProc' AND SubHeading = @WatchName AND ParameterName = @Column_Name
    ELSE
		INSERT INTO watchdogparameter (Heading, SubHeading, ParameterName, ParameterSort, ParameterValue, DisplayOnEmail) 
		SELECT 'watchdogstoredproc', @WatchName, @Column_Name, @Ordinal_Position, CASE WHEN @ThisParm = '' THEN NULL ELSE @ThisParm END, @DisplayOnEmail
GO
GRANT EXECUTE ON  [dbo].[WatchdogSetParameters] TO [public]
GO
