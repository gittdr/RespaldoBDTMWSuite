SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_get_Messages_Manager_help]	
					@LoginSN int,
					@LoginInboxSN int,
					@TruckSN int,
					@DriverSN int,
					@MessageSN int,
					@MessageSNType int,
					@FolderSN int,
					@sDispatchKey1 varchar(20),
					@sDispatchKey2 varchar(20),
					@sDispatchKeyType varchar(10),
					@FormID as int,
					@MaxMessages int,
					@FromDate datetime,
					@ToDate datetime,
					@RetrievalDateToUse varchar(20),
					@OrderByDate varchar(20),
					@OrderByDateOrder varchar(20),
					@ErroredMessagesOnly varchar(1),
					@FormIDFilter as int,
					@ExportedFlag varchar(1)=NULL,
					@Flags varchar(12)=NULL

as

DECLARE @sSQL NVARCHAR(4000)
DECLARE @sSQL_SUBSET NVARCHAR(4000)
DECLARE @sSQL_WHERE NVARCHAR(4000)
DECLARE @iFlags int

SET @iFlags = CONVERT(int, ISNULL(@Flags,'0'))

if ISNULL(@LoginSN, 0) > 0
	BEGIN

		-- If no login inbox was provided, go find it.
		IF ISNULL(@LoginInboxSN, 0)=0
			SELECT @LoginInboxSN = Inbox FROM tblLogin WITH (NOLOCK) WHERE SN = @LoginSN

		-- Get the full folder list into a temp table.
		IF ISNULL(@MaxMessages, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxMessages)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'

		SET @sSQL_SUBSET = @sSQL_SUBSET + ' tblMessages.SN 
			FROM tblMessages (nolock) '
			
		SET @sSQL_WHERE = 'WHERE tblMessages.Folder IN (SELECT Inbox FROM tblDispatchGroup (NOLOCK) 
						JOIN tblDispatchLogins (NOLOCK) ON tblDispatchLogins.DispatchGroupSN = tblDispatchGroup.SN
						WHERE tblDispatchLogins.LoginSN = ' + CONVERT(VARCHAR(12), @LoginSN) + ') OR Folder = ' + CONVERT(VARCHAR(12), @LoginInboxSN) 
		
	END

if ISNULL(@TruckSN, 0) > 0
	BEGIN

		IF ISNULL(@MaxMessages, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxMessages)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'
		
		SET @sSQL_SUBSET = @sSQL_SUBSET + ' tblHistory.MsgSn SN 
			FROM tblHistory (nolock) 
			INNER JOIN tblMessages ON tblHistory.MsgSN = tblMessages.SN '
		
		SET @sSQL_WHERE = ' WHERE tblHistory.TruckSN = ' + CONVERT(VARCHAR(12), @TruckSN ) --+ ' 

	END

if ISNULL(@DriverSN, 0) > 0
	BEGIN
		IF ISNULL(@MaxMessages, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxMessages)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'
		
		SET @sSQL_SUBSET = @sSQL_SUBSET + ' tblHistory.MsgSn SN 
			FROM tblHistory (nolock) 
			INNER JOIN tblMessages ON tblHistory.MsgSN = tblMessages.SN '

		SET @sSQL_WHERE = 'WHERE tblHistory.DriverSN = ' + CONVERT(VARCHAR(12), @DriverSN) --+ ' 

	END

if ISNULL(@FolderSN, 0) > 0 AND ISNULL(@FormID, 0) = 0
	BEGIN

		IF ISNULL(@MaxMessages, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxMessages)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'
		
		SET @sSQL_SUBSET = @sSQL_SUBSET + ' tblMessages.SN 
			FROM tblMessages (nolock) '

		SET @sSQL_WHERE = ' WHERE tblMessages.Folder = ' + CONVERT(VARCHAR(12), @FolderSN)

	END

if ISNULL(@FormID, 0) <> 0
	BEGIN
		IF ISNULL(@MaxMessages, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxMessages)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'

		-- Get the full folder list into a temp table.
		SET @sSQL_SUBSET = @sSQL_SUBSET + ' tblMessages.SN 
			FROM tblMessages (nolock) 
			INNER JOIN tblMsgProperties  on tblMessages.SN = tblMsgProperties.MsgSN '

		IF @FormID > 2000000
			BEGIN
				--Beyond 2 million means SN and not the FormID
				SET @FormID = @FormID - 2000000
				SET @sSQL_WHERE = ' WHERE tblMsgProperties.PropSN = 2 AND tblMsgProperties.Value = ' + CONVERT(VARCHAR(12), @FormID) +
						' AND Status = CASE WHEN ' + CONVERT(VARCHAR(12), @FormID) + ' < 0 THEN ''Current'' ELSE Status END'
			END
		ELSE
			BEGIN
				SET @sSQL_WHERE = ' WHERE tblMsgProperties.PropSN = 2 AND tblMsgProperties.Value IN 
						(SELECT SN FROM tblForms where FormID = ABS(' + CONVERT(VARCHAR(12), @FormID) + ') AND Status = CASE WHEN ' + CONVERT(VARCHAR(12), @FormID) + ' < 0 THEN ''Current'' ELSE Status END)'
			END

		IF ISNULL(@FolderSN, 0) <> 0
			SET @sSQL_WHERE = @sSQL_WHERE + ' AND tblMessages.Folder = @FolderSN '

	END

if ISNULL(@MessageSN, 0) > 0
	BEGIN
		SET @sSQL_SUBSET = ' SELECT tblMessages.SN 
			FROM tblMessages (nolock) '

		if ISNULL(@MessageSNType, 0) = 0
			SET @sSQL_WHERE = ' WHERE SN = ' + CONVERT(VARCHAR(12), @MessageSN)
		else
			BEGIN

				if @MessageSNType = 1 --BaseSN
					SET @sSQL_WHERE = ' WHERE BaseSN = ' + CONVERT(VARCHAR(12), @MessageSN)
				else if @MessageSNType = 2 --OrigMsgNS
					SET @sSQL_WHERE = ' WHERE OrigMsgSN = ' + CONVERT(VARCHAR(12), @MessageSN)
				else if @MessageSNType = 3 --ReplyMsgSN
					SET @sSQL_WHERE = ' WHERE ReplyMsgSN = ' + CONVERT(VARCHAR(12), @MessageSN)
				else if @MessageSNType = 3 --ResubmitOFSN
					SET @sSQL_WHERE = ' WHERE ResubmitOf = ' + CONVERT(VARCHAR(12), @MessageSN)
				else
					SET @sSQL_WHERE = ' WHERE SN = ' + CONVERT(VARCHAR(12), @MessageSN)
			END	
	END

if ISNULL(@sDispatchKey1, '') <> ''
	BEGIN
		IF ISNULL(@MaxMessages, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxMessages)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'
		
		SET @sSQL_SUBSET = @sSQL_SUBSET + ' tblMessages.SN 
			FROM tblMessages (nolock) 
			INNER JOIN tblMsgShareData ON tblMessages.SN = tblMsgShareData.OrigMsgSN '
		
		SET @sSQL_WHERE = ' WHERE tblMsgShareData.DispSysKey1 = ''' + @sDispatchKey1 + ''' AND tblMsgShareData.DispSysKeyType = ''' + @sDispatchKeyType + ''''

	END

if ISNULL(@sDispatchKey2, '') <> ''
	BEGIN
		IF ISNULL(@MaxMessages, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxMessages)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'
		
		SET @sSQL_SUBSET = @sSQL_SUBSET + '  tblMessages.SN 
			FROM tblMessages (nolock) 
			INNER JOIN tblMsgShareData ON tblMessages.SN = tblMsgShareData.OrigMsgSN '

		SET @sSQL_WHERE = ' WHERE tblMsgShareData.DispSysKey2 = ''' + @sDispatchKey2 + ''' AND tblMsgShareData.DispSysKeyType = ''' + @sDispatchKeyType + ''''

	END

if CONVERT(int, @ErroredMessagesOnly) <> 0 OR ISNULL (@FormIDFilter, 0) > 0
	BEGIN
		SET @sSQL_SUBSET = @sSQL_SUBSET + ' INNER JOIN tblMsgProperties ON tblMessages.SN = tblMsgProperties.MsgSN '
		if CONVERT(int, @ErroredMessagesOnly) <> 0
			BEGIN
				SET @sSQL_WHERE = @sSQL_WHERE + ' AND tblMsgProperties.PropSN = 6 '
				IF ISNULL (@FormIDFilter , 0) > 0
					SET @sSQL_WHERE = @sSQL_WHERE + ' AND (tblMsgProperties.PropSN = 2 AND ISNULL(Value, -1) = ' + CONVERT(varchar(12), @FormIDFilter ) + ')'		
			END
		else
			BEGIN
				IF ISNULL (@FormIDFilter , 0) > 0
					SET @sSQL_WHERE = @sSQL_WHERE + ' AND (tblMsgProperties.PropSN = 2 AND ISNULL(tblMsgProperties.Value, -1) IN (SELECT SN FROM tblForms WHERE FormId = ' + CONVERT(varchar(12), @FormIDFilter) + '))'		
			END
	END

if ISNULL(@FromDate, '') <> ''
	BEGIN
	if @FromDate > '1/1/1901' 
		SET @sSQL_WHERE = @sSQL_WHERE + ' AND (' + @RetrievalDateToUse + ' >= ''' + CONVERT(VARCHAR(30), @FromDate) + ''')'
	END
	
if ISNULL(@ToDate, '') <> ''
	BEGIN
	if @ToDate > '1/1/1901' 
		SET @sSQL_WHERE = @sSQL_WHERE + ' AND (' + @RetrievalDateToUse + ' <= ''' + CONVERT(VARCHAR(30), @ToDate) + ''')'
	END

if ISNULL(@ExportedFlag, '') <> ''
	BEGIN
	if @ExportedFlag = '0' 
		SET @sSQL_WHERE = @sSQL_WHERE + ' AND (ISNULL(Export, 0) = 0)'
	else if @ExportedFlag <> '0' 
		SET @sSQL_WHERE = @sSQL_WHERE + ' AND (ISNULL(Export, 0) <> 0)'
	END

--Only get messages with their DeliveryKey set as a positive value
if (@iFlags & 2 > 0)
	SET @sSQL_WHERE = @sSQL_WHERE + ' AND (ISNULL(DeliveryKey, 0) >= 0)'

SET @sSQL = @sSQL_SUBSET + ' ' + @sSQL_WHERE

if ISNULL(@OrderByDate, '') <> ''
	SET @sSQL = @sSQL + ' ORDER BY ' + @OrderByDate 
ELSE
	SET @sSQL = @sSQL + ' ORDER BY dtsent'
	
if ISNULL(@OrderByDateOrder, '') <> ''
	SET @sSQL = @sSQL + ' ' + @OrderByDateOrder
ELSE
	SET @sSQL = @sSQL + ' desc'

EXEC sp_ExecuteSQL	@sSQL,
					@params=N'@LoginSN int,
							  @LoginInboxSN int,
							  @TruckSN int,
							  @DriverSN int,
							  @FolderSN int,
							  @FormID int,
							  @MessageSN int,
							  @sDispatchKey1 varchar(20),
							  @sDispatchKey2 varchar(20),
							  @sDispatchKeyType varchar(10),
							  @FormIDFilter int,
							  @RetrievalDateToUse varchar(20),
							  @FromDate datetime,
							  @ToDate datetime',
							@LoginSN=@LoginSN,
							@LoginInboxSN=@LoginInboxSN,
							@TruckSN=@TruckSN,
							@DriverSN=@DriverSN,
							@FolderSN=@FolderSN,
							@FormID=@FormID,
							@MessageSN=@MessageSN,
							@sDispatchKey1=@sDispatchKey1,
							@sDispatchKey2=@sDispatchKey2,
							@sDispatchKeyType=@sDispatchKeyType,
							@FormIDFilter=@FormIDFilter,
							@RetrievalDateToUse=@RetrievalDateToUse,
							@FromDate=@FromDate,
							@ToDate=@ToDate
			
GO
GRANT EXECUTE ON  [dbo].[tm_get_Messages_Manager_help] TO [public]
GO
