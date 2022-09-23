SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[delete_allocated_invoice_detail]	@ivd_number	INT
AS
DECLARE @min_ivh_hdrnumber	INT,
	@invoice_charge		MONEY

CREATE TABLE #invoices (
	ivh_hdrnumber	INT	NULL
)

INSERT INTO #invoices
   SELECT ivh_hdrnumber
     FROM invoicedetail
    WHERE ivd_allocated_ivd_number = @ivd_number AND
	  ivd_number <> ivd_allocated_ivd_number

SET @min_ivh_hdrnumber = 0
WHILE 1 = 1
BEGIN
   
   SELECT @min_ivh_hdrnumber = MIN(ivh_hdrnumber) 
     FROM #invoices
    WHERE ivh_hdrnumber > @min_ivh_hdrnumber
            
   IF @min_ivh_hdrnumber IS NULL
      BREAK

   DELETE FROM invoicedetail
      WHERE ivh_hdrnumber = @min_ivh_hdrnumber AND
	    ivd_allocated_ivd_number = @ivd_number

   SELECT @invoice_charge = SUM(ivd_charge)
     FROM invoicedetail
    WHERE invoicedetail.ivh_hdrnumber = @min_ivh_hdrnumber

   UPDATE invoiceheader
      SET ivh_totalcharge = @invoice_charge
    WHERE ivh_hdrnumber = @min_ivh_hdrnumber

END

GO
GRANT EXECUTE ON  [dbo].[delete_allocated_invoice_detail] TO [public]
GO
