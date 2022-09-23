SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_inv_fuel_charge] (@ivh_hdrnumber INTEGER)
RETURNS MONEY
BEGIN
	DECLARE @result AS MONEY
	DECLARE @FSCChargeTypeList VARCHAR (60)
	
	SELECT @FSCChargeTypeList = gi_string1 FROM generalinfo WHERE gi_name = 'FSCChargeTypes'

	SELECT @result = SUM (ivd_charge)
		FROM dbo.CSVStringsToTable_fn (@FSCChargeTypeList) JOIN invoicedetail ON value = cht_itemcode
		WHERE invoicedetail.ivh_hdrnumber = @ivh_hdrnumber 
		
	RETURN COALESCE (@result, 0.0)
END
GO
GRANT EXECUTE ON  [dbo].[fn_inv_fuel_charge] TO [public]
GO
