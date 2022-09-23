SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[trlrental_invoice_sp] (	@ord_hdrnumber	int, 
											@cht_itemcode varchar(6),
											@warning int OUTPUT)
as

DECLARE 	@dumdate 			datetime, 
			@dummy6 			varchar(6), 
			@glnum 				varchar(20),
			@suffix				char(1),
			@fgt_number			int,
			@ivd_number			int, 
			@ivh_invoicenumber	varchar(12),
			@ivh_hdrnumber		int,
			@mov_number			int,
			@ord_number			varchar(12),
			@drv1 				varchar(8),
	       	@drv2 				varchar(8),
			@trc 				varchar(8),
			@trl 				varchar(13),
			@car				varchar(8), 
			@remarks            varchar(254), 
			@fill6              varchar(6),
			@ivd_sequence		int,
			@t1					char(1), 
			@t2	varchar(12)

select @fgt_number = null

select @warning = 0

if (select count(*) from orderheader where ord_hdrnumber = @ord_hdrnumber) = 0
begin
	select @warning = 1
	Return @warning
end

if (select count(*) from chargetype where cht_itemcode = @cht_itemcode) = 0
begin
	select @warning = 2
	Return @warning
end

if (select count(*) from invoicedetail where ord_hdrnumber = @ord_hdrnumber and 
											cht_itemcode = @cht_itemcode) > 0
begin
	select @warning = 3
	Return @warning
end
else
begin
	EXEC @ivd_number = getsystemnumber 'INVDET', ''  

	select @ivd_sequence = max(ivd_sequence) from invoicedetail where ord_hdrnumber = @ord_hdrnumber
	If @ivd_sequence < 1 or @ivd_sequence is NULL
		select @ivd_sequence = 998
	select @ivd_sequence = @ivd_sequence + 1

	select @ord_number = ord_number,
			@mov_number = mov_number
	from orderheader 
	where ord_hdrnumber = @ord_hdrnumber

	insert  into invoicedetail 
		(ivh_hdrnumber, 
		ivd_number,
--		stp_number, 
		ivd_description,
		cht_itemcode,
		ivd_quantity, 
		ivd_rate, 
		ivd_charge,  
		ivd_taxable1,
		ivd_taxable2, 
		ivd_taxable3, 
		ivd_taxable4,
		ivd_unit, 
		cur_code, 
		ivd_currencydate, 
		ivd_glnum, 	
		ord_hdrnumber, 
		ivd_type, 
		ivd_rateunit, 
		ivd_billto, 
		ivd_itemquantity, 
		ivd_subtotalptr, 	
--ivd_allocatedrev,
		ivd_sequence,
		ivd_invoicestatus,
--		mfh_hdrnumber,
--		ivd_refnum,
		cmd_code,
		cmp_id, 
		ivd_distance,
	 	ivd_distunit, 
		ivd_wgt, 
		ivd_wgtunit, 
		ivd_count, 
		ivd_countunit,
--		evt_number, 
		ivd_reftype,
		ivd_volume, 
		ivd_volunit, 
--		ivd_orig_cmpid,
--ivd_payrevenue,
		ivd_sign,
--		ivd_length, 
--		ivd_lengthunit, 
--		ivd_width, 
--		ivd_widthunit, 	
--		ivd_height,
--		ivd_heightunit, 
		cht_basisunit,
		ivd_remark,
		tar_number,
		tar_tariffnumber,
		tar_tariffitem,
--		ivd_fromord,
--ivd_zipcode,
--		ivd_quantity_type,
		cht_class,
--		ivd_mileagetable,
		ivd_trl_rent,
		ivd_trl_rent_start,
		ivd_trl_rent_end,
		cht_lh_min,
		cht_lh_stl,
		cht_lh_prn,
		cht_lh_rpt,    
		cht_lh_rev,
		cht_rollintolh)
--		fgt_number)

 	SELECT 
		0 ivh_hdrnumber, 
		@ivd_number,
--		stops.stp_number, 
		cht_description,
		cht_itemcode,
		cht_quantity, 
		cht_rate, 
		0,  
		cht_taxtable1,
		cht_taxtable2, 
		cht_taxtable3, 
		cht_taxtable4,
		cht_unit, 
		@dummy6, 
		@dumdate, 
		@glnum, 	
		@ord_hdrnumber, 
		'LI', 
		cht_rateunit, 
		@dummy6 , 
		0, 
		0, 	
--ivd_allocatedrev,
		@ivd_sequence, 			--ivd_sequence,
		@dummy6 , 		--ivd_invoicestatus,
--		@mov_number, 				--mfh_hdrnumber,
--		stops.stp_refnum, 				--ivd_refnum
		'UNKNOWN',
		'UNKNOWN',
		0,
	 	'MIL', 
		0 , 
		'LBS', 
		0, 
		'PCS',
--		event.evt_number, 
		'REF',  				--ivd_reftype,
		0, 
		'CUB', 
--		stops.cmp_id , 	--ivd_orig_cmpid,
--ivd_payrevenue,
		1,
--		0, 
--		' ', 
--		0, 
--		' ', 	
--		0,
--		' ', 
		cht_basisunit,
		'' ,
		0 ,
		'',
		'',
--		' ',							--ivd_fromord,
--ivd_zipcode,
--		0,
		'',
--		'',								--ivd_mileagetable,
		'',								--ivd_trl_rent,
		@dumdate,
		@dumdate,
		chargetype.cht_lh_min,
		chargetype.cht_lh_stl,
		chargetype.cht_lh_prn,
		chargetype.cht_lh_rpt,    
		chargetype.cht_lh_rev,
		chargetype.cht_rollintolh
--		@fgt_number
	FROM 	chargetype
   	WHERE	chargetype.cht_itemcode = @cht_itemcode
END

if (select count(*) from invoiceheader where ord_hdrnumber = @ord_hdrnumber) > 0
begin
	EXEC @ivh_hdrnumber = getsystemnumber 'INVHDR', ''   

	update invoicedetail 
	set ivh_hdrnumber = @ivh_hdrnumber
	where ord_hdrnumber = @ord_hdrnumber and cht_itemcode = @cht_itemcode

	select @ivh_invoicenumber = max(ivh_invoicenumber) 
	from invoiceheader 
	where ord_hdrnumber = @ord_hdrnumber

	select @drv1 = evt_driver1,
	       	@drv2 = evt_driver2,
			@trc = evt_tractor,
			@trl = evt_trailer1,
			@car = evt_carrier
	FROM event e, stops s, eventcodetable ec
	WHERE e.stp_number = s.stp_number and s.mov_number = @mov_number and 
			e.evt_eventcode = ec.abbr and ect_billable = 'Y' and 
			stp_lgh_mileage = (select  max(stp_lgh_mileage)
									from event e, eventcodetable ec, stops s
									where mov_number = @mov_number and 
											s.stp_number = e.stp_number and 
											e.evt_eventcode = ec.abbr and 
											ect_billable = 'Y')

	select @suffix = right(@ivh_invoicenumber,1)
	select @t1 = char((ASCII(@suffix) + 1))
	select @ivh_invoicenumber = (rtrim(@ord_number) + @t1)

	 INSERT into invoiceheader (ivh_invoicenumber, 
		ivh_billto,
		ivh_terms, 
		ivh_totalcharge,    
		ivh_shipper, 
		ivh_consignee, 
		ivh_originpoint,   
		ivh_destpoint, 
		ivh_invoicestatus, 
		ivh_origincity,     
		ivh_destcity, 
		ivh_originstate, 
		ivh_deststate,      
		ivh_originregion1, 
		ivh_destregion1, 
		ivh_supplier,       
		ivh_shipdate, 
		ivh_deliverydate, 
		ivh_revtype1,       
		ivh_revtype2, 
		ivh_revtype3, 
		ivh_revtype4, 
		ivh_totalweight, 
		ivh_totalpieces, 
		ivh_totalmiles,     
		ivh_currency,
		ivh_currencydate, 
		ivh_totalvolume,    
		ivh_taxamount1, 
		ivh_taxamount2,       
		ivh_taxamount3, 
		ivh_taxamount4,
		ivh_transtype,
		ivh_creditmemo,     
		ivh_applyto,
--		shp_hdrnumber,
--		ivh_printdate, 
		ivh_billdate, 
--		ivh_lastprintdate,   
		ivh_hdrnumber,
		ord_hdrnumber, 
		ivh_originregion2,  
		ivh_originregion3, 
		ivh_originregion4, 
		ivh_destregion2,    
		ivh_destregion3, 
		ivh_destregion4, 
--		mfh_hdrnumber,
		ivh_remark,
		ivh_driver, 
		ivh_tractor,
		ivh_trailer, 
		ivh_user_id1,
--		ivh_user_id2,
		ivh_ref_number,
		ivh_driver2, 
		mov_number, 
--		ivh_edi_flag,
		ivh_freight_miles,
		ivh_priority, 
		ivh_low_temp, 
		ivh_high_temp,
--		ivh_xferdate
		ivh_order_by,
		tar_tarriffnumber, 
		tar_number, 
		ivh_bookyear,
		ivh_bookmonth,
		tar_tariffitem, 
--		ivh_maxlength,
--		ivh_maxwidth,
--		ivh_maxheight,
		ivh_mbstatus,
		ivh_mbnumber,
		ord_number, 
		ivh_quantity, 
		ivh_rate, 
		ivh_charge, 
		cht_itemcode, 
		ivh_splitbill_flag,
		ivh_company,
		ivh_carrier,
		ivh_archarge,
		ivh_arcurrency,
		ivh_loadtime,
		ivh_unloadtime,
		ivh_drivetime,
		ivh_totaltime,
		ivh_rateby,
--		ivh_revenue_date,			
--		ivh_batch_id,			
		ivh_stopoffs,
		ivh_quantity_type,
		ivh_charge_type, 
        ivh_originzipcode, 
        ivh_destzipcode,
		ivh_ratingquantity,
		ivh_ratingunit,
		ivh_unit,
		ivh_hideshipperaddr,
		ivh_hideconsignaddr,
		ivh_paperworkstatus,
		ivh_definition,
		ivh_showshipper,
		ivh_showcons,
		ivh_applyto_definition,
		ivh_order_cmd_code,
		ivh_paperwork_override,
		ivh_attention)

	   SELECT @ivh_invoicenumber, 
		o.ord_billto,
		o.ord_terms, 
		o.ord_totalcharge,    
		o.ord_shipper, 
		o.ord_consignee, 
		o.ord_originpoint,   
		o.ord_destpoint, 
		'HLD', 
		o.ord_origincity,     
		o.ord_destcity, 
		o.ord_originstate, 
		o.ord_deststate,      
		o.ord_originregion1, 
		o.ord_destregion1, 
		o.ord_supplier,       
		o.ord_startdate, 
		o.ord_completiondate, 
		o.ord_revtype1,       
		o.ord_revtype2, 
		o.ord_revtype3, 
		o.ord_revtype4, 
		o.ord_totalweight, 
		o.ord_totalpieces, 
		o.ord_totalmiles,     
		ISNULL(o.ord_currency, 'US$'),
		o.ord_currencydate, 
		o.ord_totalvolume,    
		0, 
		0,       
		0, 
		0,
		@fill6,
		'N',  				--ivh_creditmemo   
		@ivh_invoicenumber, 		-- applyto
--shp_hdrnumber
--		@dummydate, 
		getdate(), 
--		@dummydate,   
--		0, 
		@ivh_hdrnumber,
		o.ord_hdrnumber, 
		o.ord_originregion2,  
		o.ord_originregion3, 
		o.ord_originregion4, 
		o.ord_destregion2,    
		o.ord_destregion3, 
		o.ord_destregion4, 
--mfh_hdrnumber
		@remarks, 		--ivh_remark
		@drv1,			--o.ord_driver1, 
		@trc,			--o.ord_tractor,
		@trl,			--o.ord_trailer, 
		CURRENT_USER,	--ivh_user_id1,
--		ivh_user_id2,
		o.ord_refnum,	--ivh_ref_number,
		@drv2,			--o.ord_driver2, 
		o.mov_number, 
--ivh_edi_flag
		o.ord_odmetermiles, 	--ivh_freight_miles
		o.ord_priority, 
		o.ord_lowtemp, 
		o.ord_hitemp,
--ivh_xferdate
		o.ord_company, 			--ivh_order_by
		o.tar_tarriffnumber, 
		o.tar_number, 
		0, 						--ivh_bookyear
		0, 						--ivh_bokkmonth
		o.tar_tariffitem, 
--ivh_maxlength
--ivh_maxwidth
--ivh_maxheight
		@fill6, 				--ivh_mbstatus
		0,						--ivh_mbnumber
		o.ord_number, 
		o.ord_quantity, 
		o.ord_rate, 
		o.ord_charge, 
		o.cht_itemcode, 
		'N', 					--ivh_splitbill_flag
		o.ord_subcompany,
		@car,				--ivh_carrier
		0,						--ivh_archarge
		'',						--ivh_arcurrency
		o.ord_loadtime,
		o.ord_unloadtime,
		o.ord_drivetime,
		0,						--ivh_totaltime
		o.ord_rateby,
--ivh_revenue_date
--ivh_batch_id
		0,							--ivh_stopoffs
		ISNULL(o.ord_quantity_type,0),
		ISNULL(o.ord_charge_type,0), 
        ISNULL((SELECT cmp_zip FROM company WHERE cmp_id = o.ord_shipper), ''), 
        ISNULL((SELECT cmp_zip FROM company WHERE cmp_id = o.ord_consignee), '') ,
		ISNULL(o.ord_ratingquantity,ord_quantity),
		ISNULL(o.ord_ratingunit,ord_unit),
		o.ord_unit,
		o.ord_hideshipperaddr,
		o.ord_hideconsignaddr,
		'UNK',				--ivh_paperworkstatus
		'SUPL',				--ivh_definition
		CASE
    		WHEN o.ord_showshipper = 'UNKNOWN' THEN o.ord_shipper
	        ELSE o.ord_showshipper
		END,
		CASE
    		WHEN o.ord_showcons = 'UNKNOWN' THEN o.ord_consignee
	        ELSE o.ord_showcons
		END,
		'SUPL',				--ivh_applyto_definition
		o.cmd_code,			--ivh_order_cmd_code
		'',					--ivh_paperwork_override
		''					--ivh_attention
	   FROM orderheader o
	   WHERE o.ord_hdrnumber = @ord_hdrnumber
end

Return @warning
GO
GRANT EXECUTE ON  [dbo].[trlrental_invoice_sp] TO [public]
GO
