SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


Create Procedure [dbo].[DriverAwareSuite_GeneralInfoSettings]

as

Select *
From   DriverAwareSuite_GeneralInfo
Where  dsat_type <> 'Color'



GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GeneralInfoSettings] TO [public]
GO
