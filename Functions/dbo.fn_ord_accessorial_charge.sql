SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_ord_accessorial_charge] (@ord_hdrnumber INTEGER)
RETURNS MONEY
BEGIN
   DECLARE @result AS MONEY
   DECLARE @FSCChargeTypeList VARCHAR (60)
   
   SELECT @FSCChargeTypeList = gi_string1 FROM generalinfo WHERE gi_name = 'FSCChargeTypes'

   SELECT @result = sum (i.ivd_charge)
      FROM invoicedetail i JOIN chargetype c ON i.cht_itemcode = c.cht_itemcode
      WHERE i.ord_hdrnumber = @ord_hdrnumber
      AND c.cht_primary = 'N'
      AND i.cht_itemcode NOT IN (SELECT value FROM dbo.CSVStringsToTable_fn (@FSCChargeTypeList))

   RETURN COALESCE (@result, 0.0)   
END
GO
GRANT EXECUTE ON  [dbo].[fn_ord_accessorial_charge] TO [public]
GO
