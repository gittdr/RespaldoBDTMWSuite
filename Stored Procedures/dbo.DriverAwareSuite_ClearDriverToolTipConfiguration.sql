SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO








CREATE   Procedure [dbo].[DriverAwareSuite_ClearDriverToolTipConfiguration] 

As

	Delete From DriverAwareSuite_DriverToolTipConfiguration
	Where UserID = system_user






GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_ClearDriverToolTipConfiguration] TO [public]
GO
