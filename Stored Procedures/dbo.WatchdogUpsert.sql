SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogUpsert](@UpdatedWatchName varchar(255), @WatchName varchar(255)
	, @SqlStatement varchar(255) = ''
	, @ThresholdValue varchar(150) = ''
	, @EmailAddress varchar(2000) = ''
	, @MinsBackToRun varchar(25) = ''
	, @ActiveFlag int = 0
	, @UpdateFlag int = 0
	, @HTMLTemplateFlag int = 0
	, @ProcName varchar(255) = ''
	, @EnableFileAttachment int
	, @FileAttachmentType varchar(150) = ''
	, @Description varchar(500) = ''
	, @ScheduleId int = 0
	, @NextScheduledRun varchar(100) -- Turns into a date time.
	, @ConsecutiveFailures int = 0
	, @ConsecutiveFailuresLimit int = 0
	, @DataSourceSN int = 0
	, @TemplateFilename varchar(255) = ''
	, @WatchdogTimeout int = 30
	, @SubjectOverride varchar(255) = ''
	, @AttachmentFilenameOverride varchar(255) = ''
	, @WorkflowDataSourceSN int = 0
	, @Workflow_Template_ID int = 0
	, @WorkFlow_Current_Sequence_ID int = 0
	, @TotalMailFormId int = 0
	-- , @BeginDate varchar(100)
	-- , @EndDate varchar(100)
	-- , @Operator varchar(100)
)
AS
	-- sp_help WatchDogItem 
	SET NOCOUNT ON

	IF EXISTS(SELECT * FROM WatchDogItem WHERE WatchName = @watchname)
		Update WatchDogItem 
		Set SqlStatement = @SqlStatement
	        ,ThresholdValue = @ThresholdValue
		    ,EmailAddress = @emailaddress
		    ,MinsBackToRun = @MinsBackToRun
		    ,ActiveFlag =  @ActiveFlag
		    ,UpdateFlag = @UpdateFlag
		    ,HTMLTemplateFlag =  @HTMLTemplateFlag
		    ,ProcName = @ProcName
			,AttachFileToEmail =  @EnableFileAttachment
		    ,AttachType = @FileAttachmentType
		    ,Description = @Description
			,ScheduleID =  @ScheduleId  
		    ,ScheduledRun = @NextScheduledRun
   		    ,ConsecutiveFailures = @ConsecutiveFailures
		    ,ConsecutiveFailuresLimit =  @ConsecutiveFailuresLimit
		    ,DataSourceSN = @DataSourceSN
		    ,TemplateFilename = @TemplateFilename
		    ,WatchdogTimeout = @WatchdogTimeout
		    ,SubjectOverride = @SubjectOverride
		    ,AttachmentFilenameOverride = @AttachmentFilenameOverride 
			,WorkflowDataSourceSN = @WorkflowDataSourceSN
		    ,Workflow_Template_ID =  @Workflow_Template_ID
	        ,WorkFlow_Current_Sequence_ID = @WorkFlow_Current_Sequence_ID
	        ,TotalMailFormId = @TotalMailFormId
        WHERE WatchName = @WatchName
	ELSE
    BEGIN 
/*		INSERT INTO WatchDogItem (WatchName,BeginDate,EndDate,SqlStatement,Operator,ThresholdValue,EmailAddress,BeginDateMinusDays,EndDatePlusDays, 
			        DateField,ProcName,NumericOrText,MinsBackToRun,ActiveFlag,UpdateFlag,HTMLTemplateFlag,Description,TimeValue,TimeType,AttachFileToEmail,  
 			        AttachType,LastRunDate,ParentWatchName, ScheduleID, ScheduledRun, ConsecutiveFailures, ConsecutiveFailuresLimit, DataSourceSN, TemplateFilename, WatchdogTimeout,  
                                WorkflowDataSourceSN, Workflow_Template_ID, WorkFlow_Current_Sequence_ID, SubjectOverride, AttachmentFilenameOverride )  
                                */
        INSERT INTO WatchDogItem (ParentWatchName, WatchName, SqlStatement, ThresholdValue,EmailAddress, ProcName, MinsBackToRun, ActiveFlag, HTMLTemplateFlag, Description, AttachFileToEmail,  
 			        AttachType, ScheduleID, ScheduledRun, ConsecutiveFailures, ConsecutiveFailuresLimit, DataSourceSN, TemplateFilename, WatchdogTimeout,  
                                WorkflowDataSourceSN, Workflow_Template_ID, WorkFlow_Current_Sequence_ID, SubjectOverride, AttachmentFilenameOverride, TotalMailFormId )
		SELECT @UpdatedWatchName, @WatchName, @SQLStatement, @ThresholdValue, @EmailAddress, @ProcName, @MinsBackToRun, @ActiveFlag, @HTMLTemplateFlag, @Description, @EnableFileAttachment
				,@FileAttachmentType, @ScheduleId, @NextScheduledRun, @ConsecutiveFailures, @ConsecutiveFailuresLimit, @DataSourceSN, @TemplateFilename, @WatchdogTimeout
							,@WorkflowDataSourceSN, @Workflow_Template_ID, @WorkFlow_Current_Sequence_ID, @SubjectOverride, @AttachmentFilenameOverride, @TotalMailFormId

		-- Delete anything that happens to be stuck in the new watchdog column list.
	    DELETE WatchdogColumn WHERE watchname = @watchname

		-- Copy the columns "from the watchdog that was copied" into this set of columns.
		INSERT INTO WatchdogColumn (WatchName, ColumnName, AliasColumnName, DisplayOrder) 
		SELECT @watchname, ColumnName, AliasColumnName, DisplayOrder 
		FROM WatchdogColumn WHERE watchname = @UpdatedWatchName
    END

GO
GRANT EXECUTE ON  [dbo].[WatchdogUpsert] TO [public]
GO
