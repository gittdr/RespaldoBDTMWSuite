SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE   Procedure [dbo].[DriverAwareSuite_GetColumnConfiguration] (@UserID varchar(255)='',
						   @GroupID varchar(255)='ALL'
						  ) 
As

If Len(@UserID)>0 
Begin

	Select   *
	From     DriverAwareSuite_ColumnConfiguration	
	Where    UserID = @UserID  
	Order By ColumnOrder


End
Else
Begin
	Select   *
	From     DriverAwareSuite_ColumnConfiguration	
	Where    GroupID = @GroupID  
	Order By ColumnOrder

End









GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetColumnConfiguration] TO [public]
GO
