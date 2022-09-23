SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************
  Object Description:
  Returns ar export planning board data
  Revision History:
  Date         Name             Label/Card     Description
  -----------  ---------------  ----------     ----------------------------------------
  06/20/2016   BackOffice       PTS: 103320    Initial Release
  08/18/2017   BackOffice       NSUITE-201442  Dedicated Billing
  10/18/2017   BackOffice       NSUITE-202653  A/R board fix
********************************************************************************************************************/

CREATE VIEW [dbo].[ArExportPlanningBoardView] AS
  WITH ArExportCte AS
  (
    SELECT
      i.invoiceId
     ,i.invoiceNumber
     ,i.invoiceStatus
     ,i.invoiceBillTo
     ,i.invoiceBillDate
     ,i.invoiceShipDate
     ,i.invoiceDeliveryDate
     ,ISNULL(s.earliestStopDate, '19500101') AS earliestStopDate
     ,ISNULL(i.revtype1, 'UNK') AS revType1
     ,ISNULL(i.revtype2, 'UNK') AS revType2
     ,ISNULL(i.revtype3, 'UNK') AS revType3
     ,ISNULL(i.revtype4, 'UNK') AS revType4
     ,i.totalCharge
     ,ISNULL(o.ord_subcompany, 'UNK') AS orderSubCompany
     ,i.invoicePrintDate
     ,i.masterBillId
     ,i.dedicatedBillId
     ,i.transferType
    FROM (
        SELECT
           inv.ivh_hdrnumber AS invoiceId
          ,inv.ivh_invoicenumber AS invoiceNumber
          ,inv.ivh_invoicestatus AS invoiceStatus
          ,inv.ivh_billto AS invoiceBillTo
          ,inv.ivh_billdate AS invoiceBillDate
          ,inv.ivh_shipdate AS invoiceShipDate
          ,inv.ivh_deliverydate AS invoiceDeliveryDate
          ,ISNULL(inv.ivh_revtype1, 'UNK') AS revType1
          ,ISNULL(inv.ivh_revtype2, 'UNK') AS revType2
          ,ISNULL(inv.ivh_revtype3, 'UNK') AS revType3
          ,ISNULL(inv.ivh_revtype4, 'UNK') AS revType4
          ,inv.ivh_totalcharge AS totalCharge
          ,inv.ivh_printdate AS invoicePrintDate
          ,inv.ivh_mbnumber AS masterBillId
          ,null AS dedicatedBillId
          ,c.cmp_transfertype AS transferType
		  ,inv.mov_number
		  ,inv.ord_hdrnumber
        FROM dbo.invoiceheader inv
          INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('invoiceheader', NULL) rsva
            ON (rsva.rowsec_rsrv_id = inv.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
          LEFT OUTER JOIN dbo.DedicatedInvoice di ON inv.ivh_hdrnumber = di.InvoiceId
          LEFT OUTER JOIN dbo.company c ON inv.ivh_billto = c.cmp_id
        WHERE di.DedicatedInvoiceId IS NULL
          AND
              (
                inv.ivh_mbstatus <> 'XFR'
                AND
                (
                  inv.ivh_invoicestatus in ('PRN','XFR')
                  OR (inv.ivh_invoicestatus = 'RTP' AND c.cmp_invoicetype = 'NONE')
                  OR (inv.ivh_invoicestatus = 'XFR' AND c.cmp_invoicetype = 'NONE')
                )
                AND
                (
                  c.cmp_transfertype = 'INV'
                  OR (c.cmp_transfertype = 'MAS' AND inv.ivh_mbstatus = 'NTP' AND inv.ivh_invoicestatus in ('PRN','XFR'))
                  OR (c.cmp_transfertype = 'MAS' AND inv.ivh_mbstatus = 'PRN' AND inv.ivh_invoicestatus in ('PRN','XFR'))
                )
                OR inv.ivh_mbstatus = 'XFR'
              )
        UNION
        SELECT
           inv.ivh_hdrnumber AS invoiceId
          ,inv.ivh_invoicenumber AS invoiceNumber
          ,inv.ivh_invoicestatus AS invoiceStatus
          ,inv.ivh_billto AS invoiceBillTo
          ,inv.ivh_billdate AS invoiceBillDate
          ,inv.ivh_shipdate AS invoiceShipDate
          ,inv.ivh_deliverydate AS invoiceDeliveryDate
          ,ISNULL(inv.ivh_revtype1, 'UNK') AS revType1
          ,ISNULL(inv.ivh_revtype2, 'UNK') AS revType2
          ,ISNULL(inv.ivh_revtype3, 'UNK') AS revType3
          ,ISNULL(inv.ivh_revtype4, 'UNK') AS revType4
          ,inv.ivh_totalcharge AS totalCharge
          ,inv.ivh_printdate AS invoicePrintDate
          ,NULL AS masterBillId
          ,db.DedicatedMasterId AS dedicatedBillId
          ,'DED' AS transferType
		  ,inv.mov_number
		  ,inv.ord_hdrnumber
        FROM dbo.invoiceheader inv
          INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('invoiceheader', NULL) rsva
            ON (rsva.rowsec_rsrv_id = inv.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
          INNER JOIN dbo.DedicatedInvoice di
            ON inv.ivh_hdrnumber = di.InvoiceId
          INNER JOIN dbo.DedicatedBill db
            ON di.DedicatedBillId = db.DedicatedBillId
        WHERE
          -- printed or transferred
          db.DedicatedStatusId = 4 or db.DedicatedStatusId = 5
      ) AS i
      LEFT OUTER JOIN (SELECT
                         stops.mov_number
                        ,MIN(CASE ISNULL (stops.stp_schdtearliest, '19500101')
                               WHEN '19500101' THEN stops.stp_arrivaldate
                               ELSE stops.stp_schdtearliest
                             END) as earliestStopDate
                       FROM dbo.stops
                       GROUP BY stops.mov_number) s ON i.mov_number = s.mov_number
      LEFT OUTER JOIN orderheader o ON i.ord_hdrnumber = o.ord_hdrnumber
  )
  SELECT
    ar.invoiceId
    ,ar.invoiceNumber
    ,ar.invoiceStatus
    ,ar.invoiceBillTo
    ,CASE gp.docdate
       WHEN 'Bill Date'
         THEN CASE
                WHEN dbInv.dedicatedBillId IS NOT NULL THEN dbInv.invoiceBillDate
                WHEN mbInv.masterBillId IS NOT NULL THEN mbInv.invoiceBillDate
                ELSE ar.invoiceBillDate
              END
       WHEN 'Start Date'
         THEN CASE
                WHEN dbInv.dedicatedBillId IS NOT NULL THEN dbInv.invoiceShipDate
                WHEN mbInv.masterBillId IS NOT NULL THEN mbInv.invoiceShipDate
                ELSE ar.invoiceShipDate
              END
       WHEN 'Completion Date'
         THEN CASE
                WHEN dbInv.dedicatedBillId IS NOT NULL THEN dbInv.invoiceDeliveryDate
                WHEN mbInv.masterBillId IS NOT NULL THEN mbInv.invoiceDeliveryDate
                ELSE ar.invoiceDeliveryDate
              END
       WHEN 'Earliest Date'
         THEN CASE
                WHEN dbInv.dedicatedBillId IS NOT NULL THEN dbInv.invoiceEarliestStopDate
                WHEN mbInv.masterBillId IS NOT NULL THEN mbInv.invoiceEarliestStopDate
                ELSE ar.earliestStopDate
              END
       WHEN 'Revenue Date'
         THEN CASE
                WHEN dbInv.dedicatedBillId IS NOT NULL THEN dbInv.invoiceBillDate
                WHEN mbInv.masterBillId IS NOT NULL THEN mbInv.invoiceBillDate
                ELSE ar.invoiceBillDate
              END
       WHEN 'Print Date'
         THEN CASE
                WHEN dbInv.dedicatedBillId IS NOT NULL THEN dbInv.invoicePrintDate
                WHEN mbInv.masterBillId IS NOT NULL THEN mbInv.invoicePrintDate
                ELSE ar.invoicePrintDate
              END
     ELSE CASE
            WHEN dbInv.dedicatedBillId IS NOT NULL THEN dbInv.invoiceBillDate
            WHEN mbInv.masterBillId IS NOT NULL THEN mbInv.invoiceBillDate
            ELSE ar.invoiceBillDate
          END
     END AS documentDate
    ,CASE gp.postdate
       WHEN 'Bill Date'
         THEN CASE
                WHEN dbInv.dedicatedBillId IS NOT NULL THEN dbInv.invoiceBillDate
                WHEN mbInv.masterBillId IS NOT NULL THEN mbInv.invoiceBillDate
                ELSE ar.invoiceBillDate
              END
       WHEN 'Start Date'
         THEN CASE
                WHEN dbInv.dedicatedBillId IS NOT NULL THEN dbInv.invoiceShipDate
                WHEN mbInv.masterBillId IS NOT NULL THEN mbInv.invoiceShipDate
                ELSE ar.invoiceShipDate
              END
       WHEN 'Completion Date'
         THEN CASE
                WHEN dbInv.dedicatedBillId IS NOT NULL THEN dbInv.invoiceDeliveryDate
                WHEN mbInv.masterBillId IS NOT NULL THEN mbInv.invoiceDeliveryDate
                ELSE ar.invoiceDeliveryDate
              END
       WHEN 'Earliest Date'
         THEN CASE
                WHEN dbInv.dedicatedBillId IS NOT NULL THEN dbInv.invoiceEarliestStopDate
                WHEN mbInv.masterBillId IS NOT NULL THEN mbInv.invoiceEarliestStopDate
                ELSE ar.earliestStopDate
              END
       WHEN 'Revenue Date'
         THEN CASE
                WHEN dbInv.dedicatedBillId IS NOT NULL THEN dbInv.invoiceBillDate
                WHEN mbInv.masterBillId IS NOT NULL THEN mbInv.invoiceBillDate
                ELSE ar.invoiceBillDate
              END
       WHEN 'Print Date'
         THEN CASE
                WHEN dbInv.dedicatedBillId IS NOT NULL THEN dbInv.invoicePrintDate
                WHEN mbInv.masterBillId IS NOT NULL THEN mbInv.invoicePrintDate
                ELSE ar.invoicePrintDate
              END
     ELSE CASE
            WHEN dbInv.dedicatedBillId IS NOT NULL THEN dbInv.invoiceBillDate
            WHEN mbInv.masterBillId IS NOT NULL THEN mbInv.invoiceBillDate
            ELSE ar.invoiceBillDate
          END
     END AS postDate
    ,ar.revType1
    ,ar.revType2
    ,ar.revType3
    ,ar.revType4
    ,ar.totalCharge
    ,ar.orderSubCompany
    ,ar.invoiceBillDate
    ,ar.invoiceShipDate
    ,ar.invoiceDeliveryDate
    ,ar.earliestStopDate
    ,ar.masterBillId
    ,ar.dedicatedBillId
    ,ar.transferType
  FROM ArExportCte ar
  LEFT JOIN
  (
    SELECT
       arExp.masterBillId,
       MAX(arExp.invoiceBillDate) AS invoiceBillDate,
       MAX(arExp.invoiceShipDate) AS invoiceShipDate,
       MAX(arExp.earliestStopDate) AS invoiceEarliestStopDate,
       MAX(arExp.invoiceDeliveryDate) AS invoiceDeliveryDate,
       MAX(arExp.invoicePrintDate) AS invoicePrintDate
    FROM ArExportCte arExp
    WHERE arExp.masterBillId != 0
    GROUP BY arExp.masterBillId
  ) mbInv
  ON ar.masterBillId = mbInv.masterBillId
  LEFT JOIN
  (
    SELECT
       arExp.dedicatedbillId,
       MAX(arExp.invoiceBillDate) AS invoiceBillDate,
       MAX(arExp.invoiceShipDate) AS invoiceShipDate,
       MAX(arExp.earliestStopDate) AS invoiceEarliestStopDate,
       MAX(arExp.invoiceDeliveryDate) AS invoiceDeliveryDate,
       MAX(arExp.invoicePrintDate) AS invoicePrintDate
    FROM ArExportCte arExp
    WHERE arExp.dedicatedBillId IS NOT NULL
    GROUP BY arExp.dedicatedBillId
  ) dbInv
  ON ar.dedicatedBillId = dbInv.dedicatedBillId
  CROSS APPLY dbo.gpdefaults gp
GO
GRANT SELECT ON  [dbo].[ArExportPlanningBoardView] TO [public]
GO
