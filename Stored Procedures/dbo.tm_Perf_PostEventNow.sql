SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Perf_PostEventNow] @EventSN INT,
                                              @MsgSN INT

/*******************************************************************************************************************  
  Object Description:
    Returns the root message sent time
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/05/27   W. Riley Wolfe    PTS101024    Init
  2016/09/26   W. Riley Wolfe    PTS101024    DBA recommended changes, fix naming convention
********************************************************************************************************************/
AS
Declare @temp DateTime2 = SYSDATETIME();
EXEC tm_Perf_PostEvent @EventSN, @MsgSN, @temp;

GO
GRANT EXECUTE ON  [dbo].[tm_Perf_PostEventNow] TO [public]
GO
