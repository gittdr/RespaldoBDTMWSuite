SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[fn_GetAFP] (@afp_tableid VARCHAR (8), @dateofservice DATETIME) 
RETURNS MONEY
AS
BEGIN
        DECLARE @Return 	MONEY
        DECLARE	@afp_date	DATETIME
        
        SELECT @afp_date = MAX (afp_date) 
			FROM averagefuelprice
			WHERE @dateofservice >= afp_date 
			  AND afp_tableid = @afp_tableid
		IF @afp_date IS NULL
		BEGIN
			SELECT @afp_date = MIN (afp_date)
				FROM averagefuelprice
				WHERE afp_default = 'Y'
				  AND afp_tableid = @afp_tableid
		END

		SELECT @Return = afp_price
			FROM averageFuelPrice
			WHERE afp_tableid = @afp_tableid
			  AND afp_date = @afp_date

        RETURN @Return
END
GO
GRANT EXECUTE ON  [dbo].[fn_GetAFP] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fn_GetAFP] TO [public]
GO
