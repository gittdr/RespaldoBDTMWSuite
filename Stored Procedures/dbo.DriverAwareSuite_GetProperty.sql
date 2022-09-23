SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE    Procedure [dbo].[DriverAwareSuite_GetProperty] (@Key varchar(255),@Type varchar(255))

As

Set NOCount On

Select dsat_value
From   DriverAwareSuite_GeneralInfo (NOLOCK)
Where  dsat_key = @Key 
       and 
       dsat_type = @Type
	




GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetProperty] TO [public]
GO
