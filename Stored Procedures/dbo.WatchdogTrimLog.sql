SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogTrimLog](@ForceTrimWithoutParameterChecks varchar(1) = 'Y') 
AS
	SET NOCOUNT ON

	DECLARE @RunComment varchar(255), @WithinTimeRangeYN varchar(1), @ReadyToTrimYN varchar(1), @GETDATE datetime, @CountOfDeletedRecords int
	DECLARE @TrimLog_MaxMinutesSinceLast_Parm varchar(100), @TrimLog_MaxMinutesSinceLast int
	DECLARE @TrimLog_LowTime_Parm varchar(100), @TrimLog_LowTime datetime
	DECLARE @TrimLog_HighTime_Parm varchar(100), @TrimLog_HighTime datetime
	DECLARE @TrimLog_HoursToKeep_Parm varchar(100), @TrimLog_HoursToKeep int
	DECLARE @TrimLog_LastDateTimeRun_Parm varchar(100), @TrimLog_LastDateTimeRun datetime

	SELECT @GETDATE = GETDATE(), @CountOfDeletedRecords = -1,
			@RunComment = '', @WithinTimeRangeYN = '?', @ReadyToTrimYN = '?'

	SELECT @TrimLog_LowTime_Parm = SettingValue FROM WatchDogGeneralSettings WHERE SettingName = 'TrimLog_LowTime'
	SET @TrimLog_LowTime = CASE WHEN ISDATE(@TrimLog_LowTime_Parm) = 1 THEN CONVERT(datetime, @TrimLog_LowTime_Parm) ELSE '20:00' END

	SELECT @TrimLog_HighTime_Parm = SettingValue FROM WatchDogGeneralSettings WHERE SettingName = 'TrimLog_HighTime'
	SET @TrimLog_HighTime = CASE WHEN ISDATE(@TrimLog_HighTime_Parm) = 1 THEN CONVERT(datetime, @TrimLog_HighTime_Parm) ELSE '05:00' END

	IF @ForceTrimWithoutParameterChecks = 'N'  --- No need to check if within range if being forced. So proc defaults to 'Y' for "don't check, just run.".
	BEGIN
		IF (dbo.fnc_TMWRN_IsTimeWithinRange(GETDATE(), @TrimLog_LowTime, @TrimLog_HighTime) = 'Y') 
		BEGIN
			SET @RunComment = @RunComment + 'Within time range./'
			SELECT @WithinTimeRangeYN = 'Y'
		END
		ELSE
		BEGIN
			SET @RunComment = @RunComment + 'Outside of time range./'
			SELECT @WithinTimeRangeYN = 'N'
		END
	END
	ELSE
		SET @RunComment = @RunComment + 'No need to check time range because @ForceTrimWithoutParameterChecks=Y./'

	IF (@ForceTrimWithoutParameterChecks = 'Y') OR (@WithinTimeRangeYN = 'Y')
	BEGIN
		/*** START: Lookup last date/time the process ran.  @TrimLog_LastDateTimeRun ***/
		SELECT @TrimLog_LastDateTimeRun_Parm = SettingValue FROM WatchDogGeneralSettings WHERE SettingName = 'TrimLog_LastDateTimeRun'
		SET @TrimLog_LastDateTimeRun = CASE WHEN ISDATE(@TrimLog_LastDateTimeRun_Parm) = 1 THEN CONVERT(datetime, @TrimLog_LastDateTimeRun_Parm) ELSE '19500101' END
		/*** END: Lookup last date/time the process ran.  @TrimLog_LastDateTimeRun ***/

		/*** START: Look up MaxMinutesSinceLast.  @TrimLog_MaxMinutesSinceLast ***/
		SELECT @TrimLog_MaxMinutesSinceLast_Parm = SettingValue FROM WatchDogGeneralSettings WHERE SettingName = 'TrimLog_MaxMinutesSinceLast'
		SET @TrimLog_MaxMinutesSinceLast = CASE WHEN ISNUMERIC(@TrimLog_MaxMinutesSinceLast_Parm) = 1 THEN CONVERT(int, ROUND(@TrimLog_MaxMinutesSinceLast_Parm, 0)) ELSE 120 END
		/*** END: Look up MaxMinutesSinceLast.  @TrimLog_MaxMinutesSinceLast ***/

		IF @ForceTrimWithoutParameterChecks = 'N'  --- No need to check if within range if being forced. So proc defaults to 'Y' for "don't check, just run.".
		BEGIN
			IF (DATEDIFF(minute, @TrimLog_LastDateTimeRun, @GETDATE) > @TrimLog_MaxMinutesSinceLast) 
			BEGIN
				SET @RunComment = @RunComment + 'Ready to run./'
				SET @ReadyToTrimYN = 'Y' 
			END
			ELSE 
			BEGIN
				SET @RunComment = @RunComment + 'NOT ready to run./'
				SET @ReadyToTrimYN = 'N'
			END
		END
		ELSE
			SET @RunComment = @RunComment + 'No need to check last time run because @ForceTrimWithoutParameterChecks=Y./'
			

		IF (@ForceTrimWithoutParameterChecks = 'Y') OR (@ReadyToTrimYN = 'Y')
		BEGIN
			/*** START: Determine Hours to Keep.  @TrimLog_HoursToKeep ***/
			SELECT @TrimLog_HoursToKeep_Parm = SettingValue FROM WatchDogGeneralSettings WHERE SettingName = 'TrimLog_HoursToKeep'
			SET @TrimLog_HoursToKeep = CASE WHEN ISNUMERIC(@TrimLog_HoursToKeep_Parm) = 1 THEN CONVERT(int, ROUND(@TrimLog_HoursToKeep_Parm, 0)) ELSE 168 END -- Default to 24 hours * 7 days.
			/*** END: Determine Hours to Keep.  @TrimLog_HoursToKeep ***/

			SELECT @CountOfDeletedRecords = COUNT(*) FROM dbo.WatchdogLogInfo WHERE DateAndTime < DATEADD(hour, -@TrimLog_HoursToKeep, @GETDATE)

			DELETE dbo.WatchdogLogInfo WHERE DateAndTime < DATEADD(hour, -@TrimLog_HoursToKeep, @GETDATE)

			UPDATE WatchDogGeneralSettings SET SettingValue = CONVERT(varchar(100), GETDATE(), 121) WHERE SettingName = 'TrimLog_LastDateTimeRun'

			SET @RunComment = @RunComment + CONVERT(varchar(15), @CountOfDeletedRecords) + ' records deleted./'
		END
	END

	IF @CountOfDeletedRecords > -1 
	BEGIN
		INSERT INTO dbo.WatchdogLogInfo (Event, MachineName, WatchName, Fired_YN, Results_YN, ErrorOnRun_YN, ErrorOnEmail_YN, ErrorDescription, RunDuration, MoreInfo)
		SELECT 'Dawg procedure: WatchdogTrimLog', HOST_NAME(), '', '', '', '', '', '', DATEDIFF(ms, @GETDATE, GETDATE()) / 1000.0, @RunComment
	END

	SELECT '@RunComment' = @RunComment, 
			'@ForceTrimWithoutParameterChecks' = @ForceTrimWithoutParameterChecks, 
			'@WithinTimeRangeYN' = @WithinTimeRangeYN, 
			'@ReadyToTrimYN' = @ReadyToTrimYN,
			'@TrimLog_MaxMinutesSinceLast_Parm' = @TrimLog_MaxMinutesSinceLast_Parm,
			'@TrimLog_MaxMinutesSinceLast' = @TrimLog_MaxMinutesSinceLast,
			'@TrimLog_LowTime_Parm' = @TrimLog_LowTime_Parm, 
			'@TrimLog_LowTime' = @TrimLog_LowTime,
			'@TrimLog_HighTime_Parm' = @TrimLog_HighTime_Parm, 
			'@TrimLog_HighTime' = @TrimLog_HighTime,
			'@TrimLog_HoursToKeep_Parm' = @TrimLog_HoursToKeep_Parm, 
			'@TrimLog_HoursToKeep' = @TrimLog_HoursToKeep,
			'@TrimLog_LastDateTimeRun_Parm' = @TrimLog_LastDateTimeRun_Parm, 
			'@TrimLog_LastDateTimeRun' = @TrimLog_LastDateTimeRun,
			'@CountOfDeletedRecords' = @CountOfDeletedRecords

GO
GRANT EXECUTE ON  [dbo].[WatchdogTrimLog] TO [public]
GO
