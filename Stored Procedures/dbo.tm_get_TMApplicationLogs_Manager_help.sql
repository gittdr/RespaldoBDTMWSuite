SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_get_TMApplicationLogs_Manager_help]	
					@LogEntrySN int,
					@MCSN int,
					@MCInstance varchar(50),
					@PollerInstance varchar(50),
					@AssemblyName varchar(256),
					@ModuleName varchar(256),
					@MethodName varchar(256),
					@StepDescription varchar(4000),
					@Message varchar(4000),
					@SessionID int,
					@MaxLogs int,
					@FromDate datetime,
					@ToDate datetime,
					@OrderByDateOrder varchar(20)

as


DECLARE @sSQL NVARCHAR(4000)
DECLARE @sSQL_SUBSET NVARCHAR(4000)
DECLARE @sSQL_WHERE NVARCHAR(4000)

DECLARE @sMainInsert varchar(8000), @iStatus int, @iStatusToCheck int

if ISNULL(@LogEntrySN, 0) > 0
	BEGIN
		IF ISNULL(@MaxLogs, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxLogs)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'

		SET @sSQL_SUBSET = @sSQL_SUBSET + ' tblTMApplicationLog.SN
			FROM tblTMApplicationLog (nolock) '

		SET @sSQL_WHERE = ' WHERE tblTMApplicationLog.SN = ' + CONVERT(VARCHAR(12), @LogEntrySN)

	END
else
	BEGIN
		if ISNULL(@MCSN, -999999999) <> -999999999
			BEGIN

				IF ISNULL(@MaxLogs, 0) > 0 
					SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxLogs)
				ELSE
					SET @sSQL_SUBSET = ' SELECT'

				SET @sSQL_SUBSET = @sSQL_SUBSET + ' tblTMApplicationLog.SN
					FROM tblTMApplicationLog (nolock) '

				SET @sSQL_WHERE = ' WHERE tblTMApplicationLog.MCSN = ' + CONVERT(VARCHAR(12), @MCSN)

			END

		ELSE
			BEGIN
				IF ISNULL(@MaxLogs, 0) > 0 
					SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxLogs)
				ELSE
					SET @sSQL_SUBSET = ' SELECT'

				SET @sSQL_SUBSET = @sSQL_SUBSET + '  tblTMApplicationLog.SN
					FROM tblTMApplicationLog (nolock) '

				SET @sSQL_WHERE = ''

			END
	END

	SET @sMainInsert = ''

	if ISNULL(@MCInstance, 'null') <> 'null'
		BEGIN
			SET @sMainInsert = @sMainInsert + ' AND tblTMApplicationLog.MCInstance = ''' +  @MCInstance + ''''
		END
	if ISNULL(@PollerInstance, 'null') <> 'null'
		BEGIN
			SET @sMainInsert = @sMainInsert + ' AND tblTMApplicationLog.PollerInstance = ''' +  @PollerInstance + ''''
		END
	if ISNULL(@AssemblyName, 'null') <> 'null'
		BEGIN
			SET @sMainInsert = @sMainInsert + ' AND tblTMApplicationLog.AssemblyName = ''' +  @AssemblyName + ''''
		END
	if ISNULL(@ModuleName, 'null') <> 'null'
		BEGIN
			SET @sMainInsert = @sMainInsert + ' AND tblTMApplicationLog.ModuleName = ''' +  @ModuleName + ''''
		END
	if ISNULL(@MethodName, 'null') <> 'null'
		BEGIN
			SET @sMainInsert = @sMainInsert + ' AND tblTMApplicationLog.MethodName = ''' +  @MethodName + ''''
		END
	if ISNULL(@StepDescription, 'null') <> 'null'
		BEGIN
			SET @sMainInsert = @sMainInsert + ' AND CONVERT(VARCHAR(4000), tblTMApplicationLog.StepDescription) = ''' +  @StepDescription + ''''
		END
	if ISNULL(@Message, 'null') <> 'null'
		BEGIN
			SET @sMainInsert = @sMainInsert + ' AND CONVERT(VARCHAR(4000),tblTMApplicationLog.Message) = ''' +  @Message + ''''
		END
	if ISNULL(@SessionID, -999999999) <> -999999999
		BEGIN
			SET @sMainInsert = @sMainInsert + ' AND tblTMApplicationLog.SessionID = ' + CONVERT(VARCHAR(12), @SessionID)
		END

if ISNULL(@FromDate, '') <> ''
	BEGIN
	if @FromDate > '1/1/1901' 
		SET @sSQL_WHERE = @sSQL_WHERE + ' AND ( MessageDate >= ''' + CONVERT(VARCHAR(30), @FromDate) + ''')'
	END
	
if ISNULL(@ToDate, '') <> ''
	BEGIN
	if @ToDate > '1/1/1901' 
		SET @sSQL_WHERE = @sSQL_WHERE + ' AND ( MessageDate <= ''' + CONVERT(VARCHAR(30), @ToDate) + ''')'
	END

if ISNULL(@sMainInsert, '') <> '' 
	BEGIN
		IF ISNULL(@sSQL_WHERE, '') <> ''
			SET @sSQL_WHERE = @sSQL_WHERE + ' ' + @sMainInsert 
		ELSE
			SET @sSQL_WHERE = @sMainInsert
	END

IF ISNULL(@sSQL_WHERE, '') <> ''
	SET @sSQL_WHERE = ' WHERE 1=1 ' + @sSQL_WHERE

SET @sSQL = @sSQL_SUBSET + ' ' + @sSQL_WHERE

SET @sSQL = @sSQL + ' ORDER BY MessageDate'
	
if ISNULL(@OrderByDateOrder, '') <> ''
	SET @sSQL = @sSQL + ' ' + @OrderByDateOrder
ELSE
	SET @sSQL = @sSQL + ' desc'

EXEC sp_ExecuteSQL @sSQL

GO
GRANT EXECUTE ON  [dbo].[tm_get_TMApplicationLogs_Manager_help] TO [public]
GO
