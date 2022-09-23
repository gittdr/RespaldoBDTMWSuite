SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec [SSRS_RB_OrderSummary]650
--exec SSRS_RB_OrderSummary 42650

create  Procedure [dbo].[SSRS_RB_OrderSummary]
		
		@ord_hdrnumber int
	 
AS

SELECT	orderheader.ord_number,
orderheader.ord_revtype1,
orderheader.ord_hdrnumber,
orderheader.ord_contact,
orderheader.ord_originpoint,
orderheader.ord_destpoint, orderheader.ord_billto,
orderheader.ord_reftype,
orderheader.ord_refnum,
orderheader.ord_quantity,
orderheader.ord_totalcharge,
orderheader.ord_charge,
orderheader.ord_accessorial_chrg,
orderheader.ord_remark,
orderheader.ord_bookedby,
(select name from labelfile  with(nolock) where abbr = orderheader.trl_type1 and labeldefinition = 'TrlType1' )'trl_type1',
(select name from labelfile  with(nolock) where abbr = orderheader.ord_revtype2 and labeldefinition = 'Revtype2' ) 'Salesman',
orderheader.ord_shipper 'Shipper ID',

Case when Shipper.cmp_name = 'UNKNOWN'
then ''
else Shipper.cmp_name 
end as ' Shipper Name',
Shipper.cmp_address1 'Shipper Address1',
Shipper.cmp_address2 'Shipper Address2',
Case when Shipper.cmp_name = 'UNKNOWN'
then  (select cty_name from city cu  with(nolock)  where cu.cty_code = orderheader.ord_origincity)
else Shipper_city.cty_name 
end as 'Shipper City',
Case  when Shipper.cmp_name = 'UNKNOWN'
then ord_originstate
else Shipper.cmp_State 
end as ' Shipper State',
Shipper.cmp_zip ' Shipper Zip',
orderheader.ord_consignee 'Consingee ID',
Case when Consignee.cmp_name = 'UNKNOWN'
then '' 
else Consignee.cmp_name
end as  ' Consignee Name',
Consignee.cmp_address1 'Consignee Address1',
Consignee.cmp_address2 'Consignee Address2',
Case 
when Consignee.cmp_name = 'UNKNOWN' then (select cty_name from city cu  with(nolock)  where cu.cty_code = orderheader.ord_destcity)
else Consignee_city.cty_name 
end as 'Consignee City',
Case 
when Consignee.cmp_name = 'UNKNOWN' then ord_deststate
else Consignee.cmp_State 
end as ' Consignee State',
Consignee.cmp_zip ' Consignee Zip',
company_a.cmp_name 'o_cmp_name',
company_a.cmp_address1 'o_cmp_address1',
company_a.cmp_address2 'o_cmp_address2',
Case when stops.cmp_id = 'UNKNOWN' then (select cty_name from city cu  with(nolock)  where cu.cty_code = stops.stp_city)
Else
(select cty_name from city CA  with(nolock)  where company_a.cmp_city = CA.cty_code)
end as 'o_cmp_city',
--IsNull(convert(varchar, company_a.cmp_city), origin_city.cty_name) 'o_cmp_city',
Case when stops.cmp_id = 'UNKNOWN' then stops.stp_state
else
IsNull(company_a.cmp_state, origin_city.cty_state)
end as 'o_cmp_state',
(CASE company_a.cmp_zip WHEN '00000' THEN origin_city.cty_zip ELSE company_a.cmp_zip END) 'o_cmp_zip',
(CASE company_a.cty_nmstct WHEN 'UNKNOWN' THEN origin_city.cty_nmstct ELSE company_a.cty_nmstct END) 'o_cty_nmstct',
company_b.cmp_name 'd_cmp_name',
company_b.cmp_address1 'd_cmp_address1',
company_b.cmp_address2 'd_cmp_address2',
Case when stops.cmp_id = 'UNKNOWN' then (select cty_name from city cu (nolock) where cu.cty_code = stops.stp_city)
Else
(select cty_name from city CB  with(nolock)  where company_b.cmp_city = CB.cty_code) 
End as 'D_cmp_city',
--IsNull(convert(varchar, company_b.cmp_city), destination_city.cty_name) 'd_cmp_city',
Case when stops.cmp_id = 'UNKNOWN' then stops.stp_state
else
IsNull(company_b.cmp_state, destination_city.cty_state)
end as 'd_cmp_state',
(CASE company_b.cmp_zip WHEN '00000' THEN destination_city.cty_zip ELSE company_b.cmp_zip END) 'd_cmp_zip',
(CASE company_b.cty_nmstct WHEN 'UNKNOWN' THEN destination_city.cty_nmstct ELSE company_b.cty_nmstct END) 'd_cty_nmstct',
company_c.cmp_name 'b_cmp_name',
company_c.cmp_address1 'b_cmp_address1',
company_c.cmp_address2 'b_cmp_address2',
billto_city.cty_name 'b_cmp_city',
company_c.cmp_state 'b_cmp_state',
company_c.cmp_zip 'b_cmp_zip',
company_c.cty_nmstct 'b_cty_nmstct',
Case stops.stp_type
	when 'PUP' then 'Pickup'
	when 'DRP' then 'Drop'
	else stops.stp_type
	end as 'stp_type',
stops.stp_number,
stops.cmp_id,
stops.stp_description,
stops.stp_arrivaldate,
--commodity.cmd_code,
----dbo.fcn_Commodities_CRLF(orderheader.ord_hdrnumber,stops.stp_number) as 'cmd_name',
--freightdetail.fgt_description,
--freightdetail.fgt_reftype,
--freightdetail.fgt_refnum,
--freightdetail.fgt_quantity,
--freightdetail.fgt_unit,
--freightdetail.fgt_sequence,
--freightdetail.fgt_weight, 
--freightdetail.fgt_weightunit,
--freightdetail.fgt_count,
--freightdetail.fgt_countunit,
--freightdetail.fgt_volume,
--freightdetail.fgt_volumeunit,
'' 'company_name',
stops.stp_lgh_mileage,
0.00 'accessorial_charge',
stops_city.cty_nmstct 'stop_city',
stops.stp_ord_mileage 
FROM orderheader with (nolock)	
join stops  with (nolock)	 on orderheader.ord_hdrnumber = stops.ord_hdrnumber	
join city  	 origin_city with (nolock)on orderheader.ord_origincity = origin_city.cty_code
join city   destination_city with (nolock)	on orderheader.ord_destcity = destination_city.cty_code
join city 	 stops_city with (nolock)on stops.stp_city = stops_city.cty_code
--join freightdetail with (nolock)	 on stops.stp_number = freightdetail.stp_number
--join commodity with (nolock)	 on freightdetail.cmd_code = commodity.cmd_code
left outer join company company_a with (nolock) on orderheader.ord_originpoint = company_a.cmp_id
left outer join company company_b with (nolock) on orderheader.ord_destpoint = company_b.cmp_id
left outer join company company_c with (nolock) on orderheader.ord_billto = company_c.cmp_id
left outer join city billto_city with (nolock) on billto_city.cty_code = company_c.cmp_city
left outer join company Shipper with (nolock) on  orderheader.ord_Shipper = Shipper.cmp_id
left outer join city Shipper_city with (nolock) on Shipper.cmp_city = Shipper_city.cty_code
left outer join company  Consignee with (nolock) on orderheader.ord_Consignee = Consignee.cmp_id
left outer join city Consignee_city with (nolock)       on Consignee.cmp_city = Consignee_city.cty_code

WHERE (orderheader.ord_hdrnumber = @ord_hdrnumber) ORDER BY	stops.stp_sequence
--,freightdetail.fgt_sequence

GO
