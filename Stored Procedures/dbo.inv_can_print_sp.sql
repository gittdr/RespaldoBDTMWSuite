SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[inv_can_print_sp]
( @parm_type      CHAR(1)
, @parm_number    INT
, @RetVal         CHAR(1)     OUTPUT
, @Message        VARCHAR(50) OUTPUT
)
AS

/**
 *
 * NAME:
 * dbo.inv_can_print_sp
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Stored Proc to determine if Invoice can be printed
 *
 * RETURNS:
 *
 * CHAR(1)
 *
 * PARAMETERS:
 * 001 - @parm_type     CHAR(1)     (I=Invoice;O=Order)
 * 002 - @parm_number   INT         (ivh_hdrnumber/ord_hdrnumber)
 * 003 - @RetVal        CHAR(1)     OUTPUT
 * 004 - @Message       VARCHAR(50) OUTPUT
 *
 * REVISION HISTORY:
 * PTS 57336 SPN Created 06/07/11
 * PTS 58887 SPN revised 09/21/11 - It will not expect an invoice to be present.  It will work for BillTo and/or ChrageTypes on invoicedetail
 * 
 **/

SET NOCOUNT ON

BEGIN
   DECLARE @debug          CHAR(1)
   DECLARE @count          INT
   DECLARE @ivh_hdrnumber  INT
   DECLARE @ord_hdrnumber  INT
   DECLARE @ivh_billto     VARCHAR(8)
   DECLARE @cht_itemcode   VARCHAR(6)
   DECLARE @chargetypes    VARCHAR(1000)
   DECLARE @docsrequired   INT
   DECLARE @docsreceived   INT

   SELECT @debug  = 'N'
   SELECT @RetVal = 'N'

   --Verify parameters
   IF @parm_type IS NULL OR @parm_number IS NULL
   BEGIN
      SELECT @Message = 'Bad Parameter'
      SELECT @RetVal  = 'E'
      RETURN
   END
   
   IF @parm_type = 'I'
      BEGIN
         SELECT @ivh_hdrnumber = @parm_number
         SELECT @count = COUNT(1)
           FROM invoiceheader
          WHERE ivh_hdrnumber = @ivh_hdrnumber
         IF @count <= 0
         BEGIN
            SELECT @Message = 'Invoice# not found'
            SELECT @RetVal  = 'E'
            RETURN
         END
         SELECT @ord_hdrnumber = ord_hdrnumber
              , @ivh_billto = ivh_billto
           FROM invoiceheader
          WHERE ivh_hdrnumber = @ivh_hdrnumber
         IF IsNull(@ord_hdrnumber,0) <= 0
         BEGIN
            SELECT @Message = 'No Order# found for the Invoice'
            SELECT @RetVal  = 'E'
            RETURN
         END
      END
   ELSE IF @parm_type = 'O'
      BEGIN
         SELECT @ord_hdrnumber = @parm_number
         SELECT @count = COUNT(1)
           FROM orderheader
          WHERE ord_hdrnumber = @ord_hdrnumber
         IF @count <= 0
         BEGIN
            SELECT @Message = 'Order# not found'
            SELECT @RetVal  = 'E'
            RETURN
         END
         SELECT @ivh_hdrnumber = MAX(ivh_hdrnumber)
              , @ivh_billto = MAX(ivh_billto)
           FROM invoiceheader
          WHERE ord_hdrnumber = @ord_hdrnumber
         IF IsNull(@ivh_hdrnumber,0) <= 0
         BEGIN
            SELECT @ivh_billto = ord_billto
              FROM orderheader
             WHERE ord_hdrnumber = @ord_hdrnumber
         END
         
      END
   ELSE
      BEGIN
         SELECT @Message = 'Bad ParmType'
         SELECT @RetVal  = 'E'
         RETURN
      END

   --Get ChargeTypes from InvoiceDetail
   SELECT @chargetypes = ','
   IF IsNull(@ivh_hdrnumber,0) > 0
   BEGIN
      DECLARE myCUR CURSOR FOR
      SELECT LTRIM(RTRIM(cht_itemcode))
        FROM invoicedetail
       WHERE ivh_hdrnumber = IsNull(@ivh_hdrnumber,-1)
         AND cht_itemcode IS NOT NULL
      GROUP BY cht_itemcode

      OPEN myCUR
      WHILE 1 = 1
      BEGIN
         FETCH NEXT
          FROM myCUR
          INTO @cht_itemcode
         IF @@FETCH_STATUS <> 0
            BREAK

         SELECT @chargetypes = @chargetypes + @cht_itemcode + ','
      END
      CLOSE myCUR
      DEALLOCATE myCUR
   END
   IF @chargetypes = ','
      SELECT @chargetypes = ''
   ELSE
      SELECT @chargetypes = SUBSTRING(@chargetypes,2,LEN(@chargetypes) - 2)
   
   IF @debug = 'Y'
      Print 'ChargeTypes=' + @chargetypes
   
   EXEC PpwkDocsCount 
        @ord_hdrnumber
      , 'ORD'
      , @ivh_billto
      , @chargetypes
      , 'I'
      , @docsrequired OUTPUT
      , @docsreceived OUTPUT

   IF @debug = 'Y'
   BEGIN
      Print 'DocsReceived=' + CONVERT(VARCHAR,@docsreceived)
      Print 'DocsRequired=' + CONVERT(VARCHAR,@docsrequired)
   END

   SELECT @Message = 'DocsReceived=' + CONVERT(VARCHAR,@docsreceived) + ' AND ' + 'DocsRequired=' + CONVERT(VARCHAR,@docsrequired)
   IF @docsreceived >= @docsrequired
   BEGIN
      SELECT @RetVal  = 'Y'
   END

   RETURN
END
GO
GRANT EXECUTE ON  [dbo].[inv_can_print_sp] TO [public]
GO
