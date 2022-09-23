SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollHoldOrdersView] AS

SELECT  DISTINCT orderheader.ord_number, 
	orderheader.ord_company as 'ord_company',
	company_a.cmp_id as 'origin_cmp_id', 
	company_a.cmp_name as 'origin_cmp_name', 
	company_b.cmp_id as 'dest_cmp_id', 
	company_b.cmp_name as 'dest_cmp_name', 
	company_c.cmp_id as 'orderby_cmp_id', 
	company_c.cmp_name as 'orderby_cmp_name', 
	company_c.cty_nmstct as 'orderby_cty_nmstct', 
	company_d.cmp_id as 'billto_cmp_id', 
	company_d.cmp_name as 'billto_cmp_name', 
	company_d.cty_nmstct as 'billto_cty_nmstct',
	(select name from labelfile where labeldefinition = 'DispStatus' and abbr = orderheader.ord_status) as 'ord_status_name', 
	orderheader.ord_startdate, 
	orderheader.ord_completiondate, 
	orderheader.ord_originstate, 
	orderheader.ord_deststate, 
	orderheader.ord_revtype1 as 'ord_revtype1', 
	(select name from labelfile where labeldefinition = 'RevType1' and abbr = orderheader.ord_revtype1) as 'ord_revtype1_name',
	orderheader.ord_revtype2 as 'ord_revtype2', 
	(select name from labelfile where labeldefinition = 'RevType2' and abbr = orderheader.ord_revtype2) as 'ord_revtype2_name',
	orderheader.ord_revtype3 as 'ord_revtype3', 
	(select name from labelfile where labeldefinition = 'RevType3' and abbr = orderheader.ord_revtype3) as 'ord_revtype3_name', 
	orderheader.ord_revtype4 as 'ord_revtype4', 
	(select name from labelfile where labeldefinition = 'RevType4' and abbr = orderheader.ord_revtype4) as 'ord_revtype4_name', 
	orderheader.mov_number, 
	orderheader.ord_charge, 
	orderheader.ord_totalcharge, 
	orderheader.ord_accessorial_chrg, 
	orderheader.ord_priority, 
	orderheader.ord_originregion1, 
	orderheader.ord_destregion1, 
	orderheader.ord_reftype, 
	orderheader.ord_refnum, 
	orderheader.ord_status as 'ord_status', 
	orderheader.ord_invoicestatus as 'ord_invoicestatus', 
	(select name from labelfile where labeldefinition = 'OrdInvStatus' and abbr = orderheader.ord_invoicestatus) as 'ord_invoicestatus_name', 
	(CASE company_a.cty_nmstct WHEN 'UNKNOWN' THEN city_a.cty_nmstct ELSE company_a.cty_nmstct  END) as 'origin_cty_nmstct', 
	(CASE company_b.cty_nmstct WHEN 'UNKNOWN' THEN city_b.cty_nmstct ELSE company_b.cty_nmstct END) as 'dest_cyt_nmstct', 
	orderheader.ord_origincity,
	orderheader.ord_destcity,
	orderheader.cmd_code as 'cmd_code',
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
	company_a.cmp_primaryphone as 'origin_cmp_primaryphone', 
	company_b.cmp_primaryphone as 'dest_cmp_primaryphone', 
	company_d.cmp_primaryphone as 'billto_cmp_primaryphone', 
	orderheader.ord_totalmiles, 
	orderheader.ord_carrier, 
	orderheader.ord_origin_earliestdate as 'origin_earliest', 
	orderheader.ord_origin_latestdate as 'origin_latest', 
	orderheader.ord_dest_earliestdate as 'dest_earliest', 
	orderheader.ord_dest_latestdate as 'dest_latest',
	orderheader.ord_schedulebatch as 'schedule_batch',
	orderheader.ord_shipper as 'ord_shipper',
	orderheader.ord_consignee as 'ord_consignee',
	orderheader.ord_billto as 'ord_billto',
	orderheader.ord_dest_zip as 'ord_dest_zip',
	orderheader.ord_origin_zip as 'ord_origin_zip',
	orderheader.ord_order_source as 'ord_order_source',
	orderheader.ord_originregion2 as 'ord_originregion2',
	orderheader.ord_originregion3 as 'ord_originregion3',
	orderheader.ord_originregion4 as 'ord_originregion4',
	orderheader.ord_destregion2 as 'ord_destregion2',
	orderheader.ord_destregion3 as 'ord_destregion3',
	orderheader.ord_destregion4 as 'ord_destregion4',
	orderheader.ord_schedulebatch as 'ord_schedulebatch',
	orderheader.ord_origin_earliestdate as 'ord_origin_earliestdate',
	leg.lgh_number as 'lgh_number',
 	company_d.cmp_state as 'billto_state',
 	orderhold.hld_id as 'hold_id',
	orderhold.ohld_active as 'active_hold',
 	orderholddefinition.hld_exception,
 	orderhold.ohld_id,
 	OrderHoldDefinition.hld_enddate,
 	OrderHoldDefinition.hld_startdate
FROM orderheader (nolock) 
	join OrderHold (nolock) on (orderheader.ord_hdrnumber = orderhold.ord_hdrnumber)
	join OrderHoldDefinition (nolock) on (orderhold.hld_id = OrderHoldDefinition.hld_id)
	join company company_a (nolock) on (orderheader.ord_originpoint = company_a.cmp_id)  
	join company company_b (nolock) on (orderheader.ord_destpoint = company_b.cmp_id)  
	join company company_c (nolock) on (orderheader.ord_company = company_c.cmp_id)  
	join company company_d (nolock) on (orderheader.ord_billto = company_d.cmp_id) 
	join city city_a (nolock) on (orderheader.ord_origincity = city_a.cty_code)  
	join city city_b (nolock) on (orderheader.ord_destcity = city_b.cty_code)
	left join legheader leg (nolock) on (orderheader.mov_number = leg.lgh_number)

GO
GRANT DELETE ON  [dbo].[TMWScrollHoldOrdersView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollHoldOrdersView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollHoldOrdersView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollHoldOrdersView] TO [public]
GO
