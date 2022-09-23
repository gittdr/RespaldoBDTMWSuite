SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


Create Procedure [dbo].[DriverAwareSuite_GetCityNameStateFromCompanyID](@CompanyID as varchar(255))

As

Select cty_nmstct as CityNameState

From company (NOLOCK)
Where cmp_id = @CompanyID




GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetCityNameStateFromCompanyID] TO [public]
GO
