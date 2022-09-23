SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_inv_accessorial_charge] (@ivh_hdrnumber INTEGER)
RETURNS MONEY
/*
PTS 64340 DPETE 8/13/12 performance improvment from Mindy
*/
BEGIN
	DECLARE @result AS MONEY
	DECLARE @FSCChargeTypeList VARCHAR (60)
	
	SELECT @FSCChargeTypeList = gi_string1 FROM generalinfo WHERE gi_name = 'FSCChargeTypes'

	If @FSCChargeTypeList is null or rtrim(ltrim(@FSCChargeTypeList)) = '' 
      Begin
                                SELECT @result = sum (i.ivd_charge)  
                                FROM invoicedetail i JOIN chargetype c ON i.cht_itemcode = c.cht_itemcode  
                                WHERE i.ivh_hdrnumber = @ivh_hdrnumber  
                                AND c.cht_primary = 'N' 
      End
   Else
      Begin  
                                SELECT @result = sum (i.ivd_charge)  
                                FROM invoicedetail i JOIN chargetype c ON i.cht_itemcode = c.cht_itemcode  
                                WHERE i.ivh_hdrnumber = @ivh_hdrnumber  
                                AND c.cht_primary = 'N'  
                                AND i.cht_itemcode NOT IN (SELECT value FROM dbo.CSVStringsToTable_fn (@FSCChargeTypeList))
     End  


	RETURN COALESCE (@result, 0.0)	
END
GO
GRANT EXECUTE ON  [dbo].[fn_inv_accessorial_charge] TO [public]
GO
