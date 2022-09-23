SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/*
  PTS 18878 -- BL (9/24/2003)

  NEW PROC  (for Central Transport (CTX))

	Will update the 'ivh_paid_amount' on the InvoiceHeader table with the
		amount in the given argument
	This PROC will be called by the client's given method (which will get the 
		field's value from the client's accounting system).  The PROC takes 
		in the 'Ivh_invoicenumber' and the 'customer paid dollar amount'.
		This field will be updated with NO commit action issued.
		(the COMMIT on this transaction will be the responsibility of the client)
*/

CREATE PROC [dbo].[update_invoice_paid_amount_sp] (@ivh_invoicenumber varchar(12), @ivh_paid_amount money)
AS

DECLARE
	@record_count int, @return_code int, @ivh_invoicestatus varchar(6)

BEGIN
	-- Check to see if the Invoice exists
	SELECT @record_count = count(*)
	FROM invoiceheader
	WHERE ivh_invoicenumber = @ivh_invoicenumber

	IF @record_count = 1 
	   BEGIN
		-- Make sure the Invoice status is 'Transferred'
		SELECT @ivh_invoicestatus = ivh_invoicestatus
		FROM invoiceheader
		WHERE ivh_invoicenumber = @ivh_invoicenumber

		IF @ivh_invoicestatus = 'XFR'
		   BEGIN
			-- Update the 'ivh_paid_amount' field
			UPDATE invoiceheader
			SET ivh_paid_amount = @ivh_paid_amount
			WHERE ivh_invoicenumber = @ivh_invoicenumber

			Set @return_code = @@Error
		   END
		ELSE
			-- Invoice does NOT exist
			return -1
	   END
	ELSE
		-- Invoice does NOT exist
		return -1
END

GO
GRANT EXECUTE ON  [dbo].[update_invoice_paid_amount_sp] TO [public]
GO
