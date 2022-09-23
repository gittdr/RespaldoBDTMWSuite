SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[billing_validation_rtl_sp] @ivh_invoicenumber   VARCHAR(12),
                                           @ErrorMessage        VARCHAR(255) OUTPUT
AS
DECLARE @billto                VARCHAR(8),
        @carkey                INTEGER,
        @ivh_revtype2          VARCHAR(6),
        @ivh_revtype4          VARCHAR(6),
        @ivh_order_by          VARCHAR(8),
        @ref_number            VARCHAR(30),
        @ivh_mbstatus          VARCHAR(6),
        @ivh_mb_customgroupby  VARCHAR(100),
        @ord_hdrnumber         INTEGER

SELECT @ivh_mbstatus = ivh_mbstatus,
       @billto = ivh_billto,
       @carkey = ISNULL(car_key, 0),
       @ivh_revtype2 = ivh_revtype2,
       @ivh_revtype4 = ivh_revtype4,
       @ivh_order_by = ivh_order_by,
       @ord_hdrnumber = ord_hdrnumber
  FROM invoiceheader 
 WHERE ivh_invoicenumber = @ivh_invoicenumber

IF (@billto = 'BAYCAL01' OR @billto = 'PENCOL') AND @ivh_mbstatus = 'RTP'
BEGIN
   SET @ivh_mb_customgroupby = @billto + '^' + CAST(@carkey AS VARCHAR(10)) + '^' + @ivh_revtype2 + '^' + @ivh_revtype4 + '^' + 
                               @ivh_order_by + '^'

   SET @ref_number = ' '
   SELECT @ref_number = ref_number
     FROM referencenumber 
    WHERE ref_type = 'AFE' and
          ref_table = 'orderheader' AND
          ref_tablekey = @ord_hdrnumber

   SET @ivh_mb_customgroupby = @ivh_mb_customgroupby + @ref_number

   UPDATE invoiceheader 
      SET ivh_mb_customgroupby = @ivh_mb_customgroupby
    WHERE ivh_invoicenumber = @ivh_invoicenumber

END

SET @ErrorMessage = ''

GO
GRANT EXECUTE ON  [dbo].[billing_validation_rtl_sp] TO [public]
GO
