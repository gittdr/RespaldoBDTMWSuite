SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE    Procedure [dbo].[DriverAwareSuite_GetCityCodeFromCityNameState] (@CityNameState varchar(255))

As

Set NOCount On

Select cty_code
From   city (NOLOCK)
Where  city.cty_nmstct = @CityNameState
      
    
	










GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetCityCodeFromCityNameState] TO [public]
GO
