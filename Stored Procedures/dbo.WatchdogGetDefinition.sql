SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[WatchdogGetDefinition] (@WatchName varchar(255))

AS
	Select sn, WatchName, BeginDate, EndDate, SqlStatement, Operator, ThresholdValue, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, 
		HTMLTemplateFlag, TemplateFileName, ActiveFlag, DefaultCurrency, CurrencyDateType, Description, LastRunDate, ScheduleWatchDog, TimeValue, TimeType, RunMinsBackFromScheduleTime, AttachFileToEmail, AttachType, 
		ParentWatchName, SubjectNamingRule, AttachmentFileNamingRule, UpdateFlag, WatchdogTimeOut = ISNULL(WatchdogTimeOut, 30), 
		CheckedOut, ScheduleID, ScheduledRun, DataSourceSN = ISNULL(DataSourceSN, 0), ConsecutiveFailures = ISNULL(ConsecutiveFailures, 0), ConsecutiveFailuresLimit = ISNULL(ConsecutiveFailuresLimit, 3), 
		WorkflowDataSourceSN = ISNULL(WorkflowDataSourceSN, 0), Workflow_Template_Id, Workflow_Current_Sequence_ID, 
	 	SubjectOverride = ISNULL(SubjectOverride, ''), AttachmentFilenameOverride = ISNULL(AttachmentFilenameOverride, '') ,
	 	TotalMailFormId = ISNULL(TotalMailFormId, 0)
	From WatchDogItem (NOLOCK)
	Where WatchName = @WatchName
GO
GRANT EXECUTE ON  [dbo].[WatchdogGetDefinition] TO [public]
GO
