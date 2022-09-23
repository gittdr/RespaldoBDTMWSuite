SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO





CREATE  Procedure [dbo].[DriverAwareSuite_GetDriverToolTipConfiguration] 
As

Select   *
From     DriverAwareSuite_DriverToolTipConfiguration
Where    UserID = system_user
Order By ToolTipRowPosition









GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetDriverToolTipConfiguration] TO [public]
GO
