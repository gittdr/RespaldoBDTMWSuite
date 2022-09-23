SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[sync_qty_with_units_fn]
(
	@FromUnit	VARCHAR(6),
	@ToUnit		VARCHAR(6),
	@Qty		MONEY
)
RETURNS MONEY
AS
BEGIN
	DECLARE	@Return MONEY,
			@Factor FLOAT

	SET @Return = 0.0000

	IF @FromUnit = 'UNK' or @ToUnit = 'UNK' 
		SET @Return = -1.0000

	IF (ISNULL(@FromUnit, '') = '' OR ISNULL(@ToUnit, '') = '') AND @Return = 0.0000
		SET @Return = -1.0000

	IF @FromUnit = @ToUnit AND @Return = 0.0000
		SET @Return = @Qty

	IF  @Return = 0.0000 AND @Qty <> 0.0000
	BEGIN
		SELECT	@Factor = unc_factor
		  FROM	unitconversion
		 WHERE	unc_from = @FromUnit
		   AND	unc_to = @ToUnit
		   AND	unc_convflag = 'Q'

		IF ISNULL(@Factor, -1.0000) = -1.0000
			SET @Return = -1.0000
		ELSE
			SET @Return = @Qty * @Factor
	END
	IF @Return < 0 
		SET @Return = 0
	RETURN @Return
END
GO
GRANT EXECUTE ON  [dbo].[sync_qty_with_units_fn] TO [public]
GO
GRANT REFERENCES ON  [dbo].[sync_qty_with_units_fn] TO [public]
GO
