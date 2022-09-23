SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricAddQueuedJob] (
	@UserSN int,
	@metricCode varchar(200),
	@SQL varchar(4000),
	@DatabaseName varchar(255),
	@FilePath varchar(512)
)
AS
	SET NOCOUNT ON

	DECLARE @job_id UNIQUEIDENTIFIER 
	DECLARE @jobname varchar(512)
	DECLARE @MyGUID varchar(36)
	DECLARE @fileName varchar(512)
	DECLARE @JobCommand varchar(4000)

	SET @MyGUID = CONVERT(varchar(36), NEWID())
	IF RIGHT(@FilePath, 1) <> '\' 
	BEGIN
		SET @FilePath = @FilePath + '\'
	END

	SET @FileName = @FilePath + @MyGUID + '.txt'
	SET @jobname = 'TMWRN Queued Report (' + CONVERT(varchar(16), GETDATE(), 121) + ') for ' + @metriccode + ': ' + @MyGuid
	EXEC msdb.dbo.sp_add_job @job_name = @jobname, 
			@enabled = 1, 
			@description = @jobname, 
			@delete_level = 3, -- 3: always 3 after one run.
			@job_id = @job_id OUTPUT 


    SET @JobCommand = 'UPDATE MetricQueuedReports SET dtStarted = GETDATE() WHERE Report_GUID = ''' + @MyGuid + ''''
	EXEC msdb.dbo.sp_add_jobstep @job_id = @job_id
		,@step_name = 'Step 1'
		,@subsystem = 'TSQL'
		,@command = @JobCommand
		,@database_name = @DatabaseName
		,@flags = 0
		,@on_success_action = 3

    SET @JobCommand = @SQL
	EXEC msdb.dbo.sp_add_jobstep @job_id = @job_id
		,@step_name = 'Step 2'
		,@subsystem = 'TSQL'
		,@command = @JobCommand
		,@database_name = @DatabaseName
		,@output_file_name = @filename
		,@flags = 0
		,@on_success_action = 3

    SET @JobCommand = 'UPDATE MetricQueuedReports SET status = ''Ready'', RunDuration= DATEDIFF(ms, dtStarted, GETDATE()), dtReady = GETDATE()  WHERE Report_GUID = ''' + @MyGuid + ''''
	EXEC msdb.dbo.sp_add_jobstep @job_id = @job_id
		,@step_name = 'Step 3'
		,@subsystem = 'TSQL'
		,@command = @JobCommand
		,@database_name = @DatabaseName
		,@flags = 0
		-- ,@on_success_action = 3



	EXEC msdb.dbo.sp_add_jobserver @job_id = @job_id

	-- SELECT @MyJobId = job_id from msdb.dbo.sysjobsteps WHERE job_id = @job_id -- step_uid 

	INSERT INTO MetricQueuedReports (UserSN, Status, Report_GUID, dtCreate, dtReady, dtRead, SQL, Path)
	SELECT UserSN = @UserSN, [Status] = 'Queued', Report_GUID = @MyGuid, dtCreate = GETDATE(), dtReady = NULL, dtRead = NULL, @SQL, @FilePath

	EXEC msdb.dbo.sp_start_job @job_id = @job_id

	SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[MetricAddQueuedJob] TO [public]
GO
