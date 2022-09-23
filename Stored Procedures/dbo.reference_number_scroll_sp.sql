SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[reference_number_scroll_sp]
( @ref_location      VARCHAR(250)
, @ref_number        VARCHAR(30)
, @ref_type          VARCHAR(6)
, @billto            VARCHAR(8)
)
AS
/**
 *
 * NAME:
 * dbo.reference_number_scroll_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for Reference Number Scroll
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 *
 * REVISION HISTORY:
 * PTS 51912 SPN 07/12/11 - Initial Version Created
 * PTS 62158 SPN 09/21/12 - Added ord_status and ord_status_desc
 *
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN

   DECLARE @debug_ind         CHAR(1)
   DECLARE @debug_msg         VARCHAR(1000)
   DECLARE @ll_Count          INT
   DECLARE @SplitbillMilkrun  CHAR(1)

   DECLARE @temp TABLE
   ( hdrnumber          INT            NULL
   , movnumber          INT            NULL
   , ord_number         VARCHAR(12)    NULL
   , ord_status         VARCHAR(6)     NULL
   , ord_status_desc    VARCHAR(20)    NULL
   , ivh_invoicenumber  VARCHAR(12)    NULL
   , invoicestatus      VARCHAR(10)    NULL
   , isinvoiceable      CHAR(1)        NULL
   , totalcharge        MONEY          NULL
   , refnumber          VARCHAR(30)    NULL
   , reftype            VARCHAR(6)     NULL
   , shipper            VARCHAR(8)     NULL
   , shippername        VARCHAR(100)   NULL
   , shippercity        VARCHAR(30)    NULL
   , consignee          VARCHAR(8)     NULL
   , consigneename      VARCHAR(100)   NULL
   , consigneecity      VARCHAR(30)    NULL
   , billto             VARCHAR(8)     NULL
   , billtoname         VARCHAR(100)   NULL
   , company            VARCHAR(8)     NULL
   , stopcompanyname    VARCHAR(30)    NULL
   , stopcity           INT            NULL
   , stopcitynmstct     VARCHAR(30)    NULL
   , commodity          VARCHAR(60)    NULL
   , fgt_bolid          INT            NULL
   , shipdate           DATETIME       NULL
   , deliverydate       DATETIME       NULL
   , revtype1           VARCHAR(6)     NULL
   , revtype2           VARCHAR(6)     NULL
   , revtype3           VARCHAR(6)     NULL
   , revtype4           VARCHAR(6)     NULL
   , hrevtype1          VARCHAR(20)    NULL
   , hrevtype2          VARCHAR(20)    NULL
   , hrevtype3          VARCHAR(20)    NULL
   , hrevtype4          VARCHAR(20)    NULL
   , tabletype          VARCHAR(20)    NULL
   , searchfor          VARCHAR(30)    NULL
   , trailer         VARCHAR(13)    NULL
   )

   SELECT @debug_ind = 'N'

   --GI
   SELECT @SplitbillMilkrun = IsNull(gi_string1,'N')
     FROM generalinfo
    WHERE gi_name = 'SplitbillMilkrun'

   -- orderheader(1)
   IF (@ref_location = '?' OR CharIndex('/orderheader/',@ref_location) > 0)
   BEGIN
      IF @debug_ind = 'Y'
      BEGIN
         SELECT @debug_msg = 'Begin Query: orderheader(1) @' + CONVERT(Varchar(30),GetDate(),100)
         RAISERROR(@debug_msg, 10, 1) WITH NOWAIT
      END
      INSERT INTO @temp
      ( hdrnumber
      , movnumber
      , ord_number
      , ord_status
      , ivh_invoicenumber
      , invoicestatus
      , isinvoiceable
      , totalcharge
      , refnumber
      , reftype
      , shipper
      , shippername
      , shippercity
      , consignee
      , consigneename
      , consigneecity
      , billto
      , billtoname
      , company
      , stopcompanyname
      , stopcity
      , stopcitynmstct
      , commodity
      , fgt_bolid
      , shipdate
      , deliverydate
      , revtype1
      , revtype2
      , revtype3
      , revtype4
      , hrevtype1
      , hrevtype2
      , hrevtype3
      , hrevtype4
      , tabletype
      , searchfor
      , trailer
      )
      SELECT o.ord_hdrnumber                                   AS hdrnumber
           , o.mov_number                                      AS movnumber
           , o.ord_number                                      AS ord_number
           , o.ord_status                                      AS ord_status
           , invoiceheader.ivh_invoicenumber                   AS ivh_invoicenumber
           , invoiceheader.ivh_invoicestatus                   AS invoicestatus
           , (CASE IsNull(o.ord_invoicestatus,'X')
               WHEN 'AVL' THEN 'Y'
               ELSE 'N'
              END
             )                                                 AS isinvoiceable
           , invoiceheader.ivh_totalcharge                     AS totalcharge
           , referencenumber.ref_number                        AS refnumber
           , referencenumber.ref_type                          AS reftype
           , o.ord_shipper                                     AS shipper
           , NULL                                              AS shippername
           , NULL                                              AS shippercity
           , o.ord_consignee                                   AS consignee
           , NULL                                              AS consigneename
           , NULL                                              AS consigneecity
           , o.ord_billto                                      AS billto
           , NULL                                              AS billtoname
           , o.ord_company                                     AS company
           , 'ANY'                                             AS stopcompanyname
           , 0                                                 AS stopcity
           , 'ANY'                                             AS stopcitynmstct
           , (CASE o.ord_rateby
               WHEN 'T' THEN ord_description
               WHEN 'D' THEN 'ANY'
              END
             )                                                 AS commodity
           , NULL                                              AS fgt_bolid
           , o.ord_startdate                                   AS shipdate
           , o.ord_completiondate                              AS deliverydate
           , o.ord_revtype1                                    AS revtype1
           , o.ord_revtype2                                    AS revtype2
           , o.ord_revtype3                                    AS revtype3
           , o.ord_revtype4                                    AS revtype4
           , 'RevType1'                                        AS hrevtype1
           , 'RevType2'                                        AS hrevtype2
           , 'RevType3'                                        AS hrevtype3
           , 'RevType4'                                        AS hrevtype4
           , 'Order'                                           AS tabletype
           , 'orderheader'                                     AS searchfor
           , o.ord_trailer                                     AS trailer
        FROM orderheader o WITH (NOLOCK)
        JOIN referencenumber WITH (NOLOCK) ON o.ord_hdrnumber = referencenumber.ord_hdrnumber
                                          AND referencenumber.ref_table = 'orderheader'
        LEFT OUTER JOIN invoiceheader WITH (NOLOCK) ON o.ord_hdrnumber = invoiceheader.ord_hdrnumber
        INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = o.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or o.rowsec_rsrv_id is null)
		WHERE referencenumber.ref_number LIKE @ref_number
         AND (referencenumber.ref_type = @ref_type OR @ref_type = '?')
         AND (o.ord_billto = @billto OR @billto = 'UNK' OR @billto = 'UNKNOWN')
   END

   -- orderheader(2)
   IF (@ref_location = '?' OR CharIndex('/orderheader/',@ref_location) > 0)
   BEGIN
      IF @debug_ind = 'Y'
      BEGIN
         SELECT @debug_msg = 'Begin Query: orderheader(2) @' + CONVERT(Varchar(30),GetDate(),100)
         RAISERROR(@debug_msg, 10, 1) WITH NOWAIT
      END
      INSERT INTO @temp
      ( hdrnumber
      , movnumber
      , ord_number
      , ord_status
      , ivh_invoicenumber
      , invoicestatus
      , isinvoiceable
      , totalcharge
      , refnumber
      , reftype
      , shipper
      , shippername
      , shippercity
      , consignee
      , consigneename
      , consigneecity
      , billto
      , billtoname
      , company
      , stopcompanyname
      , stopcity
      , stopcitynmstct
      , commodity
      , fgt_bolid
      , shipdate
      , deliverydate
      , revtype1
      , revtype2
      , revtype3
      , revtype4
      , hrevtype1
      , hrevtype2
      , hrevtype3
      , hrevtype4
      , tabletype
      , searchfor
      , trailer
      )
      SELECT o.ord_hdrnumber                                   AS hdrnumber
           , o.mov_number                                      AS movnumber
           , o.ord_number                                      AS ord_number
           , o.ord_status                                      AS ord_status
           , invoiceheader.ivh_invoicenumber                   AS ivh_invoicenumber
           , invoiceheader.ivh_invoicestatus                   AS invoicestatus
           , (CASE IsNull(o.ord_invoicestatus,'X')
               WHEN 'AVL' THEN 'Y'
               ELSE 'N'
              END
             )                                                 AS isinvoiceable
           , invoiceheader.ivh_totalcharge                     AS totalcharge
           , o.ord_refnum                                      AS refnumber
           , o.ord_reftype                                     AS reftype
           , o.ord_shipper                                     AS shipper
           , NULL                                              AS shippername
           , NULL                                              AS shippercity
           , o.ord_consignee                                   AS consignee
           , NULL                                              AS consigneename
           , NULL                                              AS consigneecity
           , o.ord_billto                                      AS billto
           , NULL                                              AS billtoname
           , o.ord_company                                     AS company
           , 'ANY'                                             AS stopcompanyname
           , 0                                                 AS stopcity
           , 'ANY'                                             AS stopcitynmstct
           , (CASE o.ord_rateby
               WHEN 'T' THEN ord_description
               WHEN 'D' THEN 'ANY'
              END
             )                                                 AS commodity
           , NULL                                              AS fgt_bolid
           , o.ord_startdate                                   AS shipdate
           , o.ord_completiondate                              AS deliverydate
           , o.ord_revtype1                                    AS revtype1
           , o.ord_revtype2                                    AS revtype2
           , o.ord_revtype3                                    AS revtype3
           , o.ord_revtype4                                    AS revtype4
           , 'RevType1'                                        AS hrevtype1
           , 'RevType2'                                        AS hrevtype2
           , 'RevType3'                                        AS hrevtype3
           , 'RevType4'                                        AS hrevtype4
           , 'Order'                                           AS tabletype
           , 'orderheader'                                     AS searchfor
           , o.ord_trailer                                     AS trailer
        FROM orderheader o WITH (NOLOCK)
        LEFT OUTER JOIN invoiceheader WITH (NOLOCK) ON o.ord_hdrnumber = invoiceheader.ord_hdrnumber
        INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = o.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or o.rowsec_rsrv_id is null)
       WHERE o.ord_refnum LIKE @ref_number
         AND (o.ord_reftype = @ref_type OR @ref_type = '?')
         AND (o.ord_billto = @billto OR @billto = 'UNK' OR @billto = 'UNKNOWN')
   END

   -- freightdetail(1)
   IF (@ref_location = '?' OR CharIndex('/freightdetail/',@ref_location) > 0)
   BEGIN
      IF @debug_ind = 'Y'
      BEGIN
         SELECT @debug_msg = 'Begin Query: freightdetail(1) @' + CONVERT(Varchar(30),GetDate(),100)
         RAISERROR(@debug_msg, 10, 1) WITH NOWAIT
      END
      INSERT INTO @temp
      ( hdrnumber
      , movnumber
      , ord_number
      , ord_status
      , ivh_invoicenumber
      , invoicestatus
      , isinvoiceable
      , totalcharge
      , refnumber
      , reftype
      , shipper
      , shippername
      , shippercity
      , consignee
      , consigneename
      , consigneecity
      , billto
      , billtoname
      , company
      , stopcompanyname
      , stopcity
      , stopcitynmstct
      , commodity
      , fgt_bolid
      , shipdate
      , deliverydate
      , revtype1
      , revtype2
      , revtype3
      , revtype4
      , hrevtype1
      , hrevtype2
      , hrevtype3
      , hrevtype4
      , tabletype
      , searchfor
      , trailer
      )
      SELECT o.ord_hdrnumber                                AS hdrnumber
           , o.mov_number                                   AS movnumber
           , o.ord_number                                   AS ord_number
           , o.ord_status                                   AS ord_status
           , invoiceheader.ivh_invoicenumber                AS ivh_invoicenumber
           , invoiceheader.ivh_invoicestatus                AS invoicestatus
           , (CASE IsNull(o.ord_invoicestatus,'X')
               WHEN 'AVL' THEN 'Y'
               ELSE 'N'
              END
             )                                              AS isinvoiceable
           , invoiceheader.ivh_totalcharge                  AS totalcharge
           , referencenumber.ref_number                     AS refnumber
           , referencenumber.ref_type                       AS reftype
           , o.ord_shipper                                  AS shipper
           , NULL                                           AS shippername
           , NULL                                           AS shippercity
           , o.ord_consignee                                AS consignee
           , NULL                                           AS consigneename
           , NULL                                           AS consigneecity
           , o.ord_billto                                   AS billto
           , NULL                                           AS billtoname
           , o.ord_company                                  AS company
           , stops.cmp_name                                 AS stopcompanyname
           , stops.stp_city                                 AS stopcity
           , NULL                                           AS stopcitynmstct
           , freightdetail.fgt_description                  AS commodity
           , freightdetail.fgt_bolid                        AS fgt_bolid
           , o.ord_startdate                                AS shipdate
           , o.ord_completiondate                           AS deliverydate
           , o.ord_revtype1                                 AS revtype1
           , o.ord_revtype2                                 AS revtype2
           , o.ord_revtype3                                 AS revtype3
           , o.ord_revtype4                                 AS revtype4
           , 'RevType1'                                     AS hrevtype1
           , 'RevType2'                                     AS hrevtype2
           , 'RevType3'                                     AS hrevtype3
           , 'RevType4'                                     AS hrevtype4
           , 'Commodity'                                    AS tabletype
           , 'freightdetail'                                AS searchfor
           , o.ord_trailer                                  AS trailer
        FROM orderheader o WITH (NOLOCK)
        JOIN stops WITH (NOLOCK) ON o.ord_hdrnumber = stops.ord_hdrnumber
                                AND stops.ord_hdrnumber <> 0
        JOIN freightdetail WITH (NOLOCK) ON stops.stp_number = freightdetail.stp_number
        JOIN referencenumber WITH (NOLOCK) ON freightdetail.fgt_number = referencenumber.ref_tablekey
                                          AND referencenumber.ref_table = 'freightdetail'
        LEFT OUTER JOIN invoiceheader WITH (NOLOCK) ON o.ord_hdrnumber = invoiceheader.ord_hdrnumber
        INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = o.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or o.rowsec_rsrv_id is null)
       WHERE referencenumber.ref_number LIKE @ref_number
         AND (referencenumber.ref_type = @ref_type OR @ref_type = '?')
         AND (o.ord_billto = @billto OR @billto = 'UNK' OR @billto = 'UNKNOWN')
   END

   -- freightdetail(2)
   IF (@ref_location = '?' OR CharIndex('/freightdetail/',@ref_location) > 0)
   BEGIN
      IF @debug_ind = 'Y'
      BEGIN
         SELECT @debug_msg = 'Begin Query: freightdetail(2) @' + CONVERT(Varchar(30),GetDate(),100)
         RAISERROR(@debug_msg, 10, 1) WITH NOWAIT
      END
      INSERT INTO @temp
      ( hdrnumber
      , movnumber
      , ord_number
      , ord_status
      , ivh_invoicenumber
      , invoicestatus
      , isinvoiceable
      , totalcharge
      , refnumber
      , reftype
      , shipper
      , shippername
      , shippercity
      , consignee
      , consigneename
      , consigneecity
      , billto
      , billtoname
      , company
      , stopcompanyname
      , stopcity
      , stopcitynmstct
      , commodity
      , fgt_bolid
      , shipdate
      , deliverydate
      , revtype1
      , revtype2
      , revtype3
      , revtype4
      , hrevtype1
      , hrevtype2
      , hrevtype3
      , hrevtype4
      , tabletype
      , searchfor
      , trailer
      )
      SELECT o.ord_hdrnumber                                AS hdrnumber
           , o.mov_number                                   AS movnumber
           , o.ord_number                                   AS ord_number
           , o.ord_status                                   AS ord_status
           , invoiceheader.ivh_invoicenumber                AS ivh_invoicenumber
           , invoiceheader.ivh_invoicestatus                AS invoicestatus
           , (CASE IsNull(o.ord_invoicestatus,'X')
               WHEN 'AVL' THEN 'Y'
               ELSE 'N'
              END
             )                                              AS isinvoiceable
           , invoiceheader.ivh_totalcharge                  AS totalcharge
           , freightdetail.fgt_refnum                       AS refnumber
           , freightdetail.fgt_reftype                      AS reftype
           , o.ord_shipper                                  AS shipper
           , NULL                                           AS shippername
           , NULL                                           AS shippercity
           , o.ord_consignee                                AS consignee
           , NULL                                           AS consigneename
           , NULL                                           AS consigneecity
           , o.ord_billto                                   AS billto
           , NULL                                           AS billtoname
           , o.ord_company                                  AS company
           , stops.cmp_name                                 AS stopcompanyname
           , stops.stp_city                                 AS stopcity
           , NULL                                           AS stopcitynmstct
           , freightdetail.fgt_description                  AS commodity
           , freightdetail.fgt_bolid                        AS fgt_bolid
           , o.ord_startdate                                AS shipdate
           , o.ord_completiondate                           AS deliverydate
           , o.ord_revtype1                                 AS revtype1
           , o.ord_revtype2                                 AS revtype2
           , o.ord_revtype3                                 AS revtype3
           , o.ord_revtype4                                 AS revtype4
           , 'RevType1'                                     AS hrevtype1
           , 'RevType2'                                     AS hrevtype2
           , 'RevType3'                                     AS hrevtype3
           , 'RevType4'                                     AS hrevtype4
           , 'Commodity'                                    AS tabletype
           , 'freightdetail'                                AS searchfor
           , o.ord_trailer                                  AS trailer
        FROM orderheader o WITH (NOLOCK)
        JOIN stops WITH (NOLOCK) ON o.ord_hdrnumber = stops.ord_hdrnumber
                                AND stops.ord_hdrnumber <> 0
        JOIN freightdetail WITH (NOLOCK) ON stops.stp_number = freightdetail.stp_number
        LEFT OUTER JOIN invoiceheader WITH (NOLOCK) ON o.ord_hdrnumber = invoiceheader.ord_hdrnumber
        INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = o.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or o.rowsec_rsrv_id is null)
       WHERE freightdetail.fgt_refnum LIKE @ref_number
         AND (freightdetail.fgt_reftype = @ref_type OR @ref_type = '?')
         AND (o.ord_billto = @billto OR @billto = 'UNK' OR @billto = 'UNKNOWN')
   END

   -- freightdetail related to Splitbilled Invoices (Misc Invoice/invoicedetail.ord_hdrnumber = 0)
   IF (@ref_location = '?' OR CharIndex('/freightdetail/',@ref_location) > 0) AND @SplitbillMilkrun = 'Y'
   BEGIN
      IF @debug_ind = 'Y'
      BEGIN
         SELECT @debug_msg = 'Begin Query: freightdetail Splitbilled @' + CONVERT(Varchar(30),GetDate(),100)
         RAISERROR(@debug_msg, 10, 1) WITH NOWAIT
      END
      INSERT INTO @temp
      ( hdrnumber
      , movnumber
      , ord_number
      , ord_status
      , ivh_invoicenumber
      , invoicestatus
      , isinvoiceable
      , totalcharge
      , refnumber
      , reftype
      , shipper
      , shippername
      , shippercity
      , consignee
      , consigneename
      , consigneecity
      , billto
      , billtoname
      , company
      , stopcompanyname
      , stopcity
      , stopcitynmstct
      , commodity
      , fgt_bolid
      , shipdate
      , deliverydate
      , revtype1
      , revtype2
      , revtype3
      , revtype4
      , hrevtype1
      , hrevtype2
      , hrevtype3
      , hrevtype4
      , tabletype
      , searchfor
      , trailer
      )
      SELECT DISTINCT
             o.ord_hdrnumber                                AS hdrnumber
           , o.mov_number                                   AS movnumber
           , o.ord_number                                   AS ord_number
           , o.ord_status                                   AS ord_status
           , invoiceheader.ivh_invoicenumber                AS ivh_invoicenumber
           , invoiceheader.ivh_invoicestatus                AS invoicestatus
           , (CASE IsNull(o.ord_invoicestatus,'X')
               WHEN 'AVL' THEN 'Y'
               ELSE 'N'
              END
             )                                              AS isinvoiceable
           , invoiceheader.ivh_totalcharge                  AS totalcharge
           , invoicedetail.ivd_refnum                       AS refnumber
           , invoicedetail.ivd_reftype                      AS reftype
           , invoiceheader.ivh_shipper                      AS shipper
           , NULL                                           AS shippername
           , NULL                                           AS shippercity
           , invoiceheader.ivh_consignee                    AS consignee
           , NULL                                           AS consigneename
           , NULL                                           AS consigneecity
           , invoiceheader.ivh_billto                       AS billto
           , NULL                                           AS billtoname
           , o.ord_company                                  AS company
           , stops.cmp_name                                 AS stopcompanyname
           , stops.stp_city                                 AS stopcity
           , NULL                                           AS stopcitynmstct
           , freightdetail.fgt_description                  AS commodity
           , freightdetail.fgt_bolid                        AS fgt_bolid
           , o.ord_startdate                                AS shipdate
           , o.ord_completiondate                           AS deliverydate
           , o.ord_revtype1                                 AS revtype1
           , o.ord_revtype2                                 AS revtype2
           , o.ord_revtype3                                 AS revtype3
           , o.ord_revtype4                                 AS revtype4
           , 'RevType1'                                     AS hrevtype1
           , 'RevType2'                                     AS hrevtype2
           , 'RevType3'                                     AS hrevtype3
           , 'RevType4'                                     AS hrevtype4
           , 'Commodity'                                    AS tabletype
           , 'freightdetail'                                AS searchfor
           , o.ord_trailer                                  AS trailer
        FROM orderheader o WITH (NOLOCK)
        JOIN stops WITH (NOLOCK) ON o.ord_hdrnumber = stops.ord_hdrnumber
                                AND stops.ord_hdrnumber <> 0
        JOIN freightdetail WITH (NOLOCK) ON stops.stp_number = freightdetail.stp_number
        LEFT OUTER JOIN invoicedetail WITH (NOLOCK) ON invoicedetail.ord_hdrnumber = 0
                                                   AND freightdetail.fgt_number = invoicedetail.fgt_number
        LEFT OUTER JOIN invoiceheader WITH (NOLOCK) ON invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
        INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = o.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or o.rowsec_rsrv_id is null)
       WHERE invoicedetail.ivd_refnum LIKE @ref_number
         AND (invoicedetail.ivd_reftype = @ref_type OR @ref_type = '?')
         AND (invoiceheader.ivh_billto = @billto OR @billto = 'UNK' OR @billto = 'UNKNOWN')
   END

   -- stops(1)
   IF (@ref_location = '?' OR CharIndex('/stops/',@ref_location) > 0)
   BEGIN
      IF @debug_ind = 'Y'
      BEGIN
         SELECT @debug_msg = 'Begin Query: stops(1) @' + CONVERT(Varchar(30),GetDate(),100)
         RAISERROR(@debug_msg, 10, 1) WITH NOWAIT
      END
      INSERT INTO @temp
      ( hdrnumber
      , movnumber
      , ord_number
      , ord_status
      , ivh_invoicenumber
      , invoicestatus
      , isinvoiceable
      , totalcharge
      , refnumber
      , reftype
      , shipper
      , shippername
      , shippercity
      , consignee
      , consigneename
      , consigneecity
      , billto
      , billtoname
      , company
      , stopcompanyname
      , stopcity
      , stopcitynmstct
      , commodity
      , fgt_bolid
      , shipdate
      , deliverydate
      , revtype1
      , revtype2
      , revtype3
      , revtype4
      , hrevtype1
      , hrevtype2
      , hrevtype3
      , hrevtype4
      , tabletype
      , searchfor
      , trailer
      )
      SELECT o.ord_hdrnumber                                   AS hdrnumber
           , o.mov_number                                      AS movnumber
           , o.ord_number                                      AS ord_number
           , o.ord_status                                      AS ord_status
           , invoiceheader.ivh_invoicenumber                   AS ivh_invoicenumber
           , invoiceheader.ivh_invoicestatus                   AS invoicestatus
           , (CASE IsNull(o.ord_invoicestatus,'X')
               WHEN 'AVL' THEN 'Y'
               ELSE 'N'
              END
             )                                                 AS isinvoiceable
           , invoiceheader.ivh_totalcharge                     AS totalcharge
           , referencenumber.ref_number                        AS refnumber
           , referencenumber.ref_type                          AS reftype
           , o.ord_shipper                                     AS shipper
           , NULL                                              AS shippername
           , NULL                                              AS shippercity
           , o.ord_consignee                                   AS consignee
           , NULL                                              AS consigneename
           , NULL                                              AS consigneecity
           , o.ord_billto                                      AS billto
           , NULL                                              AS billtoname
           , o.ord_company                                     AS company
           , stops.cmp_name                                    AS stopcompanyname
           , stops.stp_city                                    AS stopcity
           , NULL                                              AS stopcitynmstct
           , stops.stp_description                             AS commodity
           , NULL                                              AS fgt_bolid
           , o.ord_startdate                                   AS shipdate
           , o.ord_completiondate                              AS deliverydate
           , o.ord_revtype1                                    AS revtype1
           , o.ord_revtype2                                    AS revtype2
           , o.ord_revtype3                                    AS revtype3
           , o.ord_revtype4                                    AS revtype4
           , 'RevType1'                                        AS hrevtype1
           , 'RevType2'                                        AS hrevtype2
           , 'RevType3'                                        AS hrevtype3
           , 'RevType4'                                        AS hrevtype4
           , 'Stop'                                            AS tabletype
           , 'stops'                                           AS searchfor
           , o.ord_trailer                                     AS trailer
        FROM orderheader o WITH (NOLOCK)
        JOIN stops WITH (NOLOCK) ON o.ord_hdrnumber = stops.ord_hdrnumber
                                AND stops.ord_hdrnumber <> 0
        JOIN referencenumber WITH (NOLOCK) ON stops.stp_number = referencenumber.ref_tablekey
                                          AND referencenumber.ref_table = 'stops'
        LEFT OUTER JOIN invoiceheader WITH (NOLOCK) ON o.ord_hdrnumber = invoiceheader.ord_hdrnumber
        INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = o.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or o.rowsec_rsrv_id is null)
       WHERE referencenumber.ref_number LIKE @ref_number
         AND (referencenumber.ref_type = @ref_type OR @ref_type = '?')
         AND (o.ord_billto = @billto OR @billto = 'UNK' OR @billto = 'UNKNOWN')
   END

   -- stops(2)
   IF (@ref_location = '?' OR CharIndex('/stops/',@ref_location) > 0)
   BEGIN
      IF @debug_ind = 'Y'
      BEGIN
         SELECT @debug_msg = 'Begin Query: stops(2) @' + CONVERT(Varchar(30),GetDate(),100)
         RAISERROR(@debug_msg, 10, 1) WITH NOWAIT
      END
      INSERT INTO @temp
      ( hdrnumber
      , movnumber
      , ord_number
      , ord_status
      , ivh_invoicenumber
      , invoicestatus
      , isinvoiceable
      , totalcharge
      , refnumber
      , reftype
      , shipper
      , shippername
      , shippercity
      , consignee
      , consigneename
      , consigneecity
      , billto
      , billtoname
      , company
      , stopcompanyname
      , stopcity
      , stopcitynmstct
      , commodity
      , fgt_bolid
      , shipdate
      , deliverydate
      , revtype1
      , revtype2
      , revtype3
      , revtype4
      , hrevtype1
      , hrevtype2
      , hrevtype3
      , hrevtype4
      , tabletype
      , searchfor
      , trailer
      )
      SELECT o.ord_hdrnumber                                   AS hdrnumber
           , o.mov_number                                      AS movnumber
           , o.ord_number                                      AS ord_number
           , o.ord_status                                      AS ord_status
           , invoiceheader.ivh_invoicenumber                   AS ivh_invoicenumber
           , invoiceheader.ivh_invoicestatus                   AS invoicestatus
           , (CASE IsNull(o.ord_invoicestatus,'X')
               WHEN 'AVL' THEN 'Y'
               ELSE 'N'
              END
             )                                                 AS isinvoiceable
           , invoiceheader.ivh_totalcharge                     AS totalcharge
           , stops.stp_refnum                                  AS refnumber
           , stops.stp_reftype                                 AS reftype
           , o.ord_shipper                                     AS shipper
           , NULL                                              AS shippername
           , NULL                                              AS shippercity
           , o.ord_consignee                                   AS consignee
           , NULL                                              AS consigneename
           , NULL                                              AS consigneecity
           , o.ord_billto                                      AS billto
           , NULL                                              AS billtoname
           , o.ord_company                                     AS company
           , stops.cmp_name                                    AS stopcompanyname
           , stops.stp_city                                    AS stopcity
           , NULL                                              AS stopcitynmstct
           , stops.stp_description                             AS commodity
           , NULL                                              AS fgt_bolid
           , o.ord_startdate                                   AS shipdate
           , o.ord_completiondate                              AS deliverydate
           , o.ord_revtype1                                    AS revtype1
           , o.ord_revtype2                                    AS revtype2
           , o.ord_revtype3                                    AS revtype3
           , o.ord_revtype4                                    AS revtype4
           , 'RevType1'                                        AS hrevtype1
           , 'RevType2'                                        AS hrevtype2
           , 'RevType3'                                        AS hrevtype3
           , 'RevType4'                                        AS hrevtype4
           , 'Stop'                                            AS tabletype
           , 'stops'                                           AS searchfor
           , o.ord_trailer                                     AS trailer
        FROM orderheader o WITH (NOLOCK)
        JOIN stops WITH (NOLOCK) ON o.ord_hdrnumber = stops.ord_hdrnumber
                                AND stops.ord_hdrnumber <> 0
        LEFT OUTER JOIN invoiceheader WITH (NOLOCK) ON o.ord_hdrnumber = invoiceheader.ord_hdrnumber
        INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = o.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or o.rowsec_rsrv_id is null)
       WHERE stops.stp_refnum LIKE @ref_number
         AND (stops.stp_reftype = @ref_type OR @ref_type = '?')
         AND (o.ord_billto = @billto OR @billto = 'UNK' OR @billto = 'UNKNOWN')
   END

   -- legheader
   IF (@ref_location = '?' OR CharIndex('/legheader/',@ref_location) > 0)
   BEGIN
      IF @debug_ind = 'Y'
      BEGIN
         SELECT @debug_msg = 'Begin Query: legheader @' + CONVERT(Varchar(30),GetDate(),100)
         RAISERROR(@debug_msg, 10, 1) WITH NOWAIT
      END
      INSERT INTO @temp
      ( hdrnumber
      , movnumber
      , ord_number
      , ord_status
      , ivh_invoicenumber
      , invoicestatus
      , isinvoiceable
      , totalcharge
      , refnumber
      , reftype
      , shipper
      , shippername
      , shippercity
      , consignee
      , consigneename
      , consigneecity
      , billto
      , billtoname
      , company
      , stopcompanyname
      , stopcity
      , stopcitynmstct
      , commodity
      , fgt_bolid
      , shipdate
      , deliverydate
      , revtype1
      , revtype2
      , revtype3
      , revtype4
      , hrevtype1
      , hrevtype2
      , hrevtype3
      , hrevtype4
      , tabletype
      , searchfor
      , trailer
      )
      SELECT o.ord_hdrnumber                                   AS hdrnumber
           , o.mov_number                                      AS movnumber
           , o.ord_number                                      AS ord_number
           , o.ord_status                                      AS ord_status
           , invoiceheader.ivh_invoicenumber                   AS ivh_invoicenumber
           , invoiceheader.ivh_invoicestatus                   AS invoicestatus
           , (CASE IsNull(o.ord_invoicestatus,'X')
               WHEN 'AVL' THEN 'Y'
               ELSE 'N'
              END
             )                                                 AS isinvoiceable
           , invoiceheader.ivh_totalcharge                     AS totalcharge
           , legheader.lgh_refnum                              AS refnumber
           , legheader.lgh_reftype                             AS reftype
           , o.ord_shipper                                     AS shipper
           , NULL                                              AS shippername
           , NULL                                              AS shippercity
           , o.ord_consignee                                   AS consignee
           , NULL                                              AS consigneename
           , NULL                                              AS consigneecity
           , o.ord_billto                                      AS billto
           , NULL                                              AS billtoname
           , o.ord_company                                     AS company
           , 'ANY'                                             AS stopcompanyname
           , legheader.lgh_endcity                             AS stopcity
           , NULL                                              AS stopcitynmstct
           , legheader.fgt_description                         AS commodity
           , NULL                                              AS fgt_bolid
           , o.ord_startdate                                   AS shipdate
           , o.ord_completiondate                              AS deliverydate
           , o.ord_revtype1                                    AS revtype1
           , o.ord_revtype2                                    AS revtype2
           , o.ord_revtype3                                    AS revtype3
           , o.ord_revtype4                                    AS revtype4
           , 'RevType1'                                        AS hrevtype1
           , 'RevType2'                                        AS hrevtype2
           , 'RevType3'                                        AS hrevtype3
           , 'RevType4'                                        AS hrevtype4
           , 'Trip Segment'                                    AS tabletype
           , 'legheader'                                       AS searchfor
           , o.ord_trailer                                     AS trailer
        FROM orderheader o WITH (NOLOCK)
        JOIN legheader WITH (NOLOCK) ON o.ord_hdrnumber = legheader.ord_hdrnumber
        LEFT OUTER JOIN invoiceheader WITH (NOLOCK) ON o.ord_hdrnumber = invoiceheader.ord_hdrnumber
        INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = o.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or o.rowsec_rsrv_id is null)
       WHERE legheader.lgh_refnum LIKE @ref_number
         AND (legheader.lgh_reftype = @ref_type OR @ref_type = '?')
         AND (o.ord_billto = @billto OR @billto = 'UNK' OR @billto = 'UNKNOWN')
   END

   -- invoiceheader(1)
   IF (@ref_location = '?' OR CharIndex('/invoiceheader/',@ref_location) > 0)
   BEGIN
      IF @debug_ind = 'Y'
      BEGIN
         SELECT @debug_msg = 'Begin Query: invoiceheader(1) @' + CONVERT(Varchar(30),GetDate(),100)
         RAISERROR(@debug_msg, 10, 1) WITH NOWAIT
      END
      INSERT INTO @temp
      ( hdrnumber
      , movnumber
      , ord_number
      , ord_status
      , ivh_invoicenumber
      , invoicestatus
      , isinvoiceable
      , totalcharge
      , refnumber
      , reftype
      , shipper
      , shippername
      , shippercity
      , consignee
      , consigneename
      , consigneecity
      , billto
      , billtoname
      , company
      , stopcompanyname
      , stopcity
      , stopcitynmstct
      , commodity
      , fgt_bolid
      , shipdate
      , deliverydate
      , revtype1
      , revtype2
      , revtype3
      , revtype4
      , hrevtype1
      , hrevtype2
      , hrevtype3
      , hrevtype4
      , tabletype
      , searchfor
      , trailer
      )
      SELECT 0                                                 AS hdrnumber
           , invoiceheader.mov_number                          AS movnumber
           , invoiceheader.ord_number                          AS ord_number
           , NULL                                              AS ord_status
           , invoiceheader.ivh_invoicenumber                   AS ivh_invoicenumber
           , invoiceheader.ivh_invoicestatus                   AS invoicestatus
           , 'N'                                               AS isinvoiceable
           , invoiceheader.ivh_totalcharge                     AS totalcharge
           , referencenumber.ref_number                        AS refnumber
           , referencenumber.ref_type                          AS reftype
           , invoiceheader.ivh_shipper                         AS shipper
           , NULL                                              AS shippername
           , NULL                                              AS shippercity
           , invoiceheader.ivh_consignee                       AS consignee
           , NULL                                              AS consigneename
           , NULL                                              AS consigneecity
           , invoiceheader.ivh_billto                          AS billto
           , NULL                                              AS billtoname
           , ''                                                AS company
           , 'ANY'                                             AS stopcompanyname
           , 0                                                 AS stopcity
           , 'ANY'                                             AS stopcitynmstct
           , 'ANY'                                             AS commodity
           , NULL                                              AS fgt_bolid
           , invoiceheader.ivh_shipdate                        AS shipdate
           , invoiceheader.ivh_deliverydate                    AS deliverydate
           , invoiceheader.ivh_revtype1                        AS revtype1
           , invoiceheader.ivh_revtype2                        AS revtype2
           , invoiceheader.ivh_revtype3                        AS revtype3
           , invoiceheader.ivh_revtype3                        AS revtype4
           , 'RevType1'                                        AS hrevtype1
           , 'RevType2'                                        AS hrevtype2
           , 'RevType3'                                        AS hrevtype3
           , 'RevType4'                                        AS hrevtype4
           , 'Invoice'                                         AS tabletype
           , 'invoiceheader'                                   AS searchfor
           , invoiceheader.ivh_trailer                         AS trailer
        FROM invoiceheader WITH (NOLOCK)
        JOIN referencenumber WITH (NOLOCK) ON invoiceheader.ivh_hdrnumber = referencenumber.ref_tablekey
                                          AND referencenumber.ref_table = 'invoiceheader'
        INNER JOIN dbo.RowRestrictValidAssignments_invoiceheader_fn() rsrv on (rsrv.rowsec_rsrv_id = invoiceheader.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or invoiceheader.rowsec_rsrv_id is null)
       WHERE referencenumber.ref_number LIKE @ref_number
         AND (referencenumber.ref_type = @ref_type OR @ref_type = '?')
         AND (invoiceheader.ivh_billto = @billto OR @billto = 'UNK' OR @billto = 'UNKNOWN')
   END

   -- invoiceheader(2)
   IF (@ref_location = '?' OR CharIndex('/invoiceheader/',@ref_location) > 0)
   BEGIN
      IF @debug_ind = 'Y'
      BEGIN
         SELECT @debug_msg = 'Begin Query: invoiceheader(2) @' + CONVERT(Varchar(30),GetDate(),100)
         RAISERROR(@debug_msg, 10, 1) WITH NOWAIT
      END
      INSERT INTO @temp
      ( hdrnumber
      , movnumber
      , ord_number
      , ord_status
      , ivh_invoicenumber
      , invoicestatus
      , isinvoiceable
      , totalcharge
      , refnumber
      , reftype
      , shipper
      , shippername
      , shippercity
      , consignee
      , consigneename
      , consigneecity
      , billto
      , billtoname
      , company
      , stopcompanyname
      , stopcity
      , stopcitynmstct
      , commodity
      , fgt_bolid
      , shipdate
      , deliverydate
      , revtype1
      , revtype2
      , revtype3
      , revtype4
      , hrevtype1
      , hrevtype2
      , hrevtype3
      , hrevtype4
      , tabletype
      , searchfor
      , trailer
      )
      SELECT 0                                                 AS hdrnumber
           , invoiceheader.mov_number                          AS movnumber
           , invoiceheader.ord_number                          AS ord_number
           , NULL                                              AS ord_status
           , invoiceheader.ivh_invoicenumber                   AS ivh_invoicenumber
           , invoiceheader.ivh_invoicestatus                   AS invoicestatus
           , 'N'                                               AS isinvoiceable
           , invoiceheader.ivh_totalcharge                     AS totalcharge
           , invoiceheader.ivh_ref_number                      AS refnumber
           , invoiceheader.ivh_reftype                         AS reftype
           , invoiceheader.ivh_shipper                         AS shipper
           , NULL                                              AS shippername
           , NULL                                              AS shippercity
           , invoiceheader.ivh_consignee                       AS consignee
           , NULL                                              AS consigneename
           , NULL                                              AS consigneecity
           , invoiceheader.ivh_billto                          AS billto
           , NULL                                              AS billtoname
           , ''                                                AS company
           , 'ANY'                                             AS stopcompanyname
           , 0                                                 AS stopcity
           , 'ANY'                                             AS stopcitynmstct
           , 'ANY'                                             AS commodity
           , NULL                                              AS fgt_bolid
           , invoiceheader.ivh_shipdate                        AS shipdate
           , invoiceheader.ivh_deliverydate                    AS deliverydate
           , invoiceheader.ivh_revtype1                        AS revtype1
           , invoiceheader.ivh_revtype2                        AS revtype2
           , invoiceheader.ivh_revtype3                        AS revtype3
           , invoiceheader.ivh_revtype3                        AS revtype4
           , 'RevType1'                                        AS hrevtype1
           , 'RevType2'                                        AS hrevtype2
           , 'RevType3'                                        AS hrevtype3
           , 'RevType4'                                        AS hrevtype4
           , 'Invoice'                                         AS tabletype
           , 'invoiceheader'                                   AS searchfor
           , invoiceheader.ivh_trailer                         AS trailer
        FROM invoiceheader WITH (NOLOCK)
        INNER JOIN dbo.RowRestrictValidAssignments_invoiceheader_fn() rsrv on (rsrv.rowsec_rsrv_id = invoiceheader.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or invoiceheader.rowsec_rsrv_id is null)
       WHERE invoiceheader.ivh_ref_number LIKE @ref_number
         AND (invoiceheader.ivh_reftype = @ref_type OR @ref_type = '?')
         AND (invoiceheader.ivh_billto = @billto OR @billto = 'UNK' OR @billto = 'UNKNOWN')
   END

   -- invoicedetail
   IF (@ref_location = '?' OR CharIndex('/invoiceheader/',@ref_location) > 0)
   BEGIN
      IF @debug_ind = 'Y'
      BEGIN
         SELECT @debug_msg = 'Begin Query: invoicedetail @' + CONVERT(Varchar(30),GetDate(),100)
         RAISERROR(@debug_msg, 10, 1) WITH NOWAIT
      END
      INSERT INTO @temp
      ( hdrnumber
      , movnumber
      , ord_number
      , ord_status
      , ivh_invoicenumber
      , invoicestatus
      , isinvoiceable
      , totalcharge
      , refnumber
      , reftype
      , shipper
      , shippername
      , shippercity
      , consignee
      , consigneename
      , consigneecity
      , billto
      , billtoname
      , company
      , stopcompanyname
      , stopcity
      , stopcitynmstct
      , commodity
      , fgt_bolid
      , shipdate
      , deliverydate
      , revtype1
      , revtype2
      , revtype3
      , revtype4
      , hrevtype1
      , hrevtype2
      , hrevtype3
      , hrevtype4
      , tabletype
      , searchfor
      , trailer
      )
      SELECT 0                                                 AS hdrnumber
           , invoiceheader.mov_number                          AS movnumber
           , invoiceheader.ord_number                          AS ord_number
           , NULL                                              AS ord_status
           , invoiceheader.ivh_invoicenumber                   AS ivh_invoicenumber
           , invoiceheader.ivh_invoicestatus                   AS invoicestatus
           , 'N'                                               AS isinvoiceable
           , invoiceheader.ivh_totalcharge                     AS totalcharge
           , invoicedetail.ivd_refnum                          AS refnumber
           , invoicedetail.ivd_reftype                         AS reftype
           , invoiceheader.ivh_shipper                         AS shipper
           , NULL                                              AS shippername
           , NULL                                              AS shippercity
           , invoiceheader.ivh_consignee                       AS consignee
           , NULL                                              AS consigneename
           , NULL                                              AS consigneecity
           , invoiceheader.ivh_billto                          AS billto
           , NULL                                              AS billtoname
           , ''                                                AS company
           , 'ANY'                                             AS stopcompanyname
           , 0                                                 AS stopcity
           , 'ANY'                                             AS stopcitynmstct
           , 'ANY'                                             AS commodity
           , NULL                                              AS fgt_bolid
           , invoiceheader.ivh_shipdate                        AS shipdate
           , invoiceheader.ivh_deliverydate                    AS deliverydate
           , invoiceheader.ivh_revtype1                        AS revtype1
           , invoiceheader.ivh_revtype2                        AS revtype2
           , invoiceheader.ivh_revtype3                        AS revtype3
           , invoiceheader.ivh_revtype3                        AS revtype4
           , 'RevType1'                                        AS hrevtype1
           , 'RevType2'                                        AS hrevtype2
           , 'RevType3'                                        AS hrevtype3
           , 'RevType4'                                        AS hrevtype4
           , 'Invoice'                                         AS tabletype
           , 'invoicedetail'                                   AS searchfor
           , invoiceheader.ivh_trailer                         AS trailer
        FROM invoiceheader WITH (NOLOCK)
        JOIN invoicedetail WITH (NOLOCK) ON invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
        INNER JOIN dbo.RowRestrictValidAssignments_invoiceheader_fn() rsrv on (rsrv.rowsec_rsrv_id = invoiceheader.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or invoiceheader.rowsec_rsrv_id is null)
       WHERE invoicedetail.ivd_refnum LIKE @ref_number
         AND (invoicedetail.ivd_reftype = @ref_type OR @ref_type = '?')
         AND (invoiceheader.ivh_billto = @billto OR @billto = 'UNK' OR @billto = 'UNKNOWN')
   END

   -- payheader
   IF (@ref_location = '?' OR CharIndex('/payheader/',@ref_location) > 0)
   BEGIN
      IF @debug_ind = 'Y'
      BEGIN
         SELECT @debug_msg = 'Begin Query: payheader @' + CONVERT(Varchar(30),GetDate(),100)
         RAISERROR(@debug_msg, 10, 1) WITH NOWAIT
      END
      INSERT INTO @temp
      ( hdrnumber
      , movnumber
      , ord_number
      , ord_status
      , ivh_invoicenumber
      , invoicestatus
      , isinvoiceable
      , totalcharge
      , refnumber
      , reftype
      , shipper
      , shippername
      , shippercity
      , consignee
      , consigneename
      , consigneecity
      , billto
      , billtoname
      , company
      , stopcompanyname
      , stopcity
      , stopcitynmstct
      , commodity
      , fgt_bolid
      , shipdate
      , deliverydate
      , revtype1
      , revtype2
      , revtype3
      , revtype4
      , hrevtype1
      , hrevtype2
      , hrevtype3
      , hrevtype4
      , tabletype
      , searchfor
      , trailer
      )
      SELECT o.ord_hdrnumber                                   AS hdrnumber
           , o.mov_number                                      AS movnumber
           , o.ord_number                                      AS ord_number
           , o.ord_status                                      AS ord_status
           , invoiceheader.ivh_invoicenumber                   AS ivh_invoicenumber
           , invoiceheader.ivh_invoicestatus                   AS invoicestatus
           , (CASE IsNull(o.ord_invoicestatus,'X')
               WHEN 'AVL' THEN 'Y'
               ELSE 'N'
              END
             )                                                 AS isinvoiceable
           , invoiceheader.ivh_totalcharge                     AS totalcharge
           , payheader.pyh_ref_number                          AS refnumber
           , payheader.pyh_ref_type                            AS reftype
           , o.ord_shipper                                     AS shipper
           , NULL                                              AS shippername
           , NULL                                              AS shippercity
           , o.ord_consignee                                   AS consignee
           , NULL                                              AS consigneename
           , NULL                                              AS consigneecity
           , o.ord_billto                                      AS billto
           , NULL                                              AS billtoname
           , o.ord_company                                     AS company
           , 'ANY'                                             AS stopcompanyname
           , 0                                                 AS stopcity
           , 'ANY'                                             AS stopcitynmstct
           , (CASE o.ord_rateby
               WHEN 'T' THEN ord_description
               WHEN 'D' THEN 'ANY'
              END
             )                                                 AS commodity
           , NULL                                              AS fgt_bolid
           , o.ord_startdate                                   AS shipdate
           , o.ord_completiondate                              AS deliverydate
           , o.ord_revtype1                                    AS revtype1
           , o.ord_revtype2                                    AS revtype2
           , o.ord_revtype3                                    AS revtype3
           , o.ord_revtype4                                    AS revtype4
           , 'RevType1'                                        AS hrevtype1
           , 'RevType2'                                        AS hrevtype2
           , 'RevType3'                                        AS hrevtype3
           , 'RevType4'                                        AS hrevtype4
           , 'Settlement Header'                               AS tabletype
           , 'payheader'                                       AS searchfor
           , o.ord_trailer                                     AS trailer
        FROM payheader WITH (NOLOCK)
        LEFT OUTER JOIN legheader WITH (NOLOCK) ON payheader.pyh_lgh_number = legheader.lgh_number
        LEFT OUTER JOIN orderheader o WITH (NOLOCK) ON legheader.ord_hdrnumber = o.ord_hdrnumber
        LEFT OUTER JOIN invoiceheader WITH (NOLOCK) ON o.ord_hdrnumber = invoiceheader.ord_hdrnumber
        INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = o.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or o.rowsec_rsrv_id is null)
       WHERE payheader.pyh_ref_number LIKE @ref_number
         AND (payheader.pyh_ref_type = @ref_type OR @ref_type = '?')
         AND (o.ord_billto = @billto OR @billto = 'UNK' OR @billto = 'UNKNOWN')
   END

   -- paydetail
   IF (@ref_location = '?' OR CharIndex('/paydetail/',@ref_location) > 0)
   BEGIN
      IF @debug_ind = 'Y'
      BEGIN
         SELECT @debug_msg = 'Begin Query: paydetail @' + CONVERT(Varchar(30),GetDate(),100)
         RAISERROR(@debug_msg, 10, 1) WITH NOWAIT
      END
      INSERT INTO @temp
      ( hdrnumber
      , movnumber
      , ord_number
      , ord_status
      , ivh_invoicenumber
      , invoicestatus
      , isinvoiceable
      , totalcharge
      , refnumber
      , reftype
      , shipper
      , shippername
      , shippercity
      , consignee
      , consigneename
      , consigneecity
      , billto
      , billtoname
      , company
      , stopcompanyname
      , stopcity
      , stopcitynmstct
      , commodity
      , fgt_bolid
      , shipdate
      , deliverydate
      , revtype1
      , revtype2
      , revtype3
      , revtype4
      , hrevtype1
      , hrevtype2
      , hrevtype3
      , hrevtype4
      , tabletype
      , searchfor
      , trailer
      )
      SELECT o.ord_hdrnumber                                   AS hdrnumber
           , o.mov_number                                      AS movnumber
           , o.ord_number                                      AS ord_number
           , o.ord_status                                      AS ord_status
           , invoiceheader.ivh_invoicenumber                   AS ivh_invoicenumber
           , invoiceheader.ivh_invoicestatus                   AS invoicestatus
           , (CASE IsNull(o.ord_invoicestatus,'X')
               WHEN 'AVL' THEN 'Y'
               ELSE 'N'
              END
             )                                                 AS isinvoiceable
           , invoiceheader.ivh_totalcharge                     AS totalcharge
           , paydetail.pyd_refnum                              AS refnumber
           , paydetail.pyd_refnumtype                          AS reftype
           , o.ord_shipper                                     AS shipper
           , NULL                                              AS shippername
           , NULL                                              AS shippercity
           , o.ord_consignee                                   AS consignee
           , NULL                                              AS consigneename
           , NULL                                              AS consigneecity
           , o.ord_billto                                      AS billto
           , NULL                                              AS billtoname
           , o.ord_company                                     AS company
           , 'ANY'                                             AS stopcompanyname
           , 0                                                 AS stopcity
           , 'ANY'                                             AS stopcitynmstct
           , (CASE o.ord_rateby
               WHEN 'T' THEN ord_description
               WHEN 'D' THEN 'ANY'
              END
             )                                                 AS commodity
           , NULL                                              AS fgt_bolid
           , o.ord_startdate                                   AS shipdate
           , o.ord_completiondate                              AS deliverydate
           , o.ord_revtype1                                    AS revtype1
           , o.ord_revtype2                                    AS revtype2
           , o.ord_revtype3                                    AS revtype3
           , o.ord_revtype4                                    AS revtype4
           , 'RevType1'                                        AS hrevtype1
           , 'RevType2'                                        AS hrevtype2
           , 'RevType3'                                        AS hrevtype3
           , 'RevType4'                                        AS hrevtype4
           , 'Settlement Detail'                               AS tabletype
           , 'paydetail'                                       AS searchfor
           , o.ord_trailer                                     AS trailer
        FROM paydetail WITH (NOLOCK)
        LEFT OUTER JOIN legheader WITH (NOLOCK) ON paydetail.lgh_number = legheader.lgh_number
        LEFT OUTER JOIN orderheader o WITH (NOLOCK) ON legheader.ord_hdrnumber = o.ord_hdrnumber
        LEFT OUTER JOIN invoiceheader WITH (NOLOCK) ON o.ord_hdrnumber = invoiceheader.ord_hdrnumber
        INNER JOIN dbo.RowRestrictValidAssignments_orderheader_fn() rsrv on (rsrv.rowsec_rsrv_id = o.rowsec_rsrv_id or rsrv.rowsec_rsrv_id = 0 or o.rowsec_rsrv_id is null)
       WHERE paydetail.pyd_refnum LIKE @ref_number
         AND (paydetail.pyd_refnumtype = @ref_type OR @ref_type = '?')
         AND (o.ord_billto = @billto OR @billto = 'UNK' OR @billto = 'UNKNOWN')
   END

   --Update Key fields to 0 when NULL
   UPDATE @temp
      SET hdrnumber = 0
    WHERE hdrnumber IS NULL
   UPDATE @temp
      SET ivh_invoicenumber = 'None'
    WHERE ivh_invoicenumber IS NULL OR ivh_invoicenumber = ''
   UPDATE @temp
      SET invoicestatus = 'None'
    WHERE invoicestatus IS NULL OR invoicestatus = ''

   --Update other Info
   UPDATE @temp
      SET shippername   = cs.cmp_name
        , shippercity   = cs.cty_nmstct
        , consigneename = cc.cmp_name
        , consigneecity = cc.cty_nmstct
        , billtoname = cb.cmp_name
        , stopcitynmstct   = city.cty_nmstct
     FROM @temp t
   LEFT OUTER JOIN city WITH (NOLOCK) ON t.stopcity = city.cty_code
   LEFT OUTER JOIN company cs WITH (NOLOCK) ON t.shipper = cs.cmp_id
   LEFT OUTER JOIN company cc WITH (NOLOCK) ON t.consignee = cc.cmp_id
   LEFT OUTER JOIN company cb WITH (NOLOCK) ON t.shipper = cb.cmp_id

   --BEGIN PTS 62158 SPN
   UPDATE @temp
      SET ord_status = o.ord_status
     FROM @temp t
     JOIN orderheader o ON t.hdrnumber = o.ord_hdrnumber
    WHERE t.hdrnumber > 0
      AND t.ord_status IS NULL

   UPDATE @temp
      SET ord_status_desc = l.name
     FROM @temp t
     JOIN (SELECT abbr
                , name
             FROM labelfile
            WHERE labeldefinition = 'DispStatus'
          ) l ON t.ord_status = l.abbr
    WHERE t.ord_status IS NOT NULL
   --END PTS 62158 SPN

   --Return Resultset
   SELECT *
     FROM @temp
   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[reference_number_scroll_sp] TO [public]
GO
