SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[AOETripView]
as 
select oh.ord_number as 'Order', lgh_outstatus as 'Status', 
	   lgh_startdate 'StartDate', ISNULL(fc.cmp_name, '') as 'Origin', fcy.cty_nmstct as 'Origin City/State',
	   lgh_enddate 'EndDate', ISNULL(lc.cmp_name, '') as 'Final', lcy.cty_nmstct as 'Final City/State',
       (select sum(stp_lgh_mileage) from stops where stops.lgh_number = la.lgh_number) as Mileage, la.ord_totalweight as Weight, oh.ord_totalcharge as Revenue, 
	   bc.cmp_name as 'Bill To',
	   la.ord_stopcount 'Stop Count', la.evt_driver1_name 'Driver', lgh_tractor as Tractor, la.lgh_primary_trailer as Trailer, la.lgh_carrier as Carrier, 
	   la.fgt_description as 'Commodity',
	   la.lgh_class1 as RevType1, la.lgh_class2 as RevType2, la.lgh_class3 as RevType3, la.lgh_class4 as RevType4,  
	   oh.ord_status as 'Order Status', la.mov_number as 'Move Number',lgh_number 'Leg Number',
	   oh.rowsec_rsrv_id as oh_rowsec_rsrv_id,
	   bc.cmp_othertype1, bc.cmp_othertype2
  from legheader_active la left outer join orderheader oh on (la.ord_hdrnumber = oh.ord_hdrnumber) 
						  join company pc on (oh.ord_shipper = pc.cmp_id)
						  join company cc on (oh.ord_consignee = cc.cmp_id)
						  join company fc on (la.cmp_id_start = fc.cmp_id)
						  join company bc on (oh.ord_billto = bc.cmp_id)
						  join city fcy on (la.lgh_startcity = fcy.cty_code)
						  join company lc on (la.cmp_id_end = lc.cmp_id)
						  join city lcy on (la.lgh_endcity = lcy.cty_code)
GO
GRANT INSERT ON  [dbo].[AOETripView] TO [public]
GO
GRANT SELECT ON  [dbo].[AOETripView] TO [public]
GO
GRANT UPDATE ON  [dbo].[AOETripView] TO [public]
GO
