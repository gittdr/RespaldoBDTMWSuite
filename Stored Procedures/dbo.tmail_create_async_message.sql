SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_create_async_message] @MessageID varchar(12),
											@MessageDate varchar(30),
											@FormID varchar(12),
											@MessageTo varchar(50),
											@MessageToType varchar(4),					--5
											@MessageFilterData varchar(254),
											@MessageFilterDataDupWaitSec varchar(12),
											@MessageFrom varchar(100),
											@MessageFromType varchar(4),
											@MessageSubject varchar(254),				--10
											@Flags varchar(12) = NULL,
											@MessageField01Name varchar(30) = NULL,
											@MessageField01Value varchar(500) = NULL,
											@MessageField02Name varchar(30) = NULL,
											@MessageField02Value varchar(500) = NULL,			--15
											@MessageField03Name varchar(30) = NULL,				
											@MessageField03Value varchar(500) = NULL,
											@MessageField04Name varchar(30) = NULL,				
											@MessageField04Value varchar(500) = NULL,
											@MessageField05Name varchar(30) = NULL,				--20
											@MessageField05Value varchar(500) = NULL,			
											@MessageField06Name varchar(30) = NULL,
											@MessageField06Value varchar(500) = NULL,			
											@MessageField07Name varchar(30) = NULL,				
											@MessageField07Value varchar(500) = NULL,			--25
											@MessageField08Name varchar(30) = NULL,				
											@MessageField08Value varchar(500) = NULL,
											@MessageField09Name varchar(30) = NULL,				
											@MessageField09Value varchar(500) = NULL,
											@MessageField10Name varchar(30) = NULL,				--30
											@MessageField10Value varchar(500) = NULL,			
											@MessageField11Name varchar(30) = NULL,
											@MessageField11Value varchar(500) = NULL,			
											@MessageField12Name varchar(30) = NULL,
											@MessageField12Value varchar(500) = NULL,			--35
											@MessageField13Name varchar(30) = NULL,				
											@MessageField13Value varchar(500) = NULL,
											@MessageField14Name varchar(30) = NULL,				
											@MessageField14Value varchar(500) = NULL,
											@MessageField15Name varchar(30) = NULL,				--40
											@MessageField15Value varchar(500) = NULL,			
											@MessageField16Name varchar(30) = NULL,
											@MessageField16Value varchar(500) = NULL,			
											@MessageField17Name varchar(30) = NULL,				
											@MessageField17Value varchar(500) = NULL,			--45
											@MessageField18Name varchar(30) = NULL,				
											@MessageField18Value varchar(500) = NULL,
											@MessageField19Name varchar(30) = NULL,				
											@MessageField19Value varchar(500) = NULL,
											@MessageField20Name varchar(30) = NULL,				--50
											@MessageField20Value varchar(500) = NULL
											--with the currrent @SQLPara string length of 4000 you can go up to 52 fields
as

/**
 * 
 * NAME:
 * dbo.[tmail_create_async_message]
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 *  populate TMSQLMessage and TMSQLMessageData
 *
 * RETURNS:
 *  MessageID Int
 * 
 * PARAMETERS:
 * 
 * Change Log: 
 * 2013-07-28 - APC - increase size of TMSQLMessageData.msd_fieldvalue to varchar(500)
 * 2014-01-20 - JC	- add flag to not return insert message id
 **/
 
--Flags
-- 1 = Use 1 for all sequences (Text Message)
-- 2 = Do not update base message information
-- 4 = Do not return message id

DECLARE @lMessageID int, 
		@lFormID int, 
		@dteMessageDate datetime, 
		@lMessageFilterDataDupWaitSec int, 
		@lFlags int, 
		@sFieldName varchar(30), 
		@sFieldValue varchar(500), 
		@lFieldCount int,
		@lFieldMaxCount int,
		@SQLString nvarchar(500),
		@SQLPara nvarchar(4000)		

SET @lFieldMaxCount = 20

SET @lMessageID = CONVERT(int, ISNULL(@MessageID, 0))
SET @lFormID = CONVERT(int, ISNULL(@FormID, 0))
SET @lFlags = CONVERT(int, ISNULL(@Flags, 0))
SET @lMessageFilterDataDupWaitSec = CONVERT(int, ISNULL(@MessageFilterDataDupWaitSec, 0))

IF @lMessageFilterDataDupWaitSec = 0 SET @lMessageFilterDataDupWaitSec = 5  --give me at least 5 seconds to add the data records

IF @lMessageID > 0 
	BEGIN
		IF NOT EXISTS(SELECT NULL FROM TMSqlMessage WHERE msg_id = @lMessageID)
		BEGIN
			RAISERROR('tmail_create_async_message: Message ID %d not found in Asynchronous table', 16, 1, @lMessageID)
			RETURN
		END

		if isdate(@MessageDate) <> 0
			SET @dteMessageDate = CONVERT(datetime, @MessageDate)

	END
else
	BEGIN

		if isdate(@MessageDate) = 0
			BEGIN
				if ISNULL(@MessageDate, '') = '' AND @lMessageID = 0
					SET @dteMessageDate = GETDATE()
				ELSE
					BEGIN
						RAISERROR('tmail_create_async_message: Invalid message date: %s', 16, 1, @MessageDate)
						RETURN
					END
			END
		else
			SET @dteMessageDate = CONVERT(datetime, @MessageDate)

		if isnumeric(@FormID) = 0 
			BEGIN
				RAISERROR('tmail_create_async_message: Form ID must be numeric: %s', 16, 1, @FormID)
				RETURN
			END

		if ISNULL(@MessageTo, '') = ''
			BEGIN
				RAISERROR('tmail_create_async_message: Message To not set', 16, 1)
				RETURN
			END
	END

IF @lMessageID = 0
	BEGIN
		INSERT INTO TMSQLMessage (msg_date, 
								  msg_FormID, 
								  msg_To, 
								  msg_ToType, 
								  msg_FilterData, 
								  msg_FilterDataDupWaitSeconds, 
								  msg_From, 
								  msg_FromType, 
								  msg_Subject) VALUES
								 (@dteMessageDate,
								  @lFormID,
								  @MessageTo, 
								  @MessageToType,
								  @MessageFilterData,
								  @lMessageFilterDataDupWaitSec,
								  @MessageFrom,
								  @MessageFromType,
								  @MessageSubject)

		SET @lMessageID = @@Identity
	END
else if (@lFlags & 2) = 0
	BEGIN

		UPDATE TMSQLMessage SET msg_date = ISNULL(@dteMessageDate, msg_date), 
							    msg_FormID = ISNULL(CASE WHEN ISNULL(@lFormID, 0) = 0 THEN NULL ELSE @lFormID END, msg_FormID), 
								msg_To = ISNULL(CASE WHEN ISNULL(@MessageTo, '') = '' THEN NULL ELSE @MessageTo END, msg_To), 
								msg_ToType = ISNULL(CASE WHEN ISNULL(@MessageToType, '') = '' THEN NULL ELSE @MessageToType END, msg_ToType),  
								msg_FilterData = ISNULL(CASE WHEN ISNULL(@MessageFilterData, '') = '' THEN NULL ELSE @MessageFilterData END, msg_FilterData),  
								msg_FilterDataDupWaitSeconds = ISNULL(CASE WHEN ISNULL(@lMessageFilterDataDupWaitSec, 0) = 0 THEN NULL ELSE @lMessageFilterDataDupWaitSec END, msg_FilterDataDupWaitSeconds), 
								msg_From = ISNULL(CASE WHEN ISNULL(@MessageFrom, '') = '' THEN NULL ELSE @MessageFrom END, msg_From), 
								msg_FromType = ISNULL(CASE WHEN ISNULL(@MessageFromType, '') = '' THEN NULL ELSE @MessageFromType END, msg_FromType) , 
								msg_Subject = ISNULL(CASE WHEN ISNULL(@MessageSubject, '') = '' THEN NULL ELSE @MessageSubject END, msg_Subject)
			WHERE msg_id = @lMessageID
	END

--Create string for parameters
SET @lFieldCount = 1
SET @SQLPara = N'@sFieldName varchar(30) OutPut, @sFieldValue varchar(500) OutPut'
WHILE 1=1
BEGIN

	SET @SQLPara = @SQLPara + ', @MessageField' + RIGHT('0' + CONVERT(varchar(2), @lFieldCount), 2) + 'NameOut Varchar(30), @MessageField' + RIGHT('0' + CONVERT(varchar(2), @lFieldCount), 2) + 'ValueOut Varchar(500) '   

	SET @lFieldCount = @lFieldCount + 1
	IF @lFieldCount = (@lFieldMaxCount + 1) break
 
END

--Walk through each field and add it
SET @lFieldCount = 1
WHILE 1=1
BEGIN

	SET @SQLString = N'SELECT @sFieldName = @MessageField' + RIGHT('0' + CONVERT(varchar(2), @lFieldCount), 2) + 'NameOut, @sFieldValue = @MessageField' + RIGHT('0' + CONVERT(varchar(2), @lFieldCount), 2) + 'ValueOut'   

	EXECUTE sp_executesql  @SQLString, @SQLPara, 
						@sFieldName = @sFieldName output, 
						@sFieldValue = @sFieldValue output,
						@MessageField01NameOut = @MessageField01Name,
						@MessageField01ValueOut = @MessageField01Value,
						@MessageField02NameOut = @MessageField02Name,
						@MessageField02ValueOut = @MessageField02Value,
						@MessageField03NameOut = @MessageField03Name,
						@MessageField03ValueOut = @MessageField03Value,
						@MessageField04NameOut = @MessageField04Name,
						@MessageField04ValueOut = @MessageField04Value,
						@MessageField05NameOut = @MessageField05Name,
						@MessageField05ValueOut = @MessageField05Value,
						@MessageField06NameOut = @MessageField06Name,
						@MessageField06ValueOut = @MessageField06Value,
						@MessageField07NameOut = @MessageField07Name,
						@MessageField07ValueOut = @MessageField07Value,
						@MessageField08NameOut = @MessageField08Name,
						@MessageField08ValueOut = @MessageField08Value,
						@MessageField09NameOut = @MessageField09Name,
						@MessageField09ValueOut = @MessageField09Value,
						@MessageField10NameOut = @MessageField10Name,
						@MessageField10ValueOut = @MessageField10Value,
						@MessageField11NameOut = @MessageField11Name,
						@MessageField11ValueOut = @MessageField11Value,
						@MessageField12NameOut = @MessageField12Name,
						@MessageField12ValueOut = @MessageField12Value,
						@MessageField13NameOut = @MessageField13Name,
						@MessageField13ValueOut = @MessageField13Value,
						@MessageField14NameOut = @MessageField14Name,
						@MessageField14ValueOut = @MessageField14Value,
						@MessageField15NameOut = @MessageField15Name,
						@MessageField15ValueOut = @MessageField15Value,
						@MessageField16NameOut = @MessageField16Name,
						@MessageField16ValueOut = @MessageField16Value,
						@MessageField17NameOut = @MessageField17Name,
						@MessageField17ValueOut = @MessageField17Value,
						@MessageField18NameOut = @MessageField18Name,
						@MessageField18ValueOut = @MessageField18Value,
						@MessageField19NameOut = @MessageField19Name,
						@MessageField19ValueOut = @MessageField19Value,
						@MessageField20NameOut = @MessageField20Name,
						@MessageField20ValueOut = @MessageField20Value

	IF ISNULL(@sFieldName, '') = '' break  --if we have a blank field then stop inserting

	INSERT INTO TMSqlMessageData (msg_ID, 
								  msd_Seq, 
								  msd_FieldName, 
								  msd_FieldValue) VALUES
								 (@lMessageID, 
								  CASE WHEN (@lFlags & 1) = 0 THEN @lFieldCount ELSE 1 END,
								  @sFieldName,
								  @sFieldValue)

	SET @lFieldCount = @lFieldCount + 1
	IF @lFieldCount = (@lFieldMaxCount + 1) break

END

IF (@lflags & 4) = 0
	SELECT @lMessageID MessageID

GO
GRANT EXECUTE ON  [dbo].[tmail_create_async_message] TO [public]
GO
