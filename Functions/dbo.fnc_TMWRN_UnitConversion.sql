SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create FUNCTION [dbo].[fnc_TMWRN_UnitConversion]
	(	
		@ConvertFromUnit varchar(10),
		@ConvertToUnit varchar(10),
		@ConvertAmount float
	)
RETURNS Float

AS

Begin
	declare @Result float

	If @ConvertFromUnit = @ConvertToUnit
		Begin
			Set @Result = @ConvertAmount
		End
	Else
		Begin
			Select @Result = unc_factor * @ConvertAmount
			from unitconversion
			where unc_convflag = 'Q'
				AND unc_from = @ConvertFromUnit
				AND unc_to = @ConvertToUnit
		End

	Return @Result

End

GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_UnitConversion] TO [public]
GO
