SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



Create   Proc [dbo].[DriverAwareSuite_GetColorProperties]

As

Select dsat_key,dsat_value
From   DriverAwareSuite_GeneralInfo (NOLOCK) 
Where  dsat_type = 'Color'









GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetColorProperties] TO [public]
GO
