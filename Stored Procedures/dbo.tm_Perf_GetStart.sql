SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Perf_GetStart] @MsgSN INT, @IncOutsideSystems TINYINT

/*******************************************************************************************************************  
  Object Description:
    Returns the root message sent time
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/05/27   W. Riley Wolfe    PTS101024    Init
  2016/09/26   W. Riley Wolfe    PTS101024    DBA recommended changes
********************************************************************************************************************/

AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
DECLARE @BaseMsgSN INT;

SELECT TOP 1 @BaseMsgSN = BaseSN
FROM tblMessages
WHERE SN = @MsgSN;

IF COALESCE(@BaseMsgSN, 0) <= 0
	SET @BaseMsgSN = @MsgSN;

IF @IncOutsideSystems > 0
  SELECT TOP 1 Convert(DATETIME, raww.EventTime)
  FROM tblRawMsgPerformance raww
  JOIN tblEventsMsgPerformance eventt ON raww.PerfEventNum = eventt.PerfEventNum
  WHERE BaseMsgSN = @BaseMsgSN AND eventt.IsOrgin = 1
  ORDER BY eventt.SequenceNum ASC;
Else
BEGIN
  IF EXISTS(SELECT 1 FROM tblRawMsgPerformance raww
    JOIN tblEventsMsgPerformance eventt ON raww.PerfEventNum = eventt.PerfEventNum
    WHERE BaseMsgSN = @BaseMsgSN AND eventt.IsOrgin = 1)
  BEGIN
    SELECT TOP 1 Convert(DATETIME, EventTime)
    FROM tblRawMsgPerformance raww
    JOIN tblEventsMsgPerformance eventt ON raww.PerfEventNum = eventt.PerfEventNum
    WHERE BaseMsgSN = @BaseMsgSN
	    AND SequenceNum BETWEEN 0	AND 150
    ORDER BY SequenceNum ASC;
  END
END
GO
GRANT EXECUTE ON  [dbo].[tm_Perf_GetStart] TO [public]
GO
