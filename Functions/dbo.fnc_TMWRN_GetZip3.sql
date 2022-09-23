SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create FUNCTION [dbo].[fnc_TMWRN_GetZip3] 
	(@citycode int)
RETURNS VARCHAR(3)
AS

/*
This function returns the 3-digit zipcode value
from the city table for the cty_code value supplied.
*/

	BEGIN
	declare @zip3 varchar(3)
	select 	@zip3 = left(cty_zip,3)
	  from	city
 	 where	cty_code = @citycode
	
	return @Zip3 
	
END

GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_GetZip3] TO [public]
GO
