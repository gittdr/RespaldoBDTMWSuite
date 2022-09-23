SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[alk_fc_orders] AS

SELECT DISTINCT
	ord_number or_order
	, ord_startdate or_ship_date
	, ord_origin_latestdate or_ship_ltst
	, o_cmp.cmp_name or_orig_comp
	, o_cty.cty_name or_orig_city
	, o_cty.cty_state or_orig_st
	, o_cmp.cmp_zip or_orig_zip
	, ord_completiondate or_delv_date
	, ord_dest_latestdate or_delv_ltst
	, d_cmp.cmp_name or_dest_comp 
	, d_cty.cty_name or_dest_city
	, d_cty.cty_state or_dest_st
	, d_cmp.cmp_zip or_dest_zip
	, ord_revtype1 or_revtype1
	, ord_revtype2 or_revtype2
	, ord_revtype3 or_revtype3
	, ord_revtype4 or_revtype4
	, ord_totalweight or_Weight
	, ord_totalweightunits or_WeightUnit
	, ord_totalpieces or_count
	, ord_totalcountunits or_CountUnit
	, ord_totalvolume or_Volume
	, ord_totalvolumeunits or_VolumeUnit
	, orderheader.trl_type1 or_trlrtyp
	, orderheader.cmd_code or_prod_code
	, ord_description or_prod_desc
	, ord_status or_sts
	, ord_billto or_client
	, ord_refnum or_bill
	, lgh_tractor or_unit
	, legheader.lgh_number or_tripid
FROM	orderheader
	, city o_cty
	, company o_cmp
	, city d_cty
	, company d_cmp
	, legheader
WHERE	o_cty.cty_code = orderheader.ord_origincity
  AND	o_cmp.cmp_id = orderheader.ord_originpoint
  AND	d_cty.cty_code = orderheader.ord_destcity
  AND	d_cmp.cmp_id = orderheader.ord_destpoint
  AND 	legheader.mov_number = orderheader.mov_number
GO
GRANT DELETE ON  [dbo].[alk_fc_orders] TO [public]
GO
GRANT INSERT ON  [dbo].[alk_fc_orders] TO [public]
GO
GRANT REFERENCES ON  [dbo].[alk_fc_orders] TO [public]
GO
GRANT SELECT ON  [dbo].[alk_fc_orders] TO [public]
GO
GRANT UPDATE ON  [dbo].[alk_fc_orders] TO [public]
GO
