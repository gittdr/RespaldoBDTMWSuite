SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWScrollOrdersReadyForNoTouchBillingView] AS
/*******************************************************************************************************************  
  Object Description:
  This query retrieves orderheader records that are considered available for invoicing, to be processed by 
  the No Touch Processing Service

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  -----------  -----------------------------------------------------------------------
  2016/08/04   Andy Vanek       PTS: 104706  Fix query performance, rewrite query to meet DBA standards
  2016/08/23   Andy Vanek       PTS: 104958  Reintroduce columns expected by NTBSCR planning board
  2016/08/30   Andy Vanek       PTS: 105064  DBA standards fixes
********************************************************************************************************************/
SELECT    
  orderheader.ord_hdrnumber,
  orderheader.ord_number, 
  orderheader.ord_status, 
  orderheader.ord_invoicestatus, 
  orderheader.ord_company,
  company_a.cmp_id AS [origin_cmp_id], 
  company_a.cmp_name AS [origin_cmp_name], 
  company_b.cmp_id AS [dest_cmp_id], 
  company_b.cmp_name AS [dest_cmp_name], 
  company_c.cmp_id AS [orderby_cmp_id], 
  company_c.cmp_name AS [orderby_cmp_name], 
  company_c.cty_nmstct AS [orderby_cty_nmstct], 
  company_d.cmp_id AS [BillToID], 
  company_d.cmp_name AS [billto_cmp_name], 
  company_d.cty_nmstct AS [billto_cty_nmstct],
  orderheader.ord_startdate, 
  orderheader.ord_completiondate, 
  orderheader.ord_originstate, 
  orderheader.ord_deststate, 
  orderheader.ord_revtype1,
  lblRevType1.[name] AS [ord_revtype1_name],
  orderheader.ord_revtype2, 
  lblRevType2.[name] AS [ord_revtype2_name],
  orderheader.ord_revtype3,
  lblRevType3.[name] AS [ord_revtype3_name],
  orderheader.ord_revtype4, 
  lblRevType4.[name] AS [ord_revtype4_name],
  orderheader.mov_number, 
  orderheader.ord_charge, 
  orderheader.ord_totalcharge, 
  orderheader.ord_accessorial_chrg, 
  orderheader.ord_priority, 
  orderheader.ord_originregion1, 
  orderheader.ord_destregion1, 
  orderheader.ord_reftype, 
  orderheader.ord_refnum, 
  (CASE company_a.cty_nmstct WHEN 'UNKNOWN' THEN origCity.cty_nmstct ELSE company_a.cty_nmstct  END) AS [origin_cty_nmstct], 
  (CASE company_b.cty_nmstct WHEN 'UNKNOWN' THEN destCity.cty_nmstct ELSE company_b.cty_nmstct END) AS [dest_cty_nmstct], 
  orderheader.ord_origincity,
  orderheader.ord_destcity,
  orderheader.cmd_code,
  orderheader.ord_description, 
  orderheader.ord_remark, 
  orderheader.ord_trailer, 
  orderheader.ord_bookdate, 
  orderheader.ord_bookedby, 
  orderheader.ord_booked_revtype1, 
  orderheader.ord_entryport, 
  orderheader.ord_exitport, 
  orderheader.ord_driver1, 
  orderheader.ord_driver2, 
  orderheader.ord_tractor, 
  orderheader.ord_odmetermiles, 
  orderheader.ord_route, 
  orderheader.ord_route_effc_date, 
  orderheader.ord_route_exp_date, 
  company_a.cmp_primaryphone AS [origin_cmp_primaryphone], 
  company_b.cmp_primaryphone AS [dest_cmp_primaryphone], 
  company_d.cmp_primaryphone AS [billto_cmp_primaryphone], 
  orderheader.ord_totalmiles, 
  orderheader.ord_carrier, 
  ISNULL(orderheader.ord_trailer2, '') AS [ord_trailer2], 
  orderheader.ord_chassis, 
  orderheader.ord_chassis2, 
  orderheader.ord_origin_earliestdate AS [origin_earliest], 
  orderheader.ord_origin_latestdate AS [origin_latest], 
  orderheader.ord_dest_earliestdate AS [dest_earliest], 
  orderheader.ord_dest_latestdate AS [dest_latest],
  orderheader.ord_schedulebatch AS [schedule_batch],
  company_shipper.cmp_id AS [ord_shipper],
  company_shipper.cmp_name AS [ord_shipper_name],
  company_consignee.cmp_id AS [ord_consignee],
  company_consignee.cmp_name AS [ord_consignee_name],
  orderheader.ord_billto,
  orderheader.ord_dest_zip,
  orderheader.ord_origin_zip,
  orderheader.ord_order_source,
  orderheader.ord_originregion2 ,
  orderheader.ord_originregion3 ,
  orderheader.ord_originregion4 ,
  orderheader.ord_destregion2,
  orderheader.ord_destregion3,
  orderheader.ord_destregion4,
  orderheader.ord_schedulebatch AS [ord_schedulebatch],
  orderheader.ord_origin_earliestdate AS [ord_origin_earliestdate],
  STUFF((SELECT',' + LTRIM(RTRIM(STR(lgh_number))) FROM legheader lh (NOLOCK) WHERE lh.mov_number = orderheader.mov_number FOR XML PATH('')), 1, 1, '') AS [lgh_number],
  company_d.cmp_state AS [billto_state],
  orderheader.ord_fromschedule,
  orderheader.ord_BelongsTo,
  orderheader.rowsec_rsrv_id AS [ord_rowsec_rsrv_id],
  stops.stp_schdtearliest AS [stp_schdtearliest],
  company_d.cmp_othertype1 AS [billto_cmp_othertype1],
  company_d.cmp_othertype2 AS [billto_cmp_othertype2],
  company_d.cmp_othertype3 AS [billto_cmp_othertype3],
  company_d.cmp_othertype4 AS [billto_cmp_othertype4],
  company_d.cmp_invoiceby AS [billto_invoiceby]
FROM orderheader (NOLOCK)
  JOIN company company_a (NOLOCK) ON (orderheader.ord_originpoint = company_a.cmp_id)  
  JOIN company company_b (NOLOCK) ON (orderheader.ord_destpoint = company_b.cmp_id)  
  JOIN company company_c (NOLOCK) ON (orderheader.ord_company = company_c.cmp_id)  
  JOIN company company_d (NOLOCK) ON (orderheader.ord_billto = company_d.cmp_id) 
  JOIN company company_shipper (NOLOCK) ON (orderheader.ord_shipper = company_shipper.cmp_id)
  JOIN company company_consignee (NOLOCK) ON (orderheader.ord_consignee = company_consignee.cmp_id)
  JOIN stops (NOLOCK) ON stops.ord_hdrnumber = orderheader.ord_hdrnumber and stops.stp_sequence = 1
  LEFT JOIN labelfile lblRevType1 (NOLOCK) ON lblRevType1.labeldefinition = 'RevType1' AND lblRevType1.abbr = orderheader.ord_revtype1
  LEFT JOIN labelfile lblRevType2 (NOLOCK) ON lblRevType2.labeldefinition = 'RevType2' AND lblRevType2.abbr = orderheader.ord_revtype2
  LEFT JOIN labelfile lblRevType3 (NOLOCK) ON lblRevType3.labeldefinition = 'RevType3' AND lblRevType3.abbr = orderheader.ord_revtype3
  LEFT JOIN labelfile lblRevType4 (NOLOCK) ON lblRevType4.labeldefinition = 'RevType4' AND lblRevType4.abbr = orderheader.ord_revtype4
  LEFT JOIN city origCity (NOLOCK) ON orderheader.ord_origincity = origCity.cty_code
  LEFT JOIN city destCity (NOLOCK) ON orderheader.ord_destcity = origCity.cty_code
WHERE orderheader.ord_status <> 'CAN' 
  AND orderheader.ord_invoicestatus = 'AVL' 
  AND EXISTS(SELECT 1 FROM NoTouchBillingConfiguration billToConfig (NOLOCK) WHERE billToConfig.AppliesToId IN ('UNKNOWN', orderheader.ord_billto) AND billToConfig.ntbTypeId = 1)
GO
GRANT DELETE ON  [dbo].[TMWScrollOrdersReadyForNoTouchBillingView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollOrdersReadyForNoTouchBillingView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollOrdersReadyForNoTouchBillingView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollOrdersReadyForNoTouchBillingView] TO [public]
GO
