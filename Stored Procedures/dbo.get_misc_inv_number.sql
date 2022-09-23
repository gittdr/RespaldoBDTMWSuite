SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[get_misc_inv_number] 
AS
DECLARE
	@recnum Integer
	
	EXEC @recnum = getsystemnumber 'MISCINV', '' 		

	WHILE EXISTS (SELECT * FROM invoiceheader WHERE ivh_invoicenumber = 'S' + LTRIM(STR(@recnum, 9, 0)))
		EXEC @recnum = getsystemnumber 'MISCINV', ''

	RETURN @recnum
GO
GRANT EXECUTE ON  [dbo].[get_misc_inv_number] TO [public]
GO
