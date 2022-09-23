SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWPlanningShipmentsView]
AS
SELECT
		lh.lgh_number 'Id',
		'Trip' 'Type',
		'' Mode,
		(SELECT COUNT(*) FROM stops WHERE lgh_number=lh.lgh_number) AS 'Stops',
		lh.lgh_carrier 'Carrier',
		delv_city.cty_nmstct 'Delivery',
		s2.stp_schdtearliest DeliveryDateEarliest, 
		s2.stp_schdtlatest DeliveryDateLatest,
		c.cmd_name 'Commodity',
		(select SUM(fgt_count)
		from freightdetail
		where stp_number=s2.stp_number) 'Pallet', 
		(select SUM(fgt_volume)
		from freightdetail
		where stp_number=s2.stp_number) 'Cube',
		(select SUM(fgt_weight)
		from freightdetail
		where stp_number=s2.stp_number) 'Weight',
		pick_city.cty_nmstct 'Pickup',
		s1.stp_schdtearliest PickupDateEarliest, 
		s1.stp_schdtlatest PickupDateLatest,   
		(SELECT COUNT(*) FROM stops WHERE lgh_number=lh.lgh_number AND stp_type='PUP') AS 'Pickups',
		(SELECT COUNT(*) FROM stops WHERE lgh_number=lh.lgh_number AND stp_type='DRP') AS 'Deliveries'
FROM legheader_active lh
	inner join orderheader as o on o.ord_hdrnumber =  lh.ord_hdrnumber
	inner join stops as s1 on s1.ord_hdrnumber = o.ord_hdrnumber and s1.stp_number = lh.stp_number_start
	inner join stops as s2 on s2.ord_hdrnumber = o.ord_hdrnumber and s2.stp_number = lh.stp_number_end
	left join company pick on pick.cmp_id = s1.cmp_id
	left join city pick_city on pick_city.cty_code = s1.stp_city
	left join company delv on delv.cmp_id = s2.cmp_id 
	left join city delv_city on delv_city.cty_code = s2.stp_city
	left join commodity c on c.cmd_code = o.cmd_code
GO
GRANT SELECT ON  [dbo].[TMWPlanningShipmentsView] TO [public]
GO
