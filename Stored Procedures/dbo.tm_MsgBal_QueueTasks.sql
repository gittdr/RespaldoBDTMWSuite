SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MsgBal_QueueTasks] 
/*******************************************************************************************************************  
  Object Description:
    inserts different Transaction Tasks: TMSource, AUXSource, PosTran, DispSource, SendUnread
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/03/03   W. Riley Wolfe    PTS98345     init 
  2016/06/28   W. Riley Wolfe    PTS101538    minor cleanup of locking and format
********************************************************************************************************************/
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

if NOT Exists(select 1 from tblTranTaskList where Task = 'DispSource' AND Data = '#FULL#')
Begin
  Insert Into tblTranTaskList(Task, Data)
  Values('DispSource', '#FULL#');
END

if NOT Exists(select 1 from tblTranTaskList where Task = 'TMSource')
Begin
  Insert Into tblTranTaskList(Task, Data)
  Values('TMSource', '#FULL#');
END

if NOT Exists(select 1 from tblTranTaskList where Task = 'AUXSource')
Begin
  Insert Into tblTranTaskList(Task, Data)
  Values('AUXSource', '#FULL#');
END

if NOT Exists(select 1 from tblTranTaskList where Task = 'PosTran')
Begin
  Insert Into tblTranTaskList(Task)
  Values('PosTran');
END

if NOT Exists(select 1 from tblTranTaskList where Task = 'SendUnread')
Begin
  Insert Into tblTranTaskList(Task)
  Values('SendUnread');
END

GO
GRANT EXECUTE ON  [dbo].[tm_MsgBal_QueueTasks] TO [public]
GO
