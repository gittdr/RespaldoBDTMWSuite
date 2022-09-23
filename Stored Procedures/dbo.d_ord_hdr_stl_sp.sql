SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
-- dpdte pts6733 add ord_fromorder to orderheader to keep track of ord copied from
-- dsk pts 9374 2000/11/15 add stops table join to find orders that have been cross docked
--DPETE PTS15367 add ord_stlquantity etc to return set
-- DPETE PTS28947 return zips for origin and dest companies
CREATE PROCEDURE [dbo].[d_ord_hdr_stl_sp] (@pl_movenum int)
AS
DECLARE	@char10		char(10),
			@count_ref		int,
			@count_req		int,
			@ord_notes		int,
			@comp_notes	int,
			@c_drops		int,
			@ref_count		int,
			@load_req		int,
			@orig_datetime1		datetime,
			@orig_datetime2		datetime,
			@dest_datetime1		datetime,
			@dest_datetime2		datetime,
			@work_quantity		float(15),
			@work_unit		varchar(6),
			@work_accessorial       money,
			@settlement_status 	varchar(6)	
			/* KM	notes enhancement	*/
/*			@notes_count 		int,
			@n_ord_hdrnumber	int,
			@driver1	varchar(8),   
			@driver2	varchar(8),   
			@tractor	varchar(8),   
			@trailer1	varchar(13),
			@trailer2	varchar(13),
			@carrier	varchar(8),
			@origin_cmpid	varchar(8),
			@dest_cmpid	varchar(8),
			@billto_cmpid	varchar(8),
			@mov_number	int
*/
			/* KM	notes enhancement end */

SELECT DISTINCT orderheader.ord_number,   
         orderheader.ord_status,   
         orderheader.ord_invoicestatus,   
         orderheader.ord_revtype1,   
         orderheader.ord_bookedby,   
         orderheader.ord_subcompany,   
         orderheader.ord_company,   
         orderheader.ord_contact,   
         orderheader.ord_customer,   
         orderheader.ord_originpoint,   
         o_city.cty_nmstct,   
         orderheader.ord_destpoint,   
         d_city.cty_nmstct,   
         orderheader.ord_bookdate,   
         orderheader.ord_startdate,   
         orderheader.ord_completiondate,   
         orderheader.ord_billto,   
         orderheader.ord_reftype,   
         orderheader.ord_refnum,   
         orderheader.ord_priority,   
         orderheader.ord_revtype2,   
         orderheader.ord_revtype3,   
         orderheader.ord_revtype4,   
         orderheader.ord_totalweight,   
         orderheader.ord_totalmiles,   
         orderheader.ord_totalpieces,   
         orderheader.ord_length,   
         orderheader.ord_lengthunit,   
         orderheader.ord_width,   
         orderheader.ord_widthunit,   
         orderheader.ord_height,   
         orderheader.ord_heightunit,   
         orderheader.ord_lowtemp,   -- replaced by ord_mintemp below pts 6643  
         orderheader.ord_hitemp,    -- replaced by ord_maxtemp below pts6643 
         orderheader.trl_type1,   
         orderheader.tar_tarriffnumber,   
         orderheader.tar_tariffitem,   
         orderheader.ord_quantity,   
         orderheader.ord_rate,   
         orderheader.ord_charge,   
         orderheader.ord_rateunit,   
         orderheader.ord_unit,   
         orderheader.ord_remark,   
         orderheader.ord_trailer,   
         orderheader.ord_tractor,   
         orderheader.ord_driver2,   
         orderheader.ord_driver1,   
         orderheader.ord_showcons,   
         orderheader.ord_showshipper,   
         orderheader.mov_number,   
         orderheader.mfh_hdrnumber,   
         orderheader.ord_pu_at,   
         orderheader.ord_dr_at,   
         orderheader.ord_shipper,   
         orderheader.ord_consignee,   
         orderheader.ord_hdrnumber,   
         orderheader.ord_currency,   
         orderheader.ord_currencydate,   
         orderheader.ord_supplier,   
         orderheader.ord_destcity,   
         orderheader.ord_origincity,   
         orderheader.cmd_code,   
         orderheader.ord_description,   
         orderheader.ord_terms,   
         orderheader.cht_itemcode,  
 		  'RevType1' revtype1 ,
	 	  'RevType2' revtype2 ,
	 	  'RevType3' revtype3 ,
	 	  'RevType4' revtype4,
		  'TrlType1' trltype1,
         orderheader.ord_origin_earliestdate,   
         orderheader.ord_origin_latestdate,   
         orderheader.ord_odmetermiles,   
         orderheader.ord_stopcount,   
         orderheader.ord_dest_earliestdate,   
         orderheader.ord_dest_latestdate,   
         orderheader.ref_sid,   
         orderheader.ref_pickup,   
         orderheader.ord_cmdvalue,            orderheader.ord_accessorial_chrg,   
         orderheader.ord_totalcharge,   
         orderheader.ord_availabledate,   
		  @c_drops c_drops,
         orderheader.ord_totalvolume,   
         orderheader.ord_miscqty,   
         @char10 ord_mscqty1_t,
	 	  @ref_count ref_count, 
		  @ord_notes count_notes,
		  @load_req load_req,
		  orderheader.ord_tempunits,
		  orderheader.ord_totalweightunits,   
        orderheader.ord_totalvolumeunits,   
        orderheader.ord_totalcountunits,
        orderheader.ord_datetaken  ,
	orderheader.ord_loadtime,
	orderheader.ord_unloadtime,
	orderheader.ord_drivetime,
	orderheader.ord_rateby,
	ordby.cmp_name,
	ordby.cty_nmstct,
	orig.cmp_name,
	dest.cmp_name,
	billto.cmp_name,
	billto.cty_nmstct,
	@orig_datetime1 orig_datetime1,
	@orig_datetime2 orig_datetime2,
	@dest_datetime1 dest_datetime1,
	@dest_datetime2 dest_datetime2,
	@work_quantity work_quantity,
	@work_unit work_unit,
	orderheader.ord_quantity_type,
	orderheader.tar_number,
	@work_accessorial, 
	orderheader.ord_thirdpartytype1, 
	orderheader.ord_thirdpartytype2,
	'TprType1' ord_thirdpartytype1_t,
	'TprType2' ord_thirdpartytype2_t,
	@settlement_status settlement_status,
	orderheader.ord_charge_type,
              orderheader.ord_fromorder ,
              orderheader.ord_mintemp,
              orderheader.ord_maxtemp,
	orderheader.ord_distributor,
        orderheader.ord_revenue_pay_fix,
        orderheader.ord_revenue_pay,
	Isnull(ord_stlquantity,0),
	IsNull(ord_stlunit,'MIL'),
	ISNULL(ord_stlquantity_type,0)
    ,originzip = IsNull(orig.cmp_zip,'')
    ,destzip = IsNull(dest.cmp_zip,'')
	,ord_route
	,ord_ratemode		/* 11/18/2011 NQIAO PTS 58978 */
	,ord_servicelevel	/* 11/18/2011 NQIAO PTS 58978 */
	,ord_servicedays	/* 11/18/2011 NQIAO PTS 58978 */
FROM orderheader
     left outer join company ordby on orderheader.ord_company = ordby.cmp_id
     left outer join company orig on orderheader.ord_originpoint = orig.cmp_id
     left outer join company dest on orderheader.ord_destpoint = dest.cmp_id
     left outer join company billto on orderheader.ord_billto = billto.cmp_id
     left outer join city d_city on orderheader.ord_destcity = d_city.cty_code
     left outer join city o_city on orderheader.ord_origincity =  o_city.cty_code
     join stops on stops.ord_hdrnumber = orderheader.ord_hdrnumber
WHERE 	stops.mov_number = @pl_movenum 
--	stops.ord_hdrnumber = orderheader.ord_hdrnumber AND
--	orderheader.mov_number = @pl_movenum AND
--      orderheader.ord_billto *= billto.cmp_id AND
--      orderheader.ord_originpoint *= orig.cmp_id AND
--	orderheader.ord_destpoint *= dest.cmp_id AND
--      orderheader.ord_company *= ordby.cmp_id AND
--	orderheader.ord_destcity *= d_city.cty_code AND
--      orderheader.ord_origincity *= o_city.cty_code



GO
GRANT EXECUTE ON  [dbo].[d_ord_hdr_stl_sp] TO [public]
GO
