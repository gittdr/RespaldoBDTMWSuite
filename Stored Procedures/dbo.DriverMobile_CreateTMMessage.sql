SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DriverMobile_CreateTMMessage]
@DRIVER VARCHAR(100), @SUBJECT VARCHAR(254), @MESSAGE VARCHAR(500)
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides Notifications for driver.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  07/19/2017   Chip Ciminero    WE-209100    Created
*******************************************************************************************************************/
--DECLARE @DRIVER VARCHAR(100), @SUBJECT VARCHAR(254), @MESSAGE VARCHAR(500)
--SELECT @DRIVER = 'BEDV', @SUBJECT = 'Test Subject', @MESSAGE = 'Test message showing up to location but no one was there'

DECLARE @TRACTOR VARCHAR(100)
SET		@TRACTOR = (SELECT mpp_tractornumber FROM manpowerprofile where mpp_id = @DRIVER)

--TOTAL MAIL CODE
DECLARE @msg_FormID AS INT --not inmport for text messages.
DECLARE @msg_To AS VARCHAR(100) --driver or tractor to send the message to
DECLARE @msg_ToType AS INT --9 for tractor, 10 for driver
DECLARE @msg_FilterData AS VARCHAR(254) --Messages triggered this way with the same filter data will get removed. Only 1 message per unique filter data will go out for each dupe seconds interval.
DECLARE @msg_FilterDataDupSeconds AS INT --how long to queue a message, to remove dupes or delay the message
DECLARE @msg_From AS VARCHAR(100) --Admin, or the other login name from tblLogin
DECLARE @msg_FromType AS INT --1 login type
DECLARE @msg_Subject AS VARCHAR(254) --Does not go out with text messages, only shows in viewer.
DECLARE @TranInstance AS INT --deprecated feature. Always 0.
DECLARE @msg_Text AS VARCHAR(500) --Text message to send.

DECLARE @msg_ID AS INT --Key value for the message. To link the text to go along with the message
DECLARE @msd_Seq AS INT --Always 1 for text messages.
DECLARE @msg_FieldName AS VARCHAR(30) -- For a text message, it does not matter what it is set to so long as it is set to something.
DECLARE @msg_FieldValue AS VARCHAR(500) --Text message to send.


/*
To and From Address Type
1 - Login
3 - dispatch group
4 - Totalmail TRC ID (can be different from suite#)
5 - Totalmail DRV Name
9 - Suite TRC ID
10 - Suite DRV ID
SELECT * FROM dbo.tblAddressTypes
*/

--inbound text from truck
SELECT	@msg_FormID = 0
		,@msg_From = @DRIVER --trc or drv ID in Operations
		,@msg_FromType = 10 --9 for trc, 10 for drv
		,@msg_FilterData =	@DRIVER + --this needs to unique per msg .. so @msg_From + datetime stamp should work
							CAST(DATEPART(yyyy,GETDATE()) AS VARCHAR)+
							CAST(DATEPART(MM,GETDATE()) AS VARCHAR)+
							CAST(DATEPART(dd,GETDATE()) AS VARCHAR)+
							CAST(DATEPART(hh,GETDATE()) AS VARCHAR)+
							CAST(DATEPART(mi,GETDATE()) AS VARCHAR)+
							CAST(DATEPART(ss,GETDATE()) AS VARCHAR)
		,@msg_FilterDataDupSeconds = 30 --standard is 30, can shorten or lengthen if need be.
		,@msg_To = g.name --Admin or dispatcher login name
		,@msg_ToType = 3 --id 3 for dispatch group
		,@msg_Subject = @SUBJECT --message subject
		,@msg_Text = @MESSAGE --message body
FROM	dbo.tblDrivers t INNER JOIN 
		dbo.tblDispatchGroup g ON g.sn = t.CurrentDispatcher
WHERE	DispSysDriverID  = @DRIVER --truck # here

INSERT INTO dbo.TMSQLMessage
        ( msg_date
          ,msg_FormID
          ,msg_To
          ,msg_ToType
          ,msg_FilterData
          ,msg_FilterDataDupWaitSeconds
          ,msg_From
          ,msg_FromType
          ,msg_Subject
        )
VALUES  ( GETDATE()
          ,@msg_FormID
          ,@msg_To
          ,@msg_ToType
          ,@msg_FilterData
          ,@msg_FilterDataDupSeconds
          ,@msg_From
          ,@msg_FromType
          ,@msg_Subject
        )

SET @msg_ID = SCOPE_IDENTITY()
SET @msd_Seq = 1
SET @msg_FieldName = 'text'
SET @msg_FieldValue = @msg_Text

INSERT INTO dbo.TMSQLMessageData
        ( msg_ID ,
          msd_Seq ,
          msd_FieldName ,
          msd_FieldValue
        )
VALUES  ( @msg_id
          ,@msd_Seq
          ,@msg_FieldName
          ,@msg_FieldValue
        )
		
GO
GRANT EXECUTE ON  [dbo].[DriverMobile_CreateTMMessage] TO [public]
GO
