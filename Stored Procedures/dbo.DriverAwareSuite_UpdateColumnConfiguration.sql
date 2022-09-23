SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE  Procedure [dbo].[DriverAwareSuite_UpdateColumnConfiguration] (@ColumnName varchar(255),@ColumnOrder int,@UserID varchar(255)=Null,@GroupID varchar(255)='ALL')

As

Insert into DriverAwareSuite_ColumnConfiguration
Values (@ColumnName,@ColumnOrder,@UserID,@GroupID)



GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_UpdateColumnConfiguration] TO [public]
GO
