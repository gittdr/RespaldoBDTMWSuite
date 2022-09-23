SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogCreateAlert] (@NewName varchar(75), @SQLStatement varchar(200), @ActiveFlag int = NULL )
AS
	SET NOCOUNT ON

	DECLARE @dummy int

	SELECT @ActiveFlag = ISNULL(@ActiveFlag, 0)

	IF NOT EXISTS(SELECT * FROM watchdogitem WHERE watchname = @NewName)
	BEGIN
		INSERT INTO WatchdogItem (WatchName, SQLStatement, ParentWatchName,
				Operator, ThresholdValue, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, NumericOrText, MinsBackToRun, [Description], LastRunDate,
				TimeValue, TimeType, AttachFileToEmail, AttachType, UpdateFlag, DataSourceSN, ActiveFlag
			)
		SELECT @NewName, @SQLStatement, @NewName, 
				'', '', '', 0, 0, '', '', '', @NewName, GETDATE(),
				0, '', 0, '', 0, 0, @ActiveFlag
	END

GO
GRANT EXECUTE ON  [dbo].[WatchdogCreateAlert] TO [public]
GO
