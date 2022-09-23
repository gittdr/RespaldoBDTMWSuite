SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TMWRN_Determinant] (
	@P0_X float = 0, 
	@P0_Y float = 0, 
	@P1_X float = 0, 
	@P1_Y float = 0
)
RETURNS float
AS
BEGIN
	DECLARE @DetValue float

	SET @DetValue = (@P0_X * @P1_Y) - (@P0_Y * @P1_X)

	RETURN(@DetValue)

END


GO
