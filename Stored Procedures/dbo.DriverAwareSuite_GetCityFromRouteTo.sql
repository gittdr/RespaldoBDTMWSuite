SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE    Procedure [dbo].[DriverAwareSuite_GetCityFromRouteTo] (@CompanyID varchar(255))

As

Set NOCount On

Select cty_code,city.cty_nmstct
From   company (NOLOCK), city (NOLOCK)
Where  cmp_id = @CompanyID
       And
       cmp_city = cty_code
    
	

















GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetCityFromRouteTo] TO [public]
GO
