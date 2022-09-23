SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE   Proc [dbo].[DriverAwareSuite_GetProperties]

As

Select dsat_key,dsat_value
From   DriverAwareSuite_GeneralInfo (NOLOCK) 






GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetProperties] TO [public]
GO
