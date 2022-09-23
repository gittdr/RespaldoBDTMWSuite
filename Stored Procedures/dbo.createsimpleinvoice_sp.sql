SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[createsimpleinvoice_sp] (@pl_ordhdrnumber int, @ps_invoicestatus varchar(6) ) 
as
/**
 * 
 * REVISION HISTORY:
 * 10/23/2007.01 - PTS40012 - JGUO - convert convert old style outer join syntax to ansi outer join syntax.
 *
 **/
declare @li_count	int,
	@li_invoicehdrnumber int,
	@li_invoicedtlnumber int,
	@li_subtotptr int,
	@li_seq	int,
	@ls_ordhdrnumber varchar(25),
	@ls_rateby char(1),
	@calcmaxstat		varchar(6), 
	@dummydate              datetime, 
	@remarks                varchar(254), 
	@fill6                  varchar(6), 
	@fill3                  varchar(3), 
	@fill13                 varchar(13),    
	@fill8                  varchar(8),     
	@fill20                 varchar(20), 
	@edi                    varchar(30), 
	@invnum                 varchar(12), 
	@comments_count         int,
	@notes_count            int,
	@loadreq_count          int,
	@ref_count              int,
	@pwork_req_count        int,
	@pwork_rec_count        int,
	@lgh_count		int, 
	@vchar6			varchar(6),
	@ish_status		char(3),
	@min_date		int,
	@billto_altid		varchar(8),
	@ivh_revenue_date 	datetime,
	@ivh_batch_id		varchar(10),
	@first_invoice_number	varchar(12),
	@first_origin		varchar(8),
	@first_dest		varchar(8),
	@first_billto		varchar(8),
	@dummy6			varchar(6),
	@ctynmstct		varchar(25),
	@dumdate 		datetime,
	@ctycode		int ,
	@suffix			varchar(6),
	@glnum 			varchar(20),
	@sDummyRefType  	varchar(6),
	@sDummyRefNum		varchar(30),
	@bAllowAccessorialOnly  int

SELECT @bAllowAccessorialOnly = 0
if IsNull(@pl_ordhdrnumber ,0 ) < 0
begin
	SELECT @bAllowAccessorialOnly = 1
	SELECT @pl_ordhdrnumber = -@pl_ordhdrnumber
end

if IsNull(@pl_ordhdrnumber ,0 ) <= 0
begin
	select -1,'Order Number must be greater than 0'
	return -1
end

if not exists (select * from orderheader where ord_hdrnumber = @pl_ordhdrnumber)
begin
	select -1,'This order does not exist in the orderheader table'
	return -1
end	

if @bAllowAccessorialOnly <> 0
begin
	if (select ord_totalcharge from orderheader where ord_hdrnumber = @pl_ordhdrnumber) <= 0
	begin
		select -1,'This Order needs to be prerated in Order Entry'
		return -1
	end
end
else
begin
	if (select ord_charge from orderheader where ord_hdrnumber = @pl_ordhdrnumber) <= 0
	begin
		select -1,'This Order needs to be prerated in order entry'
		return -1
	end
end

if exists (select * from invoiceheader where ord_hdrnumber = @pl_ordhdrnumber) 
begin
	select -1,'This Order has already been invoiced'
	return -1
end

select @ls_ordhdrnumber = convert(varchar(25),@pl_ordhdrnumber)
select @ls_rateby = ord_rateby from orderheader where ord_hdrnumber = @pl_ordhdrnumber

create table #invhdr (
	ivh_invoicenumber char(12) null, 
	ivh_billto char(8) null,
	ivh_terms char(3) null, 
	ivh_totalcharge money null,    
	ivh_shipper char(8) null, 
	ivh_consignee char(8) null, 
	ivh_originpoint char(8) null,    
	ivh_destpoint char(8) null, 
	ivh_invoicestatus char(6) null, 
	ivh_origincity int null,     
	ivh_destcity int null, 
	ivh_originstate char(2) null, 
	ivh_deststate char(2) null,      
	ivh_originregion1 char(6) null, 
	ivh_destregion1 char(6) null, 
	ivh_supplier char(8) null,       
	ivh_shipdate datetime null, 
	ivh_deliverydate datetime null, 
	ivh_revtype1 char(6) null,       
	ivh_revtype2 char(6) null, 
	ivh_revtype3 char(6) null, 
	ivh_revtype4 char(6) null, 
	ivh_totalweight float(15)  null, 
	ivh_totalpieces float(15) null, 
	ivh_totalmiles float(15) null,     
	ivh_currency char(6) null,
	ivh_currencydate datetime null, 
	ivh_totalvolume float(15) null,    
	ivh_taxamount1 money null, 
	ivh_taxamount2 money null,       
	ivh_taxamount3 money null, 
	ivh_taxamount4 money null,
	ivh_transtype char(6) null,
	ivh_creditmemo char(1) null,     
	ivh_applyto char(12) null, 
	ivh_printdate datetime null, 
	ivh_billdate datetime null, 
	ivh_lastprintdate datetime null,   
	ivh_hdrnumber int null, 
	ord_hdrnumber int null, 
	ivh_originregion2 char(6) null,  
	ivh_originregion3 char(6) null, 
	ivh_originregion4 char(6) null, 
	ivh_destregion2 char(6) null,    
	ivh_destregion3 char(6) null, 
	ivh_destregion4 char(6) null, 
	ivh_mbnumber int null, 
	ivh_remark char(254) null, 
	ivh_driver char(8) null, 
	ivh_driver2 char(8) null, 
	ivh_tractor char(8) null,
	ivh_trailer char(13) null, 
	mov_number int null, 
	ivh_edi_flag char(30) null,
	revtype1 char(8) null, 
	revtype2 char(8) null, 
	revtype3 char(8) null, 
	revtype4 char(8) null, 
	ivh_freight_miles int null, 
	ivh_priority char(6),
	ivh_low_temp int null,
	ivh_high_temp int null,
	events_count int null,
	comments_count int null,
	notes_count int null,
	loadreq_count int null,
	ref_count int null,
	paperwork_required int null,
	paperwork_received int null,
	ivh_order_by char(8) null,
	tar_tarriffnumber char(12) null, 
	tar_number int null, 
	ivh_user_id1 char(20) null, 
	ivh_user_id2 char(20) null, 
	ivh_ref_number char(30) null,
	invoiceheader_ivh_bookyear int null,
	invoiceheader_ivh_bookmonth int null,
	tar_tariffitem char(12) null,
	ivh_mbstatus char(6) null,
	calc_maxstatus char(6) null,
	ord_number char(12) null,
	ivh_quantity float(15) null,
	ivh_rate money  null, 
	ivh_charge money null,
	cht_itemcode char(6) null,
	ivh_splitbill_flag char(1) null,
	dummy_ordstatus char(6) null,
	ivh_company char(6) null,
	ivh_carrier char(8) null,
	ivh_archarge money null,
	ivh_arcurrency char(6) null,
	ivh_loadtime int null,
	ivh_unloadtime int null,
	ivh_drivetime int null,
	ivh_totaltime int null,
	ivh_rateby char(1) null,
	ivh_unit char(6) null,
	ivh_rateunit char(6) null,
	lgh_count int NULL,
	ord_remark char(254) null,
	billto_altid	varchar(8) null,
	ivh_revenue_date datetime null,
	ivh_batch_id	varchar(10) null,
	mailto_flag char(1) null,
	ivh_stopoffs smallint null,
	ivh_quantity_type smallint null,
	ivh_charge_type smallint null)

create table #invdetail (
		ivh_hdrnumber		int	null, 
		ivd_number		int	not null, 
		ivd_description		varchar(30)	null, 
		ivd_quantity		float(15)	null, 
		ivd_rate		money	null, 
		ivd_charge		money	null, 
		ivd_taxable1		char(1)	null, 
		ivd_taxable2		char(1)	null, 
		ivd_taxable3		char(1)	null, 
		ivd_taxable4		char(1)	null, 
		ivd_unit		char(6)	null, 
		cur_code		char(6)	null, 
		ivd_currencydate	datetime	null, 
		ivd_glnum		char(20)	null, 
		ord_hdrnumber		int	null, 
		ivd_type		char(6)	null, 
		ivd_rateunit		char(6)	null, 
		ivd_billto		char(8)	null, 
		ivd_itemquantity	float(15)	null, 
		ivd_subtotalptr		int	null, 
		ivd_sequence		int	null, 
		ivd_invoicestatus	varchar(6)	null, 
		mfh_hdrnumber		int	null, 
		ivd_refnum		varchar(30)	null, 
		cmp_id			varchar(8)	null, 
		ivd_distance		float	null, 
		ivd_distunit		varchar(6)	null, 
		ivd_wgt			float(15)	null, 
		ivd_wgtunit		varchar(6)	null, 
		ivd_count			float(15)	null, 
		evt_number		int	null, 
		ivd_reftype		varchar(6)	null, 
		ivd_volume		float(15)	null, 
		ivd_volunit		char(6)	null, 
		ivd_orig_cmpid		char(8)	null, 
		ivd_countunit		char(6)	null, 
		cht_itemcode		char(6)	null, 
		cmd_code		varchar(8)	null, 
		cht_basis		varchar(6)	null,	 
		lowtemp			smallint	null, 	 
		hightemp		smallint	null, 
		ivd_sign		smallint	null, 
		ivd_length		money	null, 
		ivd_lengthunit		char(6)	null, 
		ivd_width		money	null, 
		ivd_widthunit		char(6)	null, 
		ivd_height		money	null, 
		ivd_heightunit		char(6)	null,
		cht_primary		char(1)	null, 
		stp_number		int 	null,
		cht_basisunit		varchar(6)	null,
		ivd_remark		varchar(255)	null,
		tar_number		int	null,
		tar_tariffnumber	varchar(12)	null,
		tar_tariffitem		varchar(12)	null,
		ivh_billto		varchar(8)	null,
		suffix_prefix		char(1)	null,
		ivd_fromord		char(1) null,
                cht_rollintolh          int     null,
		cty_nmstct		varchar(25) null,
		stp_city		int null ,
		origin_city		int null) 



-- Insert Data into the header temp table
	 INSERT into #invhdr
	   SELECT @invnum invoice_number, 
		o.ord_billto,
		o.ord_terms terms , 
		o.ord_totalcharge,    
		o.ord_shipper, 
		o.ord_consignee, 
		o.ord_originpoint,   
		o.ord_destpoint, 
		@ps_invoicestatus, 
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
		ISNULL(o.ord_currency, 'CAN$'),
		o.ord_currencydate, 
		o.ord_totalvolume,    
		0, 
		0,       
		0, 
		0,
		@fill6,
		'N',     
		@invnum, 
		@dummydate, 
		getdate(), 
		@dummydate,   
		0, 
		o.ord_hdrnumber, 
		o.ord_originregion2,  
		o.ord_originregion3, 
		o.ord_originregion4, 
		o.ord_destregion2,    
		o.ord_destregion3, 
		o.ord_destregion4, 
		0, 
		@remarks, 
		o.ord_driver1, 
		o.ord_driver2, 
		o.ord_tractor,
		o.ord_trailer, 
		o.mov_number, 
		@edi, 
		'RevType1', 
		'RevType2', 
		'RevType3', 
		'RevType4', 
		o.ord_odmetermiles, 
		o.ord_priority, 
		o.ord_lowtemp, 
		o.ord_hitemp,
		0,

		comments_count =
		  CASE o.ord_remark
		     WHEN Null THEN 0
		     WHEN '' THEN 0
		     ELSE 1
		  END,
		@notes_count,
		@loadreq_count,
		@ref_count,
		@pwork_req_count,
		@pwork_rec_count,
		o.ord_company, 
		o.tar_tarriffnumber, 
		o.tar_number, 
		@fill20, 
		@fill20, 
		ord_refnum, 
		0, 
		0, 
		o.tar_tariffitem, 
		@fill6, 
		@fill6, 
		o.ord_number, 
		o.ord_quantity, 
		o.ord_rate, 
		o.ord_charge, 
		o.cht_itemcode, 
		'N', 
		o.ord_status,
		left(o.ord_subcompany, 6),
		@fill8,
		0,
		'',
		o.ord_loadtime,
		o.ord_unloadtime,
		o.ord_drivetime,
		0,
		o.ord_rateby ivh_rateby,
		o.ord_unit ivh_unit,
		o.ord_rateunit ivh_rateunit,
		@lgh_count,
		o.ord_remark,
		@billto_altid,
		@ivh_revenue_date,
		@ivh_batch_id,
		'N',
		0,
		ISNULL(o.ord_quantity_type,0),
		ISNULL(o.ord_charge_type,0)
	   FROM orderheader o
	   WHERE o.ord_hdrnumber = @pl_ordhdrnumber 
	  	 and ord_invoicestatus = 'AVL'	
		 AND o.ord_hdrnumber > 0
	
	
	update #invhdr set ivh_terms = Case ivh_billto when ivh_shipper then 'PPD' 
					when ivh_consignee then 'COL'
					end
	where ivh_terms = 'UNK'
		
   if exists ( select * from generalinfo where gi_name = 'INVREFNUM' and gi_string1 = 'FREIGHT')
	INSERT INTO #invdetail
 	SELECT distinct 
		0 ivh_hdrnumber, 
		0 ivd_number,
		ISNULL(freightdetail.fgt_description,'UNKNOWN') ivd_description, 
		ISNULL(freightdetail.fgt_quantity,0) ivd_quantity, 
		ISNULL(freightdetail.fgt_rate,0.0) ivd_rate, 
		ISNULL(freightdetail.fgt_charge,0.0) ivd_charge,  
		commodity.cmd_taxtable1 ivd_taxable1,
		commodity.cmd_taxtable2 ivd_taxable2, 
		commodity.cmd_taxtable3 ivd_taxable3, 
		commodity.cmd_taxtable4 ivd_taxable4, 
		ISNULL(freightdetail.fgt_unit,'LBS') ivd_unit, 
		@dummy6 cur_code, 
		@dumdate currencydate, 
		@glnum ivd_glnum, 	
		stops.ord_hdrnumber, 
		stops.stp_type, 
		ISNULL(freightdetail.fgt_rateunit,'UNK') shp_rateunit, 
		@dummy6 shp_billto, 
		0 ivd_itemquantity, 
		0 ivd_subtotalptr, 	
		stops.stp_sequence, 	
		@dummy6 shp_invoicestatus, 
		stops.mfh_number, 
		freightdetail.fgt_refnum, 
		stops.cmp_id, 
		stops.stp_ord_mileage ivd_distance,
	 	'MIL' ivd_distunit, 
		ISNULL(freightdetail.fgt_weight,0) ivd_wgt, 
		ISNULL(freightdetail.fgt_weightunit,'LBS') ivd_wgtunit, 
		ISNULL(freightdetail.fgt_count,0) ivd_count, 
		event.evt_number, 
		freightdetail.fgt_reftype, 
		ISNULL(freightdetail.fgt_volume,0) ivd_volume, 
		ISNULL(freightdetail.fgt_volumeunit,'CUB') ivd_volunit, 
		stops.cmp_id shp_originpoint, 
		ISNULL(freightdetail.fgt_countunit,'PCS') ivd_countunit, 
                ISNULL(freightdetail.cht_itemcode, 'UNK') cht_itemcode,
		ISNULL(freightdetail.cmd_code,'UNKNOWN') cmd_code, 
		'DEL' cht_basis, 
		freightdetail.fgt_lowtemp, 
		freightdetail.fgt_hitemp, 
		1 ivd_sign,
		freightdetail.fgt_length ivd_length, 
		freightdetail.fgt_lengthunit ivd_lengthunit, 
		freightdetail.fgt_width ivd_width, 
		freightdetail.fgt_widthunit ivd_widthunit, 	
		freightdetail.fgt_height ivd_height,
		freightdetail.fgt_heightunit ivd_heightunit, 
		'Y' cht_primary,	
		stops.stp_number, 
		ISNULL(freightdetail.cht_basisunit,'UNK') cht_basisunit,
		'' ivd_remark,
		0 tar_number,
		'' tar_tariffnumber,
		'' tar_tariffitem,
		' ',
		' ',
		' ', 
                0 cht_rollintolh,
		@ctynmstct cty_nmstct,
		@ctycode stp_city,
		@ctycode origin_city
FROM  stops  LEFT OUTER JOIN  commodity  ON  (stops.cmd_code  = commodity.cmd_code) ,
	 freightdetail,
	 event,
	 eventcodetable 
WHERE	 stops.ord_hdrnumber  = @pl_ordhdrnumber
 AND	(stops.stp_number  = event.stp_number)
 AND	(freightdetail.stp_number  = stops.stp_number)
 AND	(event.evt_eventcode  = eventcodetable.abbr)
 AND	(eventcodetable.ect_billable  = 'Y')
 AND	(stops.stp_sequence  >
	(
 	SELECT MIN(stp_sequence)
	FROM  stops,
		 eventcodetable 
	WHERE	 ord_hdrnumber  = @pl_ordhdrnumber
	 AND	stp_event  = abbr
	 AND	ect_billable  = 'Y'
	))
 AND	(event.evt_sequence  = 1)

	UNION
	SELECT invoicedetail.ivh_hdrnumber, 

		invoicedetail.ivd_number, 
		invoicedetail.ivd_description, 
		invoicedetail.ivd_quantity, 
		invoicedetail.ivd_rate, 
		invoicedetail.ivd_charge, 
		invoicedetail.ivd_taxable1, 
		invoicedetail.ivd_taxable2, 
		invoicedetail.ivd_taxable3, 
		invoicedetail.ivd_taxable4, 
		invoicedetail.ivd_unit, 
		invoicedetail.cur_code, 
		invoicedetail.ivd_currencydate, 
		invoicedetail.ivd_glnum, 
		invoicedetail.ord_hdrnumber, 
		invoicedetail.ivd_type, 
		invoicedetail.ivd_rateunit, 
		invoicedetail.ivd_billto, 
		invoicedetail.ivd_itemquantity, 
		invoicedetail.ivd_subtotalptr, 
		invoicedetail.ivd_sequence, 
		invoicedetail.ivd_invoicestatus, 
		invoicedetail.mfh_hdrnumber, 
		invoicedetail.ivd_refnum, 
		invoicedetail.cmp_id, 
		invoicedetail.ivd_distance, 
		invoicedetail.ivd_distunit, 
		invoicedetail.ivd_wgt, 
		invoicedetail.ivd_wgtunit, 
		invoicedetail.ivd_count, 
		invoicedetail.evt_number, 
		invoicedetail.ivd_reftype, 
		invoicedetail.ivd_volume, 
		invoicedetail.ivd_volunit, 
		invoicedetail.ivd_orig_cmpid, 
		invoicedetail.ivd_countunit, 
		invoicedetail.cht_itemcode, 
		invoicedetail.cmd_code, 
		chargetype.cht_basis,	 
		0 lowtemp, 	 
		0 hightemp, 
		invoicedetail.ivd_sign, 
		invoicedetail.ivd_length, 
		invoicedetail.ivd_lengthunit, 
		invoicedetail.ivd_width, 
		invoicedetail.ivd_widthunit, 
		invoicedetail.ivd_height, 
		invoicedetail.ivd_heightunit ,
		chargetype.cht_primary, 
		invoicedetail.stp_number,
		invoicedetail.cht_basisunit,
		invoicedetail.ivd_remark,
		invoicedetail.tar_number,
		invoicedetail.tar_tariffnumber,
		invoicedetail.tar_tariffitem,
		' ',
		' ',

		invoicedetail.ivd_fromord, 
                chargetype.cht_rollintolh,
		@ctynmstct cty_nmstct,
		@ctycode stp_city,
		@ctycode origin_city
FROM  invoicedetail  LEFT OUTER JOIN  chargetype  ON  invoicedetail.cht_itemcode  = chargetype.cht_itemcode  
WHERE	 (invoicedetail.ord_hdrnumber  = @pl_ordhdrnumber)

	UNION
 	SELECT	0 ivh_hdrnumber, 
		0 ivd_number,
		' ' ivd_description, 
		cht_quantity ivd_quantity, 
		cht_rate ivd_rate, 
		0 ivd_charge,  
		cht_taxtable1 ivd_taxable1,
		cht_taxtable2 ivd_taxable2, 
		cht_taxtable3 ivd_taxable3, 
		cht_taxtable4 ivd_taxable4, 
		cht_unit ivd_unit, 
		@dummy6 cur_code, 
		@dumdate currencydate, 
		@glnum ivd_glnum, 	
		stops.ord_hdrnumber, 
		stops.stp_type, 
		cht_rateunit shp_rateunit, 

		@dummy6 shp_billto, 
		0 ivd_itemquantity, 
		0 ivd_subtotalptr, 	
		stops.stp_sequence, 	
		@dummy6 shp_invoicestatus, 
		stops.mfh_number, 
		@sDummyRefNum fgt_refnum, 
		stops.cmp_id, 
		stops.stp_ord_mileage ivd_distance,
	 	' ' ivd_distunit, 
		0 ivd_wgt, 
		' ' ivd_wgtunit, 
		0 ivd_count, 
		event.evt_number, 
		@sDummyRefType fgt_reftype, 
		0 ivd_volume, 
		' ' ivd_volunit, 
		stops.cmp_id shp_originpoint, 
		' ' ivd_countunit, 
		chargetype.cht_itemcode, 
                ' ',	
		chargetype.cht_basis, 
		0, 
		0, 
		1 ivd_sign,
		0 ivd_length, 
		' ' ivd_lengthunit, 
		0 ivd_width, 
		' ' ivd_widthunit, 	
		0 ivd_height,

		' ' ivd_heightunit, 
		cht_primary,	
		stops.stp_number, 
		chargetype.cht_basisunit,
		'' ivd_remark,
		0 tar_number,
		'' tar_tariffnumber,
		'' tar_tariffitem,
		' ',
		' ',
		' ', 
                chargetype.cht_rollintolh,
		@ctynmstct cty_nmstct,
		@ctycode stp_city,
		@ctycode origin_city
	FROM 	chargetype, stops, event, eventcodetable
		
   	WHERE	stops.ord_hdrnumber = @pl_ordhdrnumber AND
                ( event.evt_eventcode = chargetype.cht_itemcode) AND
		( stops.stp_number = event.stp_number )	AND
		( event.evt_eventcode = eventcodetable.abbr) AND
		( eventcodetable.ect_billable = 'Y') 

else
	INSERT INTO #invdetail
 	SELECT distinct 
		0 ivh_hdrnumber, 
		0 ivd_number,
		ISNULL(freightdetail.fgt_description,'UNKNOWN') ivd_description, 
		ISNULL(freightdetail.fgt_quantity,0) ivd_quantity, 
		ISNULL(freightdetail.fgt_rate,0.0) ivd_rate, 
		ISNULL(freightdetail.fgt_charge,0.0) ivd_charge,  
		commodity.cmd_taxtable1 ivd_taxable1,
		commodity.cmd_taxtable2 ivd_taxable2, 
		commodity.cmd_taxtable3 ivd_taxable3, 
		commodity.cmd_taxtable4 ivd_taxable4, 
		ISNULL(freightdetail.fgt_unit,'LBS') ivd_unit, 
		@dummy6 cur_code, 
		@dumdate currencydate, 
		@glnum ivd_glnum, 	
		stops.ord_hdrnumber, 
		stops.stp_type, 
		ISNULL(freightdetail.fgt_rateunit,'UNK') shp_rateunit, 
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
		ISNULL(freightdetail.fgt_weight,0) ivd_wgt, 
		ISNULL(freightdetail.fgt_weightunit,'LBS') ivd_wgtunit, 
		ISNULL(freightdetail.fgt_count,0) ivd_count, 
		event.evt_number, 
		stops.stp_reftype, 
		ISNULL(freightdetail.fgt_volume,0) ivd_volume, 
		ISNULL(freightdetail.fgt_volumeunit,'CUB') ivd_volunit, 
		stops.cmp_id shp_originpoint, 
		ISNULL(freightdetail.fgt_countunit,'PCS') ivd_countunit, 
		ISNULL(freightdetail.cht_itemcode,'UNK') cht_itemcode, 	
		ISNULL(freightdetail.cmd_code,'UNKNOWN') cmd_code, 
		'DEL' cht_basis, 
		freightdetail.fgt_lowtemp, 
		freightdetail.fgt_hitemp, 
		1 ivd_sign,
		freightdetail.fgt_length ivd_length, 
		freightdetail.fgt_lengthunit ivd_lengthunit, 
		freightdetail.fgt_width ivd_width, 
		freightdetail.fgt_widthunit ivd_widthunit, 	
		freightdetail.fgt_height ivd_height,
		freightdetail.fgt_heightunit ivd_heightunit, 
		'Y' cht_primary,	
		stops.stp_number, 
		ISNULL(freightdetail.cht_basisunit,'UNK') cht_basisunit,
		'' ivd_remark,
		0 tar_number,
		'' tar_tariffnumber,
		'' tar_tariffitem,
		' ',
		' ' ,
		' ', 
                0 cht_rollintolh,
		@ctynmstct cty_nmstct,
		@ctycode stp_city,
		@ctycode origin_city
FROM  stops  LEFT OUTER JOIN  commodity  ON  (stops.cmd_code  = commodity.cmd_code) ,
	 freightdetail,
	 event,
	 eventcodetable 
WHERE	 stops.ord_hdrnumber  = @pl_ordhdrnumber
 AND	(stops.stp_number  = event.stp_number)
 AND	(freightdetail.stp_number  = stops.stp_number)
 AND	(event.evt_eventcode  = eventcodetable.abbr)
 AND	(eventcodetable.ect_billable  = 'Y')
 AND	(stops.stp_sequence  >
	(
 	SELECT MIN(stp_sequence)
	FROM  stops,
		 eventcodetable 
	WHERE	 ord_hdrnumber  = @pl_ordhdrnumber
	 AND	stp_event  = abbr
	 AND	ect_billable  = 'Y'
	))
 AND	(event.evt_sequence  = 1)

	UNION
	SELECT invoicedetail.ivh_hdrnumber, 
		invoicedetail.ivd_number, 
		invoicedetail.ivd_description, 
		invoicedetail.ivd_quantity, 
		invoicedetail.ivd_rate, 
		invoicedetail.ivd_charge, 
		invoicedetail.ivd_taxable1, 
		invoicedetail.ivd_taxable2, 
		invoicedetail.ivd_taxable3, 
		invoicedetail.ivd_taxable4, 
		invoicedetail.ivd_unit, 
		invoicedetail.cur_code, 
		invoicedetail.ivd_currencydate, 
		invoicedetail.ivd_glnum, 
		invoicedetail.ord_hdrnumber, 
		invoicedetail.ivd_type, 
		invoicedetail.ivd_rateunit, 
		invoicedetail.ivd_billto, 
		invoicedetail.ivd_itemquantity, 
		invoicedetail.ivd_subtotalptr, 
		invoicedetail.ivd_sequence, 
		invoicedetail.ivd_invoicestatus, 
		invoicedetail.mfh_hdrnumber, 
		invoicedetail.ivd_refnum, 
		invoicedetail.cmp_id, 
		invoicedetail.ivd_distance, 
		invoicedetail.ivd_distunit, 
		invoicedetail.ivd_wgt, 

		invoicedetail.ivd_wgtunit, 
		invoicedetail.ivd_count, 
		invoicedetail.evt_number, 
		invoicedetail.ivd_reftype, 
		invoicedetail.ivd_volume, 
		invoicedetail.ivd_volunit, 
		invoicedetail.ivd_orig_cmpid, 
		invoicedetail.ivd_countunit, 
		invoicedetail.cht_itemcode, 
		invoicedetail.cmd_code, 
		chargetype.cht_basis,	 
		0 lowtemp, 	 
		0 hightemp, 
		invoicedetail.ivd_sign, 
		invoicedetail.ivd_length, 
		invoicedetail.ivd_lengthunit, 
		invoicedetail.ivd_width, 
		invoicedetail.ivd_widthunit, 
		invoicedetail.ivd_height, 
		invoicedetail.ivd_heightunit ,
		chargetype.cht_primary, 
		invoicedetail.stp_number,

		invoicedetail.cht_basisunit,
		invoicedetail.ivd_remark,
		invoicedetail.tar_number,
		invoicedetail.tar_tariffnumber,
		invoicedetail.tar_tariffitem,
		' ',
		' ',
		invoicedetail.ivd_fromord, 
                chargetype.cht_rollintolh,
		@ctynmstct cty_nmstct,
		@ctycode stp_city,
		@ctycode origin_city
FROM  invoicedetail  LEFT OUTER JOIN  chargetype  ON  invoicedetail.cht_itemcode  = chargetype.cht_itemcode  
WHERE	 (invoicedetail.ord_hdrnumber  = @pl_ordhdrnumber)

	UNION
 	SELECT	0 ivh_hdrnumber, 
		0 ivd_number,
		' ' ivd_description, 
		cht_quantity ivd_quantity, 
		cht_rate ivd_rate, 
		0 ivd_charge,  
		cht_taxtable1 ivd_taxable1,
		cht_taxtable2 ivd_taxable2, 
		cht_taxtable3 ivd_taxable3, 
		cht_taxtable4 ivd_taxable4, 
		cht_unit ivd_unit, 
		@dummy6 cur_code, 
		@dumdate currencydate, 
		@glnum ivd_glnum, 	
		stops.ord_hdrnumber, 
		stops.stp_type, 
		cht_rateunit shp_rateunit, 
		@dummy6 shp_billto, 
		0 ivd_itemquantity, 
		0 ivd_subtotalptr, 	
		stops.stp_sequence, 	
		@dummy6 shp_invoicestatus, 
		stops.mfh_number, 
		stops.stp_refnum, 
		stops.cmp_id, 
		stops.stp_ord_mileage ivd_distance,
	 	' ' ivd_distunit, 
		0 ivd_wgt, 
		' ' ivd_wgtunit, 
		0 ivd_count, 
		event.evt_number, 
		stops.stp_reftype, 
		0 ivd_volume, 
		' ' ivd_volunit, 
		stops.cmp_id shp_originpoint, 
		' ' ivd_countunit, 

		cht_itemcode, 
                ' ',	
		cht_basis, 
		0, 
		0, 
		1 ivd_sign,
		0 ivd_length, 
		' ' ivd_lengthunit, 
		0 ivd_width, 
		' ' ivd_widthunit, 	
		0 ivd_height,
		' ' ivd_heightunit, 
		cht_primary,	
		stops.stp_number, 
		cht_basisunit,
		'' ivd_remark,
		0 tar_number,
		'' tar_tariffnumber,
		'' tar_tariffitem,
		' ',
		' ',
		' ', 
                chargetype.cht_rollintolh,
		@ctynmstct cty_nmstct,
		@ctycode stp_city,
		@ctycode origin_city
	FROM 	chargetype, stops, event, eventcodetable
   	WHERE	stops.ord_hdrnumber = @pl_ordhdrnumber AND
                        ( event.evt_eventcode = chargetype.cht_itemcode) AND
			( stops.stp_number = event.stp_number )	AND
			( event.evt_eventcode = eventcodetable.abbr) AND

			( eventcodetable.ect_billable = 'Y') 

	update 	#invdetail set 
		#invdetail.cht_itemcode  = c.cht_itemcode ,
		#invdetail.cht_basis 	 = c.cht_basis,
		#invdetail.cht_basisunit = c.cht_basisunit	
	from 	chargetype c
	where 	c.cht_itemcode = 'DEL'
	   


-- If in rate by total mode then create a subtotal row
	if @ls_rateby = 'T'
	INSERT INTO #invdetail
 	SELECT distinct 
		0 ivh_hdrnumber, 
		0 ivd_number,
		'' ivd_description, 
		o.ord_quantity ivd_quantity, 
		o.ord_rate ivd_rate, 
		o.ord_charge ivd_charge,  
		'' ivd_taxable1,
		'' ivd_taxable2, 
		'' ivd_taxable3, 
		'' ivd_taxable4, 
		o.ord_unit ivd_unit, 
		@dummy6 cur_code, 
		@dumdate currencydate, 
		@glnum ivd_glnum, 	
		@pl_ordhdrnumber, 
		'SUB', 
		ord_rateunit shp_rateunit, 
		@dummy6 shp_billto, 
		0 ivd_itemquantity, 
		0 ivd_subtotalptr, 	
		0, 	
		@dummy6 shp_invoicestatus, 
		0, 
		'', 
		'', 
		0 ivd_distance,
	 	'MIL' ivd_distunit, 
		0ivd_wgt, 
		'LBS' ivd_wgtunit, 
		0 ivd_count, 
		0, 
		'', 
		0 ivd_volume, 
		'CUB' ivd_volunit, 
		'', 
		'PCS' ivd_countunit, 
                o.cht_itemcode cht_itemcode,
		'UNKNOWN' cmd_code, 
		'DEL' cht_basis, 
		0, 
		0, 
		1 ivd_sign,
		0, 
		'', 
		0, 
		'', 	
		0,
		'', 
		'Y' cht_primary,	
		0, 
		'UNK' cht_basisunit,
		'' ivd_remark,
		0 tar_number,
		'' tar_tariffnumber,
		o.tar_tariffitem tar_tariffitem,
		' ',
		' ',
		' ', 
                0 cht_rollintolh,
		@ctynmstct cty_nmstct,
		@ctycode stp_city,
		@ctycode origin_city

	FROM 	orderheader o
   	WHERE	o.ord_hdrnumber = @pl_ordhdrnumber 


	UPDATE	#invdetail
	SET	ivh_billto = ivh.ivh_billto,
		suffix_prefix = SUBSTRING(LTRIM(REVERSE(ivh.ivh_invoicenumber)), 1, 1)
	FROM	invoiceheader ivh
	WHERE	ivh.ivh_hdrnumber = #invdetail.ivh_hdrnumber


	UPDATE	#invdetail
	SET	ivd_glnum = cht_glnum
	FROM	chargetype c
	WHERE	c.cht_itemcode = #invdetail.cht_itemcode

	UPDATE  #invdetail   
	SET	cty_nmstct = c.cty_nmstct,	
		stp_city = s.stp_city 
	FROM  city c  RIGHT OUTER JOIN  stops s  ON  c.cty_code  = s.stp_city  
	WHERE  #invdetail.stp_number  IS NOT NULL
	 AND	s.stp_number  = #invdetail.stp_number 

	execute @li_invoicehdrnumber = getsystemnumber 'INVHDR', NULL
	update #invhdr set ivh_hdrnumber = @li_invoicehdrnumber
	update #invhdr set ivh_hdrnumber = @li_invoicehdrnumber
	update #invhdr set ivh_invoicenumber = @ls_ordhdrnumber +'A'
	update #invdetail set ivh_hdrnumber = @li_invoicehdrnumber
	
	-- Now sequence all the invoicedetails( this could be a problem as the sort order is not guarenteed)
	-- (but I dont have any time to fix this now.We could potentially get the subtotal row in between)
	select @li_seq = 1

	while  1 = 1
	begin		
		select @li_count = count(*) from #invdetail where 
		IsNull(ivd_number,0) = 0	
		
		If @li_count = 0 
			break
			
		execute @li_invoicedtlnumber = getsystemnumber 'INVDET', NULL
		
		set rowcount 1
		update #invdetail set ivd_number = @li_invoicedtlnumber,ivd_sequence = @li_seq where
			ivd_number = 0		
		set rowcount 0
		select @li_seq = @li_seq + 1
	end


	if @ls_rateby = 'T'
	Begin
		select @li_subtotptr = ivd_number from #invdetail where ivd_type = 'SUB'
		update #invdetail set ivd_subtotalptr = @li_subtotptr
	End

 Begin Tran
	update #invdetail set ivh_hdrnumber = @li_invoicehdrnumber where ord_hdrnumber = @pl_ordhdrnumber
	if @@error <> 0 
	Begin
		select -1,'Error Updating the invoice header number on the invoicedetails'	
		Rollback
		Return -1
	End 

	insert into invoicedetail(
	ivh_hdrnumber, 
	ivd_number, 
	ivd_description, 
	ivd_quantity, 
	ivd_rate, 
	ivd_charge, 
	ivd_unit, 
	ivd_glnum, 
	ord_hdrnumber,
	ivd_type, 
	ivd_rateunit, 
	ivd_itemquantity, 
	ivd_subtotalptr, 
	ivd_sequence, 
	mfh_hdrnumber, 
	cmp_id, 
	ivd_distance, 
	ivd_distunit, 
	ivd_wgt, 
	ivd_wgtunit, 
	ivd_count, 
	evt_number, 
	ivd_reftype, 
	ivd_volume, 
	ivd_volunit, 
	ivd_orig_cmpid, 
	ivd_countunit, 
	cht_itemcode, 
	cmd_code, 
	ivd_sign, 
	stp_number, 
	cht_basisunit, 
	ivd_remark, 
	tar_number, 
	tar_tariffnumber, 
	tar_tariffitem, 
	ivd_fromord )
	(select  
	ivh_hdrnumber, 
	ivd_number, 
	ivd_description, 
	ivd_quantity, 
	ivd_rate, 
	ivd_charge, 
	ivd_unit, 
	ivd_glnum, 
	ord_hdrnumber, 
	ivd_type, 
	ivd_rateunit, 
	ivd_itemquantity, 
	ivd_subtotalptr, 
	ivd_sequence, 
	mfh_hdrnumber, 
	cmp_id, 
	ivd_distance, 
	ivd_distunit, 
	ivd_wgt, 
	ivd_wgtunit, 
	ivd_count, 
	evt_number, 
	ivd_reftype, 
	ivd_volume, 
	ivd_volunit, 
	ivd_orig_cmpid, 
	ivd_countunit, 
	cht_itemcode, 
	cmd_code, 
	ivd_sign, 
	stp_number, 
	cht_basisunit, 
	ivd_remark, 
	tar_number, 
	tar_tariffnumber, 
	tar_tariffitem, 
	ivd_fromord 
	 from #invdetail 
	where ivd_number not in (select b.ivd_number from invoicedetail b 
					  where b.ord_hdrnumber  = @pl_ordhdrnumber ))

	if @@error <> 0 
	Begin
		select -1,'Error Creating New InvoiceDetails'	
		Rollback
		Return -1
	End 


	INSERT INTO invoiceheader ( 
	ivh_invoicenumber, 
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
	ivh_creditmemo, 
	ivh_applyto, 
	ivh_billdate, 
	ivh_hdrnumber, 
	ord_hdrnumber, 
	ivh_mbnumber, 
	ivh_driver, 
	ivh_driver2, 
	ivh_tractor, 
	ivh_trailer, 
	mov_number, 
	ivh_freight_miles, 
	ivh_priority, 
	ivh_low_temp, 
	ivh_high_temp, 
	ivh_order_by, 
	tar_tarriffnumber, 
	tar_number, 
	tar_tariffitem, 
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
	ivh_totaltime, 
	ivh_rateby, 
	ivh_stopoffs, 
	ivh_quantity_type, 
	ivh_charge_type )
	(select 
	ivh_invoicenumber, 
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
	ivh_creditmemo, 
	ivh_applyto, 
	ivh_billdate, 
	ivh_hdrnumber, 
	ord_hdrnumber, 
	ivh_mbnumber, 
	ivh_driver, 
	ivh_driver2, 
	ivh_tractor, 
	ivh_trailer, 
	mov_number, 
	ivh_freight_miles, 
	ivh_priority, 
	ivh_low_temp, 
	ivh_high_temp, 
	ivh_order_by, 
	tar_tarriffnumber, 
	tar_number,  
	tar_tariffitem, 
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
	ivh_totaltime, 
	ivh_rateby, 
	ivh_stopoffs, 
	ivh_quantity_type, 
	ivh_charge_type 
	 from #invhdr)
	if @@error <> 0 
	Begin
		select -1,'Error Creating the InvoiceHeader'	
		Rollback
		Return -1
	End 


	update orderheader set ord_invoicestatus = 'PPD' where ord_hdrnumber = @pl_ordhdrnumber
	if @@error <> 0 
	Begin
		select -1,'Error Updating Order Status to PPD'	
		Rollback
		Return -1
	End 

	Commit

	select @li_invoicehdrnumber,'Invoice Created'


GO
GRANT EXECUTE ON  [dbo].[createsimpleinvoice_sp] TO [public]
GO
