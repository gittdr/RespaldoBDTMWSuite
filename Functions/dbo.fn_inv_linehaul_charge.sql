SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_inv_linehaul_charge] (@ivh_hdrnumber INTEGER)
RETURNS MONEY
BEGIN
	DECLARE @result AS MONEY
	
	SELECT @result = sum (i.ivd_charge)
		FROM invoicedetail i JOIN chargetype c ON i.cht_itemcode = c.cht_itemcode
		WHERE i.ivh_hdrnumber = @ivh_hdrnumber
		AND c.cht_primary = 'Y'
		
	RETURN COALESCE (@result, 0)
END
GO
GRANT EXECUTE ON  [dbo].[fn_inv_linehaul_charge] TO [public]
GO
