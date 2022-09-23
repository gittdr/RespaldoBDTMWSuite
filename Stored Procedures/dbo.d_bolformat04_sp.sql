SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_bolformat04_sp] @ord_hdrnumber int
AS
/**
 * 
 * REVISION HISTORY:
 * 10/24/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE
@refcount	int,
@stopcount	int,
@x		int

select	oh.ord_hdrnumber,
	oh.ord_number,
	stops.stp_sequence,
	isNull((select shipper.cmp_name from company shipper where oh.ord_originpoint = shipper.cmp_id),'') 'shipper_cmp_name',
	isNull((select shipper.cmp_address1 from company shipper where oh.ord_originpoint = shipper.cmp_id),'') 'shipper_cmp_address1',
	isNull((select shipper.cmp_address2 from company shipper where oh.ord_originpoint = shipper.cmp_id),'') 'shipper_cmp_address2',
	isNull((select c1.cty_state from company, city c1 where oh.ord_originpoint = company.cmp_id and company.cmp_city = c1.cty_code),'') 'shipper_cmp_state',
	isNull((select c1.cty_name from company, city c1 where oh.ord_originpoint = company.cmp_id and company.cmp_city = c1.cty_code),'') 'shipper_cmp_city',
	isNull((select shipper.cmp_zip from company shipper where oh.ord_originpoint = shipper.cmp_id),'') 'shipper_cmp_zip',
	isNull((select shipper.cmp_primaryphone from company shipper where oh.ord_originpoint = shipper.cmp_id),'') 'shipper_cmp_primaryphone',
	isNull((select consignee.cmp_name from company consignee where oh.ord_destpoint = consignee.cmp_id),'') 'consignee_cmp_name',
	isNull((select consignee.cmp_address1 from company consignee where oh.ord_destpoint = consignee.cmp_id),'') 'consignee_cmp_address1',
	isNull((select consignee.cmp_address2 from company consignee where oh.ord_destpoint = consignee.cmp_id),'') 'consignee_cmp_address2',
	isNull((select c1.cty_state from company consignee, city c1 where oh.ord_destpoint = consignee.cmp_id and consignee.cmp_city = c1.cty_code),'') 'consignee_cmp_state',
	isNull((select c1.cty_name from company consignee, city c1 where oh.ord_destpoint = consignee.cmp_id and consignee.cmp_city = c1.cty_code),'') 'consignee_cmp_city',
	isNull((select consignee.cmp_zip from company consignee where oh.ord_destpoint = consignee.cmp_id),'') 'consignee_cmp_zip',
	isNull((select consignee.cmp_primaryphone from company consignee where oh.ord_destpoint = consignee.cmp_id),'') 'consignee_cmp_primaryphone',
	oh.ord_company,
	'' 'ordby_cmp_name',
	oh.ord_remark,
	oh.ord_distributor,
	oh.ord_revtype2,
	oh.ord_revtype4,
	oh.ord_driver1,
	oh.ord_tractor,
	oh.ord_trailer,
	oh.ord_startdate 'ship_date',
	isNull(oh.ord_cod_amount, 0) 'ord_code_amount',
	isNull((select cmd_name from commodity where cmd_code = stops.cmd_code),'None') 'commodity_desc',
	isNull(referencenumber.ref_type,'') 'ref_type',
	isNull(referencenumber.ref_number,'') 'ref_number',
	isNull(referencenumber.ref_table,'') 'ref_table',
	oh.ord_bookdate 'ord_bookdate',
	isNull(o_city.cty_name,'') 'origin_cityname',
	isNull(o_city.cty_state,'') 'origin_citystate',
	isNull(o_city.cty_zip,'') 'origin_cityzip',
	isNull(d_city.cty_name,'') 'dest_cityname',
	isNull(d_city.cty_state,'') 'dest_citystate',
	isNull(d_city.cty_zip,'') 'dest_cityzip',
	'detail_qty' = 
		Case
			when isNull(stops.stp_weight,0) > 0 then stops.stp_weight
			when isNull(stops.stp_volume,0) > 0 then stops.stp_volume
			when isNull(stops.stp_count,0) > 0 then stops.stp_count
			else 0
		End,
	--stp_count 'detail_qty',
	stops.stp_comment 'delivery_instuctions'
FROM  orderheader oh  LEFT OUTER JOIN  city d_city  ON  oh.ord_destcity  = d_city.cty_code   LEFT OUTER JOIN  city o_city  ON  oh.ord_origincity  = o_city.cty_code ,
	 stops,
	 eventcodetable evt,
	 referencenumber 
WHERE	 oh.mov_number  = stops.mov_number
 AND	oh.ord_hdrnumber  = @ord_hdrnumber
 AND	stops.stp_event  = evt.abbr
 AND	evt.fgt_event  = 'DRP'
 AND	stops.stp_number  = referencenumber.ref_tablekey
 AND	referencenumber.ref_table  = 'stops'

Union 
select	distinct oh.ord_hdrnumber,
	oh.ord_number,
	0,
	isNull((select shipper.cmp_name from company shipper where oh.ord_originpoint = shipper.cmp_id),'') 'shipper_cmp_name',
	isNull((select shipper.cmp_address1 from company shipper where oh.ord_originpoint = shipper.cmp_id),'') 'shipper_cmp_address1',
	isNull((select shipper.cmp_address2 from company shipper where oh.ord_originpoint = shipper.cmp_id),'') 'shipper_cmp_address2',
	isNull((select c1.cty_state from company, city c1 where oh.ord_originpoint = company.cmp_id and company.cmp_city = c1.cty_code),'') 'shipper_cmp_state',
	isNull((select c1.cty_name from company, city c1 where oh.ord_originpoint = company.cmp_id and company.cmp_city = c1.cty_code),'') 'shipper_cmp_city',
	isNull((select shipper.cmp_zip from company shipper where oh.ord_originpoint = shipper.cmp_id),'') 'shipper_cmp_zip',
	isNull((select shipper.cmp_primaryphone from company shipper where oh.ord_originpoint = shipper.cmp_id),'') 'shipper_cmp_primaryphone',
	isNull((select consignee.cmp_name from company consignee where oh.ord_destpoint = consignee.cmp_id),'') 'consignee_cmp_name',
	isNull((select consignee.cmp_address1 from company consignee where oh.ord_destpoint = consignee.cmp_id),'') 'consignee_cmp_address1',
	isNull((select consignee.cmp_address2 from company consignee where oh.ord_destpoint = consignee.cmp_id),'') 'consignee_cmp_address2',
	isNull((select c1.cty_state from company consignee, city c1 where oh.ord_destpoint = consignee.cmp_id and consignee.cmp_city = c1.cty_code),'') 'consignee_cmp_state',
	isNull((select c1.cty_name from company consignee, city c1 where oh.ord_destpoint = consignee.cmp_id and consignee.cmp_city = c1.cty_code),'') 'consignee_cmp_city',
	isNull((select consignee.cmp_zip from company consignee where oh.ord_destpoint = consignee.cmp_id),'') 'consignee_cmp_zip',
	isNull((select consignee.cmp_primaryphone from company consignee where oh.ord_destpoint = consignee.cmp_id),'') 'consignee_cmp_primaryphone',
	oh.ord_company,
	'' 'ordby_cmp_name',
	oh.ord_remark,
	oh.ord_distributor,
	oh.ord_revtype2,
	oh.ord_revtype4,
	oh.ord_driver1,
	oh.ord_tractor,
	oh.ord_trailer,
	oh.ord_startdate 'ship_date',
	isNull(oh.ord_cod_amount, 0) 'ord_code_amount',
	isNull((select cmd_name from commodity where cmd_code = oh.cmd_code),'None') 'commodity_desc',
	isNull(referencenumber.ref_type,'') 'ref_type',
	isNull(referencenumber.ref_number,'') 'ref_number',
	isNull(referencenumber.ref_table,'') 'ref_table',
	oh.ord_bookdate 'ord_bookdate',
	isNull(o_city.cty_name,'') 'origin_cityname',
	isNull(o_city.cty_state,'') 'origin_citystate',
	isNull(o_city.cty_zip,'') 'origin_cityzip',
	isNull(d_city.cty_name,'') 'dest_cityname',
	isNull(d_city.cty_state,'') 'dest_citystate',
	isNull(d_city.cty_zip,'') 'dest_cityzip',
	'detail_qty' = 
		Case
			when isNull(oh.ord_totalweight,0) > 0 then oh.ord_totalweight
			when isNull(oh.ord_totalvolume,0) > 0 then oh.ord_totalvolume
			when isNull(oh.ord_totalpieces,0) > 0 then oh.ord_totalpieces
			else 0
		End,
	--oh.ord_quantity 'detail_qty',
	isNull((select max(stp_comment) from stops where ord_hdrnumber = oh.ord_hdrnumber and stp_type = 'DRP'),'') 'delivery_instuctions'
FROM  orderheader oh  LEFT OUTER JOIN  referencenumber  ON  (oh.ord_hdrnumber  = referencenumber.ref_tablekey and referencenumber.ref_table  = 'orderheader') 
		LEFT OUTER JOIN  city d_city  ON  oh.ord_destcity  = d_city.cty_code   
		LEFT OUTER JOIN  city o_city  ON  oh.ord_origincity  = o_city.cty_code  
WHERE	 oh.ord_hdrnumber  = @ord_hdrnumber

Union
select	oh.ord_hdrnumber,
	oh.ord_number,
	stops.stp_sequence,
	isNull((select shipper.cmp_name from company shipper where oh.ord_originpoint = shipper.cmp_id),'') 'shipper_cmp_name',
	isNull((select shipper.cmp_address1 from company shipper where oh.ord_originpoint = shipper.cmp_id),'') 'shipper_cmp_address1',
	isNull((select shipper.cmp_address2 from company shipper where oh.ord_originpoint = shipper.cmp_id),'') 'shipper_cmp_address2',
	isNull((select c1.cty_state from company, city c1 where oh.ord_originpoint = company.cmp_id and company.cmp_city = c1.cty_code),'') 'shipper_cmp_state',
	isNull((select c1.cty_name from company, city c1 where oh.ord_originpoint = company.cmp_id and company.cmp_city = c1.cty_code),'') 'shipper_cmp_city',
	isNull((select shipper.cmp_zip from company shipper where oh.ord_originpoint = shipper.cmp_id),'') 'shipper_cmp_zip',
	isNull((select shipper.cmp_primaryphone from company shipper where oh.ord_originpoint = shipper.cmp_id),'') 'shipper_cmp_primaryphone',
	isNull((select consignee.cmp_name from company consignee where oh.ord_destpoint = consignee.cmp_id),'') 'consignee_cmp_name',
	isNull((select consignee.cmp_address1 from company consignee where oh.ord_destpoint = consignee.cmp_id),'') 'consignee_cmp_address1',
	isNull((select consignee.cmp_address2 from company consignee where oh.ord_destpoint = consignee.cmp_id),'') 'consignee_cmp_address2',
	isNull((select c1.cty_state from company consignee, city c1 where oh.ord_destpoint = consignee.cmp_id and consignee.cmp_city = c1.cty_code),'') 'consignee_cmp_state',
	isNull((select c1.cty_name from company consignee, city c1 where oh.ord_destpoint = consignee.cmp_id and consignee.cmp_city = c1.cty_code),'') 'consignee_cmp_city',
	isNull((select consignee.cmp_zip from company consignee where oh.ord_destpoint = consignee.cmp_id),'') 'consignee_cmp_zip',
	isNull((select consignee.cmp_primaryphone from company consignee where oh.ord_destpoint = consignee.cmp_id),'') 'consignee_cmp_primaryphone',
	oh.ord_company,
	'' 'ordby_cmp_name',
	oh.ord_remark,
	oh.ord_distributor,
	oh.ord_revtype2,
	oh.ord_revtype4,
	oh.ord_driver1,
	oh.ord_tractor,
	oh.ord_trailer,
	oh.ord_startdate 'ship_date',
	isNull(oh.ord_cod_amount, 0) 'ord_code_amount',
	isNull((select cmd_name from commodity where cmd_code = fd.cmd_code),'None') 'commodity_desc',
	referencenumber.ref_type 'ref_type',
	referencenumber.ref_number 'ref_number',
	referencenumber.ref_table,
	oh.ord_bookdate 'ord_bookdate',
	isNull(o_city.cty_name,'') 'origin_cityname',
	isNull(o_city.cty_state,'') 'origin_citystate',
	isNull(o_city.cty_zip,'') 'origin_cityzip',
	isNull(d_city.cty_name,'') 'dest_cityname',
	isNull(d_city.cty_state,'') 'dest_citystate',
	isNull(d_city.cty_zip,'') 'dest_cityzip',
	'detail_qty' = 
		Case
			when isNull(fd.fgt_weight,0) > 0 then fd.fgt_weight
			when isNull(fd.fgt_volume,0) > 0 then fd.fgt_volume
			when isNull(fd.fgt_count,0) > 0 then fd.fgt_count
			else 0
		End,
	--isNull(fd.fgt_weight,0) + isNull(fd.fgt_volume,0) + isNull(fd.fgt_count,0) 'detail_qty ',
	stops.stp_comment 'delivery_instuctions'
FROM  orderheader oh  LEFT OUTER JOIN  city d_city  ON  oh.ord_destcity  = d_city.cty_code   LEFT OUTER JOIN  city o_city  ON  oh.ord_origincity  = o_city.cty_code ,
	 stops,
	 eventcodetable evt,
	 referencenumber,
	 freightdetail fd 
WHERE	 oh.mov_number  = stops.mov_number
 AND	oh.ord_hdrnumber  = @ord_hdrnumber
 AND	stops.stp_number  = fd.stp_number
 AND	stops.stp_event  = evt.abbr
 AND	evt.fgt_event  = 'DRP'
 AND	fd.fgt_number  = referencenumber.ref_tablekey
 AND	referencenumber.ref_table  = 'freightdetail'
GO
GRANT EXECUTE ON  [dbo].[d_bolformat04_sp] TO [public]
GO
