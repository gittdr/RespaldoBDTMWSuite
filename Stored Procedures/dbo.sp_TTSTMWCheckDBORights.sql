SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


--sp_TTSTMWCheckDBORights 'bk'
CREATE Procedure [dbo].[sp_TTSTMWCheckDBORights] (@LoginID varchar(255))

as 

Create Table #HelpUser (UserName varchar(255),GroupName varchar(255),LoginName varchar(255),DefDBName varchar(255),UserId int,SID varchar(1000))
Declare @ReturnStatus int


If @LoginID = 'sa'
Begin
      Set @ReturnStatus = 0

End
Else
Begin
      Insert into #HelpUser
      exec sp_helpuser @LoginID

      Set @ReturnStatus = IsNull((Select 0 From #HelpUser where GroupName = 'db_owner'),-1)

End




Select @ReturnStatus as ReturnStatus







GO
