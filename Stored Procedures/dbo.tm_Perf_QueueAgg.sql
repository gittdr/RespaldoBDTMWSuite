SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec dbo.tm_Perf_QueueAgg
CREATE PROCEDURE [dbo].[tm_Perf_QueueAgg] 
/*******************************************************************************************************************  
  Object Description:
    inserts different Transaction Task for Data Aggregate
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/10/18   W. Riley Wolfe    PTS101024     init 
********************************************************************************************************************/
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF NOT EXISTS (SELECT 1 FROM tblTranTaskList WHERE Task = 'PerfData')
   INSERT INTO tblTranTaskList (Task,Data) 
   VALUES ('PerfData', 1000)

GO
GRANT EXECUTE ON  [dbo].[tm_Perf_QueueAgg] TO [public]
GO
