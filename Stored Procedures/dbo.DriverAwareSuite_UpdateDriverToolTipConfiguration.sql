SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO






CREATE  Procedure [dbo].[DriverAwareSuite_UpdateDriverToolTipConfiguration] (@ColumnName varchar(255),@ToolTipRowPosition int)

As

Insert into DriverAwareSuite_DriverToolTipConfiguration
Values (@ColumnName,@ToolTipRowPosition,system_user)





GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_UpdateDriverToolTipConfiguration] TO [public]
GO
