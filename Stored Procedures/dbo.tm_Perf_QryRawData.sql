SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--exec dbo.tm_Perf_QryRawData 1000
CREATE PROCEDURE [dbo].[tm_Perf_QryRawData] @MaxRec INT

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

DECLARE @BaseSNList as Table(BaseMsgSN INT);
Declare @TopRaw BigINT, @CMPUnder BIGINT;

--We are getting data ready to aggregate, so make sure all Queries are using the 
--same window as raw data will always be coming in.  
SELECT @TopRaw = Max(rawperfnum) from tblRawMsgPerformance;

INSERT INTO @BaseSNList
SELECT TOP (@MaxRec) raww.BaseMsgSN
FROM tblRawMsgPerformance raww
JOIN tblEventsMsgPerformance evt ON raww.PerfEventNum = evt.PerfEventNum
WHERE raww.RawPerfNum <= @TopRaw
	AND BaseMsgSN IN (
		SELECT DISTINCT BaseMsgSN
		FROM tblRawMsgPerformance
		WHERE Processed = 0
			AND RawPerfNum <= @TopRaw
		)
GROUP BY BaseMsgSN
HAVING Sum(evt.IsOrgin) > 0
	AND Sum(evt.IsFinal) > 0
ORDER BY raww.BaseMsgSN;

SELECT @CMPUnder = MAX(RawPerfNum)
FROM tblRawMsgPerformance
WHERE BaseMsgSN IN (
		SELECT BaseMsgSN
		FROM @BaseSNList
		);

IF COALESCE(@CMPUnder, 0) > 0
BEGIN
  UPDATE tblRawMsgPerformance
  SET Processed = 1
  WHERE RawPerfNum <= @CMPUnder 
    AND Processed = 0;
END

SELECT BaseMsgSN
FROM @BaseSNList;
GO
GRANT EXECUTE ON  [dbo].[tm_Perf_QryRawData] TO [public]
GO
