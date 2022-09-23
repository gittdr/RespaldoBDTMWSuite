SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.get_statecode_from_citycode_sp    Script Date: 6/1/99 11:54:33 AM ******/
CREATE PROC [dbo].[get_statecode_from_citycode_sp] (@CityCode	integer)
As
	select cty_state from city where cty_code = @CityCode


GO
GRANT EXECUTE ON  [dbo].[get_statecode_from_citycode_sp] TO [public]
GO
