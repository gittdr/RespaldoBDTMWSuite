SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create Procedure [dbo].[TMWMRStateMileage_DeleteInvalidCity](@CityCode int)

As

if exists (select * from MR_StateMileageInvalidCityCodes where CityCode = @CityCode)
Begin
	Delete From MR_StateMileageInvalidCityCodes Where CityCode = @CityCode

End




GO
GRANT EXECUTE ON  [dbo].[TMWMRStateMileage_DeleteInvalidCity] TO [public]
GO
