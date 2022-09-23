SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Perf_PostEvent] @EventSN INT, 
                                           @MsgSN INT, 
                                           @Time DATETIME2

/*******************************************************************************************************************  
  Object Description:
    Records an occurrence in TotalMail Message flow
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/05/27   W. Riley Wolfe    PTS101024    Init
  2016/09/26   W. Riley Wolfe    PTS101024    DBA recommended changes, fix naming convention
********************************************************************************************************************/
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @OrgMsgSN INT,
	@BaseMsgSN INT;

IF COALESCE(@MsgSN, 0 ) > 0
BEGIN
  SELECT TOP 1 @OrgMsgSN = OrigMsgSN,
	  @BaseMsgSN = BaseSN
  FROM tblMessages(NOLOCK)
  WHERE SN = @MsgSN;

  IF COALESCE(@OrgMsgSN, 0) <= 0
	  SET @OrgMsgSN = @MsgSN;

  IF COALESCE(@BaseMsgSN, 0) <= 0
	  SET @BaseMsgSN = @MsgSN;

  INSERT INTO tblRawMsgPerformance (
	  BaseMsgSN,
	  OrgMsgSN,
	  TrueMsgSN,
	  PerfEventNum,
	  EventTime,
	  Processed
	  )
  VALUES (
	  @BaseMsgSN,
	  @OrgMsgSN,
	  @MsgSN,
	  @EventSN,
	  @Time,
	  0
	  );
END

GO
GRANT EXECUTE ON  [dbo].[tm_Perf_PostEvent] TO [public]
GO
