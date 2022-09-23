SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[TMWMRStateMileage_AddInvalidCity](@CityCode int)

As

if not exists (select * from MR_StateMileageInvalidCityCodes where CityCode = @CityCode)
Begin
	Insert into MR_StateMileageInvalidCityCodes Values (@CityCode)

End




GO
GRANT EXECUTE ON  [dbo].[TMWMRStateMileage_AddInvalidCity] TO [public]
GO
