SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Perf_Time] 
/*******************************************************************************************************************  
  Object Description:
    get basic data for Queue sizes with performance monitoring on
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/10/17   W. Riley Wolfe    PTS101024     init 
********************************************************************************************************************/
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 'perfStuff' code,
	'Current Latency (Sec)' NAME,
	COalesce(Cast(DateDiff(second, '19000101', a.TotalRAW) AS VARCHAR(100)), 'Unknown') value
FROM (
	SELECT Sum(msgcount) tot,
		Cast(Avg(TotalRAW) AS DATETIME) TotalRAW
	FROM tblAggMsgGrpPerformance
	WHERE Start > DateADD(mi, - 15, GETDATE())
	) a
WHERE a.tot > 15

GO
GRANT EXECUTE ON  [dbo].[tm_Perf_Time] TO [public]
GO
