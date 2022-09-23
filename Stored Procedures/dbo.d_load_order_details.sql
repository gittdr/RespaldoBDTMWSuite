SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_load_order_details    Script Date: 6/1/99 11:54:50 AM ******/
create PROC [dbo].[d_load_order_details] @p_order_number int  as 

DECLARE 	@dumdate 		datetime, 
			@dummy1			varchar(1),
			@dummy3 			varchar(3), 
			@dummy6 			varchar(6), 
			@dummy8 			varchar(8), 
			@glnum 			varchar(20), 	
			@description	varchar(30),
			@addl_pickup	varchar(20),
			@minseq	int

/*SELECT @minseq = ( SELECT MIN ( stp_sequence ) FROM stops WHERE ord_hdrnumber = @p_order_number ) */
SELECT distinct 0 ivh_hdrnumber, 
	0 ivd_number, 
	freightdetail.fgt_description ivd_description, 
	0 ivd_quantity, 
	0 ivd_rate, 
	0 ivd_charge, 	 
	"" ivd_taxable1, 
	"" ivd_taxable2, 
	"" ivd_taxable3, 
	"" ivd_taxable4, 
	@dummy6 ivd_unit, 	
	@dummy6 cur_code, 
	@dumdate currencydate, 
	@glnum ivd_glnum, 
	stops.ord_hdrnumber, 	
	stops.stp_type, 
	@dummy6 shp_rateunit, 
	@dummy6 shp_billto, 
	0 ivd_itemquantity, 	
	0 ivd_subtotalptr, 
	stops.stp_sequence, 
	@dummy6 shp_invoicestatus, 
	stops.mfh_number, 	
	stops.stp_refnum, 
	stops.cmp_id, 
	stops.stp_ord_mileage ivd_distance, 
	'MIL' ivd_distunit, 
	stops.stp_weight ivd_wgt, 
	stops.stp_weightunit ivd_wgtunit, 
	stops.stp_count ivd_count, 
	event.evt_number, 
	stops.stp_reftype, 
	0 ivd_volume, 
	"" ivd_volunit, 
	stops.cmp_id,                      
	stops.stp_countunit ivd_countunit, 
	@dummy6 cht_itemcode, 	
	freightdetail.cmd_code, 
	@dummy6 cht_basis, 
	freightdetail.fgt_lowtemp, 
	freightdetail.fgt_hitemp, 
	1 ivd_sign , 
	freightdetail.fgt_length ivd_length , 
	freightdetail.fgt_lengthunit ivd_lengthunit , 
	freightdetail.fgt_width ivd_width , 
	freightdetail.fgt_widthunit ivd_widthunit , 
	freightdetail.fgt_height ivd_height , 
	freightdetail.fgt_heightunit ivd_heightunit,
	"Y"  cht_primary,
	stops.stp_number  
FROM  freightdetail,  stops, event
WHERE stops.ord_hdrnumber = @p_order_number		
		AND ( stops.stp_number = event.stp_number ) 
		AND ( freightdetail.stp_number = stops.stp_number  )
		AND ( stops.stp_sequence > ( SELECT MIN ( stp_sequence ) 
											 FROM stops WHERE ord_hdrnumber = @p_order_number ) )
		AND ( event.evt_sequence = 1 )
 





GO
GRANT EXECUTE ON  [dbo].[d_load_order_details] TO [public]
GO
