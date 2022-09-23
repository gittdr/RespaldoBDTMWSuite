SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec dbo.tm_Perf_PurgeData 15, 15
CREATE PROCEDURE [dbo].[tm_Perf_PurgeData] @RawDaysToSave INT = 120, 
                                           @AggregatedDaysToSave INT = 120

/*******************************************************************************************************************  
  Object Description:
    Clears up all older performance data to keep the DB from filling up.  
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/10/17   W. Riley Wolfe    PTS101024    Init
********************************************************************************************************************/
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @RAWtime DATETIME2 = DateADD(d, (-1 * @RawDaysToSave), GETDATE()),
        @AGGtime DATETIME2 = DateADD(d, (-1 * @AggregatedDaysToSave), GETDATE());

IF COALESCE(@RawDaysToSave, 0) > 0
  DELETE tblRawMsgPerformance
  WHERE EventTime < @RAWtime;

IF COALESCE(@AggregatedDaysToSave, 0) > 0
  DELETE tblAggMsgGrpPerformance
  WHERE Start < @AGGtime;

GO
GRANT EXECUTE ON  [dbo].[tm_Perf_PurgeData] TO [public]
GO
