SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MsgBal_AddDispSource] @Data varchar(100)

/*
NAME:
dbo.tm_MsgBal_AddDispSource

TYPE:
Stored Procedure

DESCRIPTION:
inserts records into tblTranTaskList
Prams:
@Data: task Data, ususaly a Truck number

Change Log: 
2016/03/09 rwolfe: PTS98345	init 

*/
AS
SET NOCOUNT ON

if NOT Exists(select * from tblTranTaskList(nolock) where Task = 'DispSource' and Data = @Data) 
Insert Into tblTranTaskList(Task, Data) Values('DispSource', @Data)
GO
GRANT EXECUTE ON  [dbo].[tm_MsgBal_AddDispSource] TO [public]
GO
