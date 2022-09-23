SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TMWRN_IsPointInTriangle] (
	@P_X float = 0, -- X-coordinate or latitude of points to determine existance within a triangle defined by 3 points.
	@P_Y float = 0, -- Y-coordinate or longitude of points to determine existance within a triangle defined by 3 points.
	@P0_X float = 0, -- X/Latitude for point 1 of triangle.
	@P0_Y float = 0, 
	@P1_X float = 0, -- X/Latitude for point 1 of triangle.
	@P1_Y float = 0,
	@P2_X float = 0, -- X/Latitude for point 1 of triangle.
	@P2_Y float = 0
)
RETURNS float
AS
BEGIN
	DECLARE @InTriangle float
	DECLARE @a float, @b float
	DECLARE @XDiff float, @YDiff float

	SET @XDiff = @P0_X
	SET @YDiff = @P0_Y
	SET @P0_X = 0
	SET @P0_Y = 0

	SET @P_X = @P_X - @XDiff
	SET @P_Y = @P_Y - @YDiff
	SET @P1_X = @P1_X - @XDiff
	SET @P1_Y = @P1_Y - @YDiff
	SET @P2_X = @P2_X - @XDiff
	SET @P2_Y = @P2_Y - @YDiff

	SET @InTriangle = 0

	-- a = ( det(V, V2) - det(V0, V2) ) / det(V1 * V2)
	IF dbo.fnc_TMWRN_Determinant(@P1_X, @P1_Y, @P2_X, @P2_Y) <> 0
		SET @a = ( dbo.fnc_TMWRN_Determinant(@P_X, @P_Y, @P2_X, @P2_Y) - dbo.fnc_TMWRN_Determinant(@P0_X, @P0_Y, @P2_X, @P2_Y) ) 
				/ dbo.fnc_TMWRN_Determinant(@P1_X, @P1_Y, @P2_X, @P2_Y)
	ELSE
		SET @a = -1

	-- b = ( det(V, V1) - det(V0, V1) ) / det(V1 * V2)
	IF dbo.fnc_TMWRN_Determinant(@P1_X, @P1_Y, @P2_X, @P2_Y) <> 0
		SET @b = - ( dbo.fnc_TMWRN_Determinant(@P_X, @P_Y, @P1_X, @P1_Y) - dbo.fnc_TMWRN_Determinant(@P0_X, @P0_Y, @P1_X, @P1_Y) ) 
				/ dbo.fnc_TMWRN_Determinant(@P1_X, @P1_Y, @P2_X, @P2_Y)
	ELSE
		SET @b = -1
  
	-- Point is is triangle if 
	IF (@a >= 0 AND @a <= 1)
		AND (@b >= 0 AND @b <= 1)
		AND (@a + @b >= 0 AND @a + @b <= 1)
	BEGIN
		SET @InTriangle = 1
	END

	RETURN(@InTriangle)

END

GO
