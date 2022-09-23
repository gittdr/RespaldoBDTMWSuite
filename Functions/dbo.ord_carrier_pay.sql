SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[ord_carrier_pay] (@ord_hdrnumber integer)
RETURNS MONEY
AS
BEGIN
	DECLARE @amount 		MONEY, 
			@lgh_miles		DECIMAL, 
			@ord_miles		DECIMAL

	IF @ord_hdrnumber > 0 
	BEGIN
		SELECT @amount = SUM(pyd_amount)
			FROM paydetail 
			WHERE lgh_number IN (SELECT lgh_number 
									FROM legheader JOIN orderheader on orderheader.mov_number = legheader.mov_number 
									WHERE orderheader.ord_hdrnumber = @ord_hdrnumber)
			AND paydetail.asgn_type = 'CAR'
		IF @amount IS NOT NULL AND @amount <> 0.0 
		BEGIN
			SELECT @lgh_miles = SUM(DISTINCT ord_totalmiles)
				FROM orderheader JOIN legheader ON orderheader.mov_number = legheader.mov_number
				WHERE orderheader.mov_number IN (SELECT legheader.mov_number 
													FROM legheader JOIN orderheader on orderheader.mov_number = legheader.mov_number 
													WHERE orderheader.ord_hdrnumber = @ord_hdrnumber)
			
			SELECT @ord_miles = ord_totalmiles
				FROM orderheader
				WHERE orderheader.ord_hdrnumber = @ord_hdrnumber
		
			IF @lgh_miles IS NOT NULL AND @lgh_miles > 0
				SET @amount = (@amount) * (@ord_miles / @lgh_miles)
		END
	END
	RETURN @amount
END

GO
GRANT EXECUTE ON  [dbo].[ord_carrier_pay] TO [public]
GO
