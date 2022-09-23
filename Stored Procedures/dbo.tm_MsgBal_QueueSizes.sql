SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec [dbo].[tm_MsgBal_QueueSizes]
CREATE PROCEDURE [dbo].[tm_MsgBal_QueueSizes]
/*******************************************************************************************************************  
  Object Description:
    Provides Queue Items for the Viewer, moved out of existing inline SQL
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/09/07   W. Riley Wolfe    PTS101538    Init
  2016/10/14   W. Riley Wolfe    PTS101024    Add Dynamic Queue Querys
********************************************************************************************************************/
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @Results AS TABLE(KeyCode VARCHAR(12), Name VARCHAR(50), Value VARCHAR(20));
DECLARE @PerfInfo NVARCHAR(50),
        @CusInfo NVARCHAR(50)


INSERT INTO @Results
VALUES (
	'CIn',
	'Outbound Message Queue',
	(
		SELECT count(1)
		FROM tblmessages
		INNER JOIN tblserver ON tblmessages.folder = tblserver.inbox
		WHERE tblserver.Servercode = 'C'
		)
	),-----------------------------------------------------------------
	(
	'COut',
	'Inbound Message Queue',
	(
		SELECT count(1)
		FROM tblmessages
		INNER JOIN tblserver ON tblmessages.folder = tblserver.outbox
		WHERE tblserver.Servercode = 'C'
			AND tblmessages.STATUS < 2
		)
	),-----------------------------------------------------------------
	(
	'T',
	'Transaction Message Queue',
	(
		SELECT COUNT(1)
		FROM tblMessages
		WHERE Folder = (
				SELECT TOP 1 Inbox
				FROM tblServer
				WHERE ServerCode = 'T'
				)
		)
	),-----------------------------------------------------------------
	(
	'task',
	'Other Transaction Items',
	(
		SELECT count(1)
		FROM tblTranTaskList
		WHERE StartTime IS NULL
		)
	),-----------------------------------------------------------------
	(
	'TOut',
	'Transactions In Progress',
	(
		  SELECT count(1)
		  FROM tblmessages
		  WHERE Folder = (
				  SELECT TOP 1 Working
				  FROM tblServer
				  WHERE ServerCode = 'T'
				  )
		  ) + (
		  SELECT count(1)
		  FROM tblTranTaskList
		  WHERE NOT StartTime IS NULL
		  )
	),-----------------------------------------------------------------
	(
	'agent',
	'Active Transaction Agents',
	(
		SELECT count(1)
		FROM tblServer
		WHERE ServerCode = 'TMUL'
		)
	);

SELECT @PerfInfo = [Text] FROM tblRS WHERE keyCode = 'QPERFINFO';
SELECT @CusInfo = [Text] FROM tblRS WHERE keyCode = 'QCUSINFO';

IF coalesce(@CusInfo, '') <> ''
	INSERT INTO @Results
	EXEC sp_executesql @CusInfo;


IF coalesce(@PerfInfo, '') <> '' AND EXISTS(SELECT 1 FROM tblRS WHERE keyCode = 'LiveMsgPer' AND [TEXT] = 1)
	INSERT INTO @Results
	EXEC sp_executesql @PerfInfo;

SELECT KeyCode, Name, value FROM @Results

GO
GRANT EXECUTE ON  [dbo].[tm_MsgBal_QueueSizes] TO [public]
GO
