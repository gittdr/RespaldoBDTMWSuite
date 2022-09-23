SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO




CREATE   Procedure [dbo].[DriverAwareSuite_ClearColumnConfiguration] (@UserID varchar(255)=Null,@GroupID varchar(255)=Null)

As

If Len(@UserID)>0
Begin
	Delete From DriverAwareSuite_ColumnConfiguration
	Where UserID = @UserID
	   
End
Else
Begin
	Delete From DriverAwareSuite_ColumnConfiguration
	Where GroupID = @GroupID
	      
End








GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_ClearColumnConfiguration] TO [public]
GO
