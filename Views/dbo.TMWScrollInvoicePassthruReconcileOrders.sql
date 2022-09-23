SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWScrollInvoicePassthruReconcileOrders]
AS

SELECT DISTINCT orderheader.ord_number, 
	orderheader.ord_company AS 'ord_company',
	company_a.cmp_id AS 'origin_cmp_id', 
	company_a.cmp_name AS 'origin_cmp_name', 
	company_b.cmp_id AS 'dest_cmp_id', 
	company_b.cmp_name AS 'dest_cmp_name', 
	company_c.cmp_id AS 'orderby_cmp_id', 
	company_c.cmp_name AS 'orderby_cmp_name', 
	company_c.cty_nmstct AS 'orderby_cty_nmstct', 
	company_d.cmp_id AS 'billto_cmp_id', 
	company_d.cmp_name AS 'billto_cmp_name', 
	company_d.cty_nmstct AS 'billto_cty_nmstct',
	(SELECT name FROM labelfile WHERE labeldefinition = 'DispStatus' AND abbr = orderheader.ord_status) AS 'ord_status_name', 
	orderheader.ord_startdate, 
	orderheader.ord_completiondate, 
	orderheader.ord_originstate, 
	orderheader.ord_deststate, 
	orderheader.ord_revtype1 AS 'ord_revtype1', 
	(SELECT name FROM labelfile WHERE labeldefinition = 'RevType1' AND abbr = orderheader.ord_revtype1) AS 'ord_revtype1_name',
	orderheader.ord_revtype2 AS 'ord_revtype2', 
	(SELECT name FROM labelfile WHERE labeldefinition = 'RevType2' AND abbr = orderheader.ord_revtype2) AS 'ord_revtype2_name',
	orderheader.ord_revtype3 AS 'ord_revtype3', 
	(SELECT name FROM labelfile WHERE labeldefinition = 'RevType3' AND abbr = orderheader.ord_revtype3) AS 'ord_revtype3_name', 
	orderheader.ord_revtype4 AS 'ord_revtype4', 
	(SELECT name FROM labelfile WHERE labeldefinition = 'RevType4' AND abbr = orderheader.ord_revtype4) AS 'ord_revtype4_name', 
	orderheader.mov_number, 
	orderheader.ord_charge, 
	orderheader.ord_totalcharge, 
	orderheader.ord_accessorial_chrg, 
	orderheader.ord_priority, 
	orderheader.ord_originregion1, 
	orderheader.ord_destregion1, 
	orderheader.ord_reftype, 
	orderheader.ord_refnum, 
	orderheader.ord_status AS 'ord_status', 
	orderheader.ord_invoicestatus AS 'ord_invoicestatus', 
	(SELECT name FROM labelfile WHERE labeldefinition = 'OrdInvStatus' AND abbr = orderheader.ord_invoicestatus) AS 'ord_invoicestatus_name', 
	(CASE company_a.cty_nmstct WHEN 'UNKNOWN' THEN city_a.cty_nmstct ELSE company_a.cty_nmstct  END) AS 'origin_cty_nmstct', 
	(CASE company_b.cty_nmstct WHEN 'UNKNOWN' THEN city_b.cty_nmstct ELSE company_b.cty_nmstct END) AS 'dest_cyt_nmstct', 
	orderheader.ord_origincity,
	orderheader.ord_destcity,
	orderheader.cmd_code AS 'cmd_code',
	orderheader.ord_description, 
	orderheader.ord_remark, 
	orderheader.ord_hdrnumber, 
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
	company_a.cmp_primaryphone AS 'origin_cmp_primaryphone', 
	company_b.cmp_primaryphone AS 'dest_cmp_primaryphone', 
	company_d.cmp_primaryphone AS 'billto_cmp_primaryphone', 
	orderheader.ord_totalmiles, 
	orderheader.ord_carrier, 
	ISNULL(orderheader.ord_trailer2, '') AS 'ord_trailer2', 
	ISNULL(leg.lgh_trailer3, '') AS 'lgh_trailer3', 
	ISNULL(leg.lgh_trailer4, '') AS 'lgh_trailer4', 
	ISNULL(leg.lgh_chassis, '') AS 'lgh_chassis', 
	ISNULL(leg.lgh_chassis2, '') AS 'lgh_chassis2', 
	ISNULL(leg.lgh_dolly, '') AS 'lgh_dolly', 
	ISNULL(leg.lgh_dolly2, '') AS 'lgh_dolly2', 
	orderheader.ord_chassis AS 'ord_chassis', 
	orderheader.ord_chassis2 AS 'ord_chassis2', 
	orderheader.ord_origin_earliestdate AS 'origin_earliest', 
	orderheader.ord_origin_latestdate AS 'origin_latest', 
	orderheader.ord_dest_earliestdate AS 'dest_earliest', 
	orderheader.ord_dest_latestdate AS 'dest_latest',
	orderheader.ord_schedulebatch AS 'schedule_batch',
	orderheader.ord_shipper AS 'ord_shipper',
	orderheader.ord_consignee AS 'ord_consignee',
	orderheader.ord_billto AS 'ord_billto',
	orderheader.ord_dest_zip AS 'ord_dest_zip',
	orderheader.ord_origin_zip AS 'ord_origin_zip',
	orderheader.ord_order_source AS 'ord_order_source',
	orderheader.ord_originregion2 AS 'ord_originregion2',
	orderheader.ord_originregion3 AS 'ord_originregion3',
	orderheader.ord_originregion4 AS 'ord_originregion4',
	orderheader.ord_destregion2 AS 'ord_destregion2',
	orderheader.ord_destregion3 AS 'ord_destregion3',
	orderheader.ord_destregion4 AS 'ord_destregion4',
	orderheader.ord_schedulebatch AS 'ord_schedulebatch',
	orderheader.ord_origin_earliestdate AS 'ord_origin_earliestdate',
	leg.lgh_number AS 'lgh_number',
 	company_d.cmp_state AS 'billto_state',
	orderheader.ord_fromschedule AS 'ord_fromschedule',
	orderheader.ord_BelongsTo AS 'ord_belongsto',
	orderheader.rowsec_rsrv_id AS 'ord_rowsec_rsrv_id',
	orderheader.ord_fromorder AS 'ord_fromorder',
	orderheader.ord_datepromised,
	orderheader.ord_job_remaining
FROM orderheader (NOLOCK)
  INNER JOIN TMWTPLBillPostSettlementsView ON TMWTPLBillPostSettlementsView.ord_hdrnumber = orderheader.ord_hdrnumber
	JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('orderheader', NULL) rsva ON (orderheader.rowsec_rsrv_id = rsva.rowsec_rsrv_id OR rsva.rowsec_rsrv_id = 0) 
	JOIN company company_a (NOLOCK) ON (orderheader.ord_originpoint = company_a.cmp_id)  
	JOIN company company_b (NOLOCK) ON (orderheader.ord_destpoint = company_b.cmp_id)  
	JOIN company company_c (NOLOCK) ON (orderheader.ord_company = company_c.cmp_id)  
	JOIN company company_d (NOLOCK) ON (orderheader.ord_billto = company_d.cmp_id) 
	JOIN city city_a (NOLOCK) ON (orderheader.ord_origincity = city_a.cty_code)  
	JOIN city city_b (NOLOCK) ON (orderheader.ord_destcity = city_b.cty_code)
	LEFT JOIN legheader leg (NOLOCK) ON (orderheader.mov_number = leg.mov_number)

GO
GRANT DELETE ON  [dbo].[TMWScrollInvoicePassthruReconcileOrders] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollInvoicePassthruReconcileOrders] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollInvoicePassthruReconcileOrders] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollInvoicePassthruReconcileOrders] TO [public]
GO
