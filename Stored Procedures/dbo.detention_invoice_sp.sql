SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[detention_invoice_sp] (	@ord_hdrnumber	int, 
						@det_mins int,
						@warning int OUTPUT)
as

DECLARE @cht_itemcode		varchar(6),
	@dumdate 		datetime, 
	@dummy6 		varchar(6), 
	@glnum 			varchar(20),
	@suffix			char(1),
	@fgt_number		int,
	@ivd_number		int, 
	@ivh_invoicenumber	varchar(12),
	@ivh_hdrnumber		int,
	@mov_number		int,
	@ord_number		varchar(12),
	@drv1 			varchar(8),
	@drv2 			varchar(8),
	@trc 			varchar(8),
	@trl 			varchar(13),
	@car			varchar(8), 
	@remarks		varchar(254), 
	@fill6			varchar(6),
	@ivd_sequence		int,
	@t1			char(1), 
	@t2			varchar(12)

select @fgt_number = null

select @warning = 0

if (select count(*) from orderheader where ord_hdrnumber = @ord_hdrnumber) = 0
begin
	select @warning = 1 -- non-existent order number
	Return @warning
end

Select @cht_itemcode = gi_string1 From generalInfo where gi_name = 'AutoDetentionChargeType'
If @cht_itemcode is null
begin
	select @warning = 2 -- no generalinfo setting defined
	Return @warning
end

if (select count(*) from chargetype WHERE chargetype.cht_itemcode = 'DT') < 1
begin
	select @warning = 3 -- chargetype pointed to by GI does not exist
	Return @warning
end

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
		@det_mins, 
		cht_rate, 
		0,  
		cht_taxtable1,
		cht_taxtable2, 
		cht_taxtable3, 
		cht_taxtable4,
		'MINS', 
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

Return @warning
GO
GRANT EXECUTE ON  [dbo].[detention_invoice_sp] TO [public]
GO
