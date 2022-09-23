SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWScrollInvoicesOnHoldView] AS
/*******************************************************************************************************************  
  Object Description:
  This query retrieves invoice records that are on hold.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  -----------  -----------------------------------------------------------------------
  2016/08/04   Andy Vanek       PTS: 104706  Fix query performance, rewrite query to meet DBA standards
  2016/10/13   Andy Vanek       PTS: 105638  Add additional filter to join on stops table to remove records with ord_hdrnumber = 0
********************************************************************************************************************/
SELECT
  ivh.ivh_hdrnumber,
  ivh.ivh_invoicenumber,
  ivh.ord_number,
  ivh.ord_hdrnumber,
  ivh.ivh_invoicestatus,
  ivh.mov_number,
  ivh.ivh_order_by,
  orderByCompany.cmp_name AS [ivh_order_by_name],
  ivh.ivh_billto,
  billToCompany.cmp_name AS [ivh_billto_name],
  ivh.ivh_shipper,
  shipCompany.cmp_name AS [ivh_shipper_name],
  ivh.ivh_consignee,
  consCompany.cmp_name AS [ivh_consignee_name],
  ivh.ivh_shipdate,
  ivh.ivh_deliverydate,
  ivh.ivh_totalcharge,
  ivh.ivh_revtype1,
  (SELECT lf.name FROM labelfile lf (NOLOCK) WHERE lf.labeldefinition = 'RevType1' AND lf.abbr = ivh.ivh_revtype1) AS [ivh_revtype1_name],
  ivh.ivh_revtype2,
  (SELECT lf.name FROM labelfile lf (NOLOCK) WHERE lf.labeldefinition = 'RevType2' AND lf.abbr = ivh.ivh_revtype2) AS [ivh_revtype2_name],
  ivh.ivh_revtype3,
  (SELECT lf.name FROM labelfile lf (NOLOCK) WHERE lf.labeldefinition = 'RevType3' AND lf.abbr = ivh.ivh_revtype3) AS [ivh_revtype3_name],
  ivh.ivh_revtype4,
  (SELECT lf.name FROM labelfile lf (NOLOCK) WHERE lf.labeldefinition = 'RevType4' AND lf.abbr = ivh.ivh_revtype4) AS [ivh_revtype4_name],
  ivh.ivh_totalweight,
  ivh.ivh_totalpieces,
  ivh.ivh_totalmiles,
  ivh.ivh_totalvolume,
  ivh.ivh_printdate,
  ivh.ivh_billdate,
  ivh.ivh_lastprintdate,
  ivh.ivh_edi_flag,
  billToCompany.cmp_edi210 AS [ivh_edi210_flag],
  billToCompany.cmp_edi214 AS [ivh_edi214_flag],
  ivh.ivh_xferdate,
  ivh.ivh_booked_revtype1,
  ivh.ivh_paperwork_override,
  ivh.ivh_carrier,
  carrier.car_name AS [ivh_carrier_name],
  ISNULL(stops.stp_schdtearliest, '1950-01-01 00:00:00.000') AS [stp_schdtearliest]
FROM invoiceheader ivh (NOLOCK)
  LEFT JOIN stops (NOLOCK) ON stops.ord_hdrnumber = ivh.ord_hdrnumber AND stops.ord_hdrnumber > 0 AND stops.stp_sequence = 1
  LEFT JOIN company billToCompany (NOLOCK) ON (ivh.ivh_billto = billToCompany.cmp_id) 
  LEFT JOIN company consCompany (NOLOCK) ON (ivh.ivh_consignee = consCompany.cmp_id) 
  LEFT JOIN company shipCompany (NOLOCK) ON (ivh.ivh_shipper = shipCompany.cmp_id) 
  LEFT JOIN company orderByCompany (NOLOCK) ON (ivh.ivh_order_by = orderByCompany.cmp_id) 
  LEFT JOIN carrier (NOLOCK) ON ivh.ivh_carrier = carrier.car_id
WHERE ivh.ivh_invoicestatus = 'HLD'
GO
GRANT DELETE ON  [dbo].[TMWScrollInvoicesOnHoldView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollInvoicesOnHoldView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollInvoicesOnHoldView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollInvoicesOnHoldView] TO [public]
GO
