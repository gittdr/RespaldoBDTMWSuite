SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
  Object Description:
  Returns gl reset invoice planning board data
  Revision History:
  Date         Name             Label/PTS      Description
  -----------  ---------------  -------------  ----------------------------------------
  02/21/2017   BackOffice       NSUITE-200450  Initial Release
  09/12/2017   BackOffice       NSUITE-201442  Dedicated Billing
  10/06/2017   Eric T. Hammel	NSUITE-202368  Fixed NULL criteria problems with WHERE clause by implementing COALESCE
********************************************************************************************************************/

CREATE VIEW [dbo].[GlResetBillingPlanningBoardView] AS
    SELECT
      i.ivh_hdrnumber AS invoiceId
     ,i.ivh_invoicenumber AS invoiceNumber
     ,i.ivh_invoicestatus AS invoiceStatus
     ,i.ivh_billto AS invoiceBillTo
     ,ISNULL(i.ivh_revtype1, 'UNK') AS revType1
     ,ISNULL(i.ivh_revtype2, 'UNK') AS revType2
     ,ISNULL(i.ivh_revtype3, 'UNK') AS revType3
     ,ISNULL(i.ivh_revtype4, 'UNK') AS revType4
     ,i.ivh_totalcharge AS totalCharge
     ,ISNULL(o.ord_subcompany, 'UNK') AS orderSubCompany
     ,i.ivh_billdate AS invoiceBillDate
     ,i.ivh_shipdate AS invoiceShipDate
     ,i.ivh_deliverydate AS invoiceDeliveryDate
     ,ISNULL(s.earliestStopDate, '19500101') AS earliestStopDate
     ,i.ivh_mbnumber AS masterbillId
     ,di.DedicatedBillId as dedicatedBillId
    FROM dbo.invoiceheader i
      INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('invoiceheader', NULL) rsva
        ON (rsva.rowsec_rsrv_id = i.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
      LEFT OUTER JOIN dbo.company c ON i.ivh_billto = c.cmp_id
      LEFT OUTER JOIN (SELECT
                         stops.mov_number
                        ,MIN(CASE ISNULL (stops.stp_schdtearliest, '19500101')
                               WHEN '19500101' THEN stops.stp_arrivaldate
                               ELSE stops.stp_schdtearliest
                             END) as earliestStopDate
                       FROM dbo.stops
                       GROUP BY stops.mov_number) s ON i.mov_number = s.mov_number
      LEFT OUTER JOIN orderheader o ON i.ord_hdrnumber = o.ord_hdrnumber
      LEFT OUTER JOIN dbo.DedicatedInvoice di ON i.ivh_hdrnumber = di.InvoiceId
    WHERE COALESCE(i.ivh_invoicestatus,'') <> 'XFR'
	AND COALESCE(i.ivh_mbstatus,'') <> 'XFR'
GO
GRANT SELECT ON  [dbo].[GlResetBillingPlanningBoardView] TO [public]
GO
