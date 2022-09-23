SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[getassetsforinvoicebackoffice]
   @p_ordhdrnumber        INTEGER,
   @p_driver1             VARCHAR(8) OUTPUT,
   @p_driver2             VARCHAR(8) OUTPUT,
   @p_tractor             VARCHAR(8) OUTPUT,
   @p_trailer1            VARCHAR(8) OUTPUT,
   @p_trailer2            VARCHAR(8) OUTPUT,
   @p_carrier             VARCHAR(8) OUTPUT
AS
DECLARE @v_billto             VARCHAR(8),
        @v_GI_InvoiceAssets   VARCHAR(30),
        @v_invoiceby          VARCHAR(6),
        @v_mov                INTEGER,
        @v_consignee          VARCHAR(8),
        @v_stpnumber          INTEGER

DECLARE @stops TABLE (
   stp_number   INTEGER NULL
)

DEcLARE @legmiles TABLE (
   lgh_number   INTEGER NULL,
   sumdist      DECIMAL(9,1) NULL,
   minstop      INTEGER NULL
)

IF EXISTS (SELECT 1
             FROM invoiceheader
            WHERE ord_hdrnumber = @p_ordhdrnumber)
BEGIN
   SELECT @v_billto = ivh_billto,
          @v_invoiceby = ISNULL(ivh_invoiceby, 'ORD'),
          @v_mov = mov_number,
          @v_consignee = ivh_destpoint
     FROM invoiceheader
    WHERE ord_hdrnumber = @p_ordhdrnumber AND
          ivh_hdrnumber = (SELECT MIN(ivh_hdrnumber)
                             FROM invoiceheader
                            WHERE ord_hdrnumber = @p_ordhdrnumber)
END
ELSE
BEGIN
   SELECT @v_billto = ord_billto,
          @v_invoiceby = ISNULL(cmp_invoiceby, 'ORD'),
          @v_mov = mov_number,
          @v_consignee = ord_consignee
     FROM orderheader JOIN company ON ord_billto = cmp_id
    WHERE ord_hdrnumber = @p_ordhdrnumber
END 
    
SELECT @v_GI_InvoiceAssets = ISNULL(UPPER(gi_string1), 'DELIVERY')
  FROM generalinfo
 WHERE gi_name = 'InvoiceAssets'

IF @v_billto IS NULL
   RETURN  
  
/* Handle special "invoiceby" options when selecting assets */
IF @v_invoiceby = 'MOV'
BEGIN
   INSERT INTO @stops
      SELECT stp_number
        FROM orderheader JOIN stops ON orderheader.ord_hdrnumber = stops.ord_hdrnumber
       WHERE orderheader.mov_number = @v_mov AND
             ord_billto = @v_billto
END

IF @v_invoiceby = 'CON'
BEGIN
   INSERT INTO @stops
      SELECT stp_number
        FROM orderheader JOIN stops ON orderheader.ord_hdrnumber = stops.ord_hdrnumber
       WHERE orderheader.mov_number = @v_mov AND
             ord_billto = @v_billto AND
             ord_consignee = @v_consignee
END

IF @v_invoiceby <> 'MOV' AND @v_invoiceby <> 'CON'
BEGIN
   INSERT INTO @stops
      SELECT stp_number
        FROM stops
       WHERE ord_hdrnumber = @p_ordhdrnumber AND
             ord_hdrnumber > 0

END
  
/* GI setting dictates which leg to get the assets from */
IF @v_GI_InvoiceAssets = 'DELIVERY'
BEGIN  --get assets for delivery leg
   SELECT @v_stpnumber = (SELECT TOP 1 stops.stp_number
                            FROM @stops st JOIN stops ON st.stp_number = stops.stp_number
                           WHERE stops.stp_type = 'DRP'
                          ORDER BY stops.stp_sequence, stops.stp_arrivaldate DESC)
   
   SELECT @p_driver1 = evt_driver1,
          @p_driver2 = evt_driver2,
          @p_tractor = evt_tractor,
          @p_trailer1 = evt_trailer1,
          @p_trailer2 = evt_trailer2,
          @p_carrier = evt_carrier
     FROM event
    WHERE event.stp_number = @v_stpnumber AND
          event.evt_sequence = 1
END

IF @v_GI_InvoiceAssets = 'MOSTMILES'
BEGIN  --get assets for leg with most miles (use trip miles to get total segment length)
   INSERT INTO @legmiles (lgh_number, sumdist, minstop)
      SELECT lgh_number, SUM(ISNULL(stp_lgh_mileage,0)), MIN(stops.stp_number)
        FROM @stops st JOIN stops ON st.stp_number = stops.stp_number
      GROUP BY lgh_number
      ORDER BY SUM(ISNULL(stp_lgh_mileage, 0)) DESC

   SELECT @v_stpnumber = (SELECT TOP 1 minstop
                            FROM @legmiles)

   SELECT @p_driver1 = evt_driver1,
          @p_driver2 = evt_driver2,
          @p_tractor = evt_tractor,
          @p_trailer1 = evt_trailer1,
          @p_trailer2 = evt_trailer2,
          @p_carrier = evt_carrier
     FROM event
    WHERE event.stp_number = @v_stpnumber AND
          event.evt_sequence = 1
END     
        
IF @v_GI_InvoiceAssets <> 'DELIVERY' AND @v_GI_InvoiceAssets <> 'MOSTMILES'
BEGIN -- get assets for pickup leg
   SELECT @v_stpnumber = (SELECT TOP 1 stops.stp_number
                            FROM @stops st JOIN stops ON st.stp_number = stops.stp_number
                           WHERE stp_type = 'PUP'
                          ORDER BY stp_mfh_sequence)

   SELECT @p_driver1 = evt_driver1,
          @p_driver2 = evt_driver2,
          @p_tractor = evt_tractor,
          @p_trailer1 = evt_trailer1,
          @p_trailer2 = evt_trailer2,
          @p_carrier = evt_carrier
     FROM event
    WHERE event.stp_number = @v_stpnumber AND
          event.evt_sequence = 1
END

--PTS88961 MBR 04/06/15 If no assets are found then pull assets from the order.  I put this in to fix
--billable empty moves from blowing up on save in BackOffice.
IF @p_driver1 IS NULL AND @p_driver2 IS NULL AND @p_tractor IS NULL AND
   @p_trailer1 IS NULL AND @p_trailer2 IS NULL AND @p_carrier IS NULL
BEGIN
   SELECT @p_driver1 = ISNULL(ord_driver1, 'UNKNOWN'),
          @p_driver2 = ISNULL(ord_driver2, 'UNKNOWN'),
          @p_tractor = ISNULL(ord_tractor, 'UNKNOWN'),
          @p_trailer1 = ISNULL(ord_trailer, 'UNKNOWN'),
          @p_trailer2 = ISNULL(ord_trailer2, 'UNKNOWN'),
          @p_carrier = ISNULL(ord_carrier, 'UNKNOWN')
     FROM orderheader 
    WHERE ord_hdrnumber = @p_ordhdrnumber
END

GO
GRANT EXECUTE ON  [dbo].[getassetsforinvoicebackoffice] TO [public]
GO
