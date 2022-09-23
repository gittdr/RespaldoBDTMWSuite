SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_currency_conversion] (@pmny_amount money, @pdtm_conv_date datetime, @ps_fromcurr varchar(12), @ps_tocurr varchar(12)) 
RETURNS MONEY
AS
BEGIN
    DECLARE @return		MONEY
	DECLARE @max_date	datetime

	SELECT @max_date = (SELECT MAX(cex_date) 
                          FROM currency_exchange
	                     WHERE (cex_date <= @pdtm_conv_date)
	                       AND (cex_from_curr = @ps_fromcurr)
	                       AND (cex_to_curr = @ps_tocurr))

	SELECT @return = cex_rate 
	  FROM currency_exchange
	 WHERE (cex_date = @max_date)
       AND (cex_from_curr = @ps_fromcurr)
       AND (cex_to_curr = @ps_tocurr)

	RETURN isnull(@return,1) * @pmny_amount
END
GO
GRANT EXECUTE ON  [dbo].[fn_currency_conversion] TO [public]
GO
