SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/*
Proc created to allow imaging system venor to delete entries in the temp table of image invoicedata
Returns the number of rows deleted.


*/
CREATE PROCEDURE [dbo].[imageinvoicelist_delete]  @controlnbr int
	
AS

Delete From pegasus_invoicelist
 Where peg_controlnumber = @controlnbr
Return @@rowcount
GO
GRANT EXECUTE ON  [dbo].[imageinvoicelist_delete] TO [public]
GO
