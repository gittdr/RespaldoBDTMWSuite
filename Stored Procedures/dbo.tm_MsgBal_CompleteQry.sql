SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MsgBal_CompleteQry] @AgentID UNIQUEIDENTIFIER
/*******************************************************************************************************************  
  Object Description:
    Clears a message in tblmsgcheckout or tblTranTaskList when it has finished prossessing
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/02/27   W. Riley Wolfe    PTS98345     init 
  2016/06/28   W. Riley Wolfe    PTS101538    minor cleanup of locking and format
********************************************************************************************************************/
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DELETE tblMsgCheckout
WHERE Agent = @AgentID;

DELETE tblTranTaskList
WHERE Agent = @AgentID;

GO
GRANT EXECUTE ON  [dbo].[tm_MsgBal_CompleteQry] TO [public]
GO
