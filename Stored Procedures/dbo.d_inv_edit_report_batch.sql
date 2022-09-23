SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_inv_edit_report_batch](@invoice_no_lo  	int,
				   	@invoice_no_hi  	int,
				   	@invoice_status		varchar(10),
				   	@revtype1	 	varchar(6),
				   	@revtype2		varchar(6),
				   	@revtype3		varchar(6),
				   	@revtype4		varchar(6),
				   	@billto			varchar(8),
				   	@shipper		varchar(8),
				   	@consignee		varchar(8),
				   	@shipdate1		datetime,
				   	@shipdate2		datetime,
				   	@deldate1		datetime,
				   	@deldate2		datetime,
				   	@billdate1		datetime,
				   	@billdate2		datetime,
				   	@copies			int,	
				   	@queue_number		int,
				   	@useasbillto		varchar(3), 
					@batch 			varchar(254), 
					@batch_count 		int,
				   	@xfrdate1		datetime,
				   	@xfrdate2		datetime,
				 	@include_mbonly		char(1),
				   @usr_id char(20) = 'UNK')  --pts 38282 os
as
/*	PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND
	1 - IF SUCCESFULLY EXECUTED
	@@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS
*/

/**
 * DESCRIPTION:
 *
 * REVISION HISTORY:
 * 2/2/99 add cmp_altid from useasbillto company to return set
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/
declare	@temp_name   varchar(30) ,
	@temp_addr   varchar(30) ,
	@temp_addr2  varchar(30),
	@temp_nmstct varchar(30),
	@temp_altid  varchar(8),
	@counter    int,
	@ret_value  int,
	@revtype1_name	varchar(30),
	@revtype2_name	varchar(30),
	@revtype3_name	varchar(30),
	@revtype4_name	varchar(30)
	
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1

DECLARE	@batch_id_1 	varchar(10),
	@i_batch	int,
	@batch_string	varchar(254),
	@count 		int

Create Table #invtemp_tbl (
	ivh_invoicenumber	varchar(12)	NULL,
	ivh_hdrnumber		int	NULL,
	ivh_billto		varchar(8)	NULL,
	ivh_billto_name		varchar(30)	NULL,
	ivh_billto_addr		varchar(30)	NULL,
	ivh_billto_addr2	varchar(30)	NULL,
	ivh_billto_nmctst	varchar(30)	NULL,
	ivh_terms		char(3)	NULL,
	ivh_totalcharge		money	NULL,
	ivh_shipper		varchar(8)	NULL,
	shipper_name		varchar(30)	NULL,
	shipper_addr		varchar(30)	NULL,
	shipper_addr2		varchar(30)	NULL,
	shipper_nmctst		varchar(30)	NULL,
	ivh_consignee		varchar(8)	NULL,
	consignee_name		varchar(30)	NULL,
	consignee_addr		varchar(30)	NULL,
	consignee_addr2		varchar(30)	NULL,
	consignee_nmctst	varchar(30)	NULL,
	ivh_originpoint		varchar(8)	NULL,
	originpoint_name	varchar(30)	NULL,
	origin_addr		varchar(30)	NULL,
	origin_addr2		varchar(30)	NULL,
	origin_nmctst		varchar(30)	NULL,
	ivh_destpoint		varchar(8)	NULL,
	destpoint_name		varchar(30)	NULL,
	dest_addr		varchar(30)	NULL,
	dest_addr2		varchar(30)	NULL,
	dest_nmctst		varchar(30)	NULL,
	ivh_invoicestatus	varchar(6)	NULL,
	ivh_origincity		Integer		NULL,
	ivh_destcity		Integer		NULL,
	ivh_originstate		char(2)		NULL,
	ivh_deststate		char(2)		NULL,
	ivh_originregion1	varchar(6)	NULL,
	ivh_destregion1		varchar(6)	NULL,
	ivh_supplier		varchar(8)	NULL,
	ivh_shipdate		datetime	NULL,
	ivh_deliverydate	datetime	NULL,
	ivh_revtype1		varchar(6)	NULL,
	ivh_revtype2		varchar(6)	NULL,
	ivh_revtype3		varchar(6)	NULL,
	ivh_revtype4		varchar(6)	NULL,
	ivh_totalweight		float(8)	NULL,
	ivh_totalpieces		float(8)	NULL,
	ivh_totalmiles		float(8)	NULL,
	ivh_currency		varchar(6)	NULL,
	ivh_currencydate	datetime	NULL,
	ivh_totalvolume		float(8)	NULL,
	ivh_taxamount1		money		NULL,
	ivh_taxamount2		money		NULL,
	ivh_taxamount3		money		NULL,
	ivh_taxamount4		money		NULL,
	ivh_transtype		varchar(6)	NULL,
	ivh_creditmemo		char(1)		NULL,
	ivh_applyto		varchar(12)	NULL,
	ivh_printdate		datetime	NULL,
	ivh_billdate		datetime	NULL,
	ivh_lastprintdate	datetime	NULL,
	ivh_originregion2	varchar(6)	NULL,
	ivh_originregion3	varchar(6)	NULL,
	ivh_originregion4	varchar(6)	NULL,
	ivh_destregion2		varchar(6)	NULL,
	ivh_destregion3		varchar(6)	NULL,
	ivh_destregion4		varchar(6)	NULL,
	mfh_hdrnumber		Integer		NULL,
	ivh_remark		varchar(254)	NULL,
	ivh_driver		varchar(8)	NULL,
	ivh_tractor		varchar(8)	NULL,
	ivh_trailer		varchar(13)	NULL,
	ivh_user_id1		char(20)	NULL,
	ivh_user_id2		char(20)	NULL,
	ivh_ref_number		varchar(30)	NULL,
	ivh_driver2		varchar(8)	NULL,
	mov_number		Integer		NULL,
	ivh_edi_flag		char(30)	NULL,
	ord_hdrnumber		Integer		NULL,
	ivd_number		Integer		NULL,
	stp_number		Integer		NULL,
	ivd_description		varchar(60)	NULL,
	cht_itemcode		char(6)		NULL,
	ivd_quantity		float(8)	NULL,
	ivd_rate		money		NULL,
	ivd_charge		money		NULL,
	ivd_taxable1		char(1)		NULL,
	ivd_taxable2		char(1)		NULL,
	ivd_taxable3		char(1)		NULL,
	ivd_taxable4		char(1)		NULL,
	ivd_unit		char(6)		NULL,
	cur_code		char(6)		NULL,
	ivd_currencydate	datetime	NULL,
	ivd_glnum		char(32)	NULL,
	ivd_type		char(6)		NULL,
	ivd_rateunit		char(6)		NULL,
	ivd_billto		char(8)		NULL,
	ivd_billto_name		varchar(30)	NULL,
	ivd_billto_addr		varchar(30)	NULL,
	ivd_billto_addr2	varchar(30)	NULL,
	ivd_billto_nmctst	varchar(30)	NULL,
	ivd_itemquantity	float(8)	NULL,
	ivd_subtotalptr		Integer	NULL,
	ivd_allocatedrev	money	NULL,
	ivd_sequence		Integer	NULL,
	ivd_refnum		varchar(30)	NULL,
	cmd_code		varchar(8)	NULL,
	cmp_id			varchar(8)	NULL,
	stop_name		varchar(30)	NULL,
	stop_addr		varchar(30)	NULL,
	stop_addr2		varchar(30)	NULL,
	stop_nmctst		varchar(30)	NULL,
	ivd_distance		float(8)	NULL,
	ivd_distunit		varchar(6)	NULL,
	ivd_wgt			float(8)	NULL,
	ivd_wgtunit		varchar(6)	NULL,
	ivd_count		decimal(9)	NULL,
	ivd_countunit		char(6)	NULL,
	evt_number		Integer	NULL,
	ivd_reftype		varchar(6)	NULL,
	ivd_volume		float(8)	NULL,
	ivd_volunit		char(6)	NULL,
	ivd_orig_cmpid		char(8)	NULL,
	ivd_payrevenue		money	NULL,
	ivh_freight_miles	float(8)	NULL,
	tar_tarriffnumber	varchar(12)	NULL,
	tar_tariffitem		varchar(12)	NULL,
	copies			Integer	NULL,
	cht_basis		varchar(6)	NULL,
	cht_description		varchar(30)	NULL,
	cmd_name		varchar(60)	NULL,
	cmp_altid		varchar(8)	NULL,
	ivh_batch_id		varchar(10)	NULL,
	ivh_revenue_date	datetime	NULL,
	revtype1_name		varchar(8)	NULL,
	revtype2_name		varchar(8)	NULL,
	revtype3_name		varchar(8)	NULL,
	revtype4_name		varchar(8)	NULL,
	ivh_xferdate		datetime	Null,
	cht_class			varchar(6) null,
	cmd_stcc			varchar(8) null,
	no_print 			varchar (20) null,
	tar_number			int null,
	ivh_order_cmd_code	varchar(8) null,
	order_cmd_name		varchar(60) null)

select @batch_string = RTRIM(@batch)
select @i_batch = 0
select @count = 1

create table #batch (batch_id varchar(10) not null)
insert #batch (batch_id) values('XXX,')

WHILE @count <= @batch_count
BEGIN
	select @i_batch = charindex(',', @batch_string)
	If @i_batch > 0
	BEGIN
		SELECT @batch_id_1 = substring(@batch_string, 1, (@i_batch - 1))
		select @batch_string = substring(@batch_string, (@i_batch + 1), (254 - @i_batch))
		insert #batch (batch_id) values(@batch_id_1)
		select @count = @count + 1
	END
	If @count > 1 and @i_batch = 0
	BEGIN
		insert #batch (batch_id) values(@batch_string)
		select @count = @count + 1
	END
END

/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET 
	NOTE: 'COPY' - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/
Insert Into #invtemp_tbl
SELECT  invoiceheader.ivh_invoicenumber,   
         invoiceheader.ivh_hdrnumber, 
	 invoiceheader.ivh_billto, 
	 @temp_name ivh_billto_name ,
	 @temp_addr 	ivh_billto_addr,
	 @temp_addr2	ivh_billto_addr2,
	 @temp_nmstct ivh_billto_nmctst,
         invoiceheader.ivh_terms,   	
         invoiceheader.ivh_totalcharge,   
	 invoiceheader.ivh_shipper,   
	 @temp_name	shipper_name,
	 @temp_addr	shipper_addr,
	 @temp_addr2	shipper_addr2,
	 @temp_nmstct shipper_nmctst,
         invoiceheader.ivh_consignee,   
	 @temp_name consignee_name,
	 @temp_addr consignee_addr,
	 @temp_addr2	consignee_addr2,
	 @temp_nmstct consignee_nmctst,
         invoiceheader.ivh_originpoint,   
	 @temp_name originpoint_name,
	 @temp_addr origin_addr,
	 @temp_addr2	origin_addr2,
	 @temp_nmstct origin_nmctst,
         invoiceheader.ivh_destpoint,   
	 @temp_name destpoint_name,
	 @temp_addr dest_addr,
	 @temp_addr2	dest_addr2,
	 @temp_nmstct dest_nmctst,
         invoiceheader.ivh_invoicestatus,   
         invoiceheader.ivh_origincity,   
         invoiceheader.ivh_destcity,   
         invoiceheader.ivh_originstate,   
         invoiceheader.ivh_deststate,
         invoiceheader.ivh_originregion1,   
         invoiceheader.ivh_destregion1,   
         invoiceheader.ivh_supplier,   
         invoiceheader.ivh_shipdate,   
         invoiceheader.ivh_deliverydate,   
         invoiceheader.ivh_revtype1,   
         invoiceheader.ivh_revtype2,   
         invoiceheader.ivh_revtype3,   
         invoiceheader.ivh_revtype4,   
         invoiceheader.ivh_totalweight,   
         invoiceheader.ivh_totalpieces,   
         invoiceheader.ivh_totalmiles,   
         invoiceheader.ivh_currency,   
         invoiceheader.ivh_currencydate,   
         invoiceheader.ivh_totalvolume,   
         invoiceheader.ivh_taxamount1,   
         invoiceheader.ivh_taxamount2,   
         invoiceheader.ivh_taxamount3,   
         invoiceheader.ivh_taxamount4,   
         invoiceheader.ivh_transtype,   
         invoiceheader.ivh_creditmemo,   
         invoiceheader.ivh_applyto,   
         invoiceheader.ivh_printdate,   
         invoiceheader.ivh_billdate,   
         invoiceheader.ivh_lastprintdate,   
         invoiceheader.ivh_originregion2,   
         invoiceheader.ivh_originregion3,   
         invoiceheader.ivh_originregion4,   
         invoiceheader.ivh_destregion2,   
         invoiceheader.ivh_destregion3,   
         invoiceheader.ivh_destregion4,   
         invoiceheader.mfh_hdrnumber,   
         invoiceheader.ivh_remark,   
         invoiceheader.ivh_driver,   
         invoiceheader.ivh_tractor,   
         invoiceheader.ivh_trailer,   
         invoiceheader.ivh_user_id1,   
         invoiceheader.ivh_user_id2,   
         invoiceheader.ivh_ref_number,   
         invoiceheader.ivh_driver2,   
         invoiceheader.mov_number,   
         invoiceheader.ivh_edi_flag,   
         invoiceheader.ord_hdrnumber,   
         invoicedetail.ivd_number,   
         invoicedetail.stp_number,   
         invoicedetail.ivd_description,   
         invoicedetail.cht_itemcode,   
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
         invoicedetail.ivd_type,   
         invoicedetail.ivd_rateunit,   
         invoicedetail.ivd_billto,   
	 @temp_name ivd_billto_name,
	 @temp_addr ivd_billto_addr,
	 @temp_addr2	ivd_billto_addr2,
	 @temp_nmstct ivd_billto_nmctst,
         invoicedetail.ivd_itemquantity,   
         invoicedetail.ivd_subtotalptr,   
         invoicedetail.ivd_allocatedrev,   
         invoicedetail.ivd_sequence,   
         invoicedetail.ivd_refnum,   
         invoicedetail.cmd_code,   
         invoicedetail.cmp_id,   
	 @temp_name	stop_name,
	 @temp_addr	stop_addr,
	 @temp_addr2	stop_addr2,
	 @temp_nmstct stop_nmctst,
         invoicedetail.ivd_distance,   
         invoicedetail.ivd_distunit,   
         invoicedetail.ivd_wgt,   
         invoicedetail.ivd_wgtunit,   
         invoicedetail.ivd_count,   
	 invoicedetail.ivd_countunit,   
         invoicedetail.evt_number,   
         invoicedetail.ivd_reftype,   
         invoicedetail.ivd_volume,   
         invoicedetail.ivd_volunit,   
         invoicedetail.ivd_orig_cmpid,   
         invoicedetail.ivd_payrevenue,
	 invoiceheader.ivh_freight_miles,
	 invoiceheader.tar_tarriffnumber,
	 invoiceheader.tar_tariffitem,
	 1 copies,
	 chargetype.cht_basis,
	 chargetype.cht_description,
	 commodity.cmd_name,
	@temp_altid cmp_altid, 
	invoiceheader.ivh_batch_id,
	invoiceheader.ivh_revenue_date,
	'RevType1' revtype1_name,
	'RevType2' revtype2_name,
	'RevType3' revtype3_name,
	'RevType4' revtype4_name,
	invoiceheader.ivh_xferdate,
	invoicedetail.cht_class,
	c1.cmd_stcc,
	no_print =
		 	CASE invoiceheader.ivh_block_printing
			WHEN 'Y' THEN 'DNM'
			ELSE '                    '
			END,
	invoiceheader.tar_number,
	invoiceheader.ivh_order_cmd_code,
	c1.cmd_name order_cmd_name
    --pts40012, jg, outer join conversion
	FROM  chargetype  RIGHT OUTER JOIN  invoicedetail  ON  chargetype.cht_itemcode  = invoicedetail.cht_itemcode   
					LEFT OUTER JOIN  commodity  ON  invoicedetail.cmd_code  = commodity.cmd_code ,
		 invoiceheader  LEFT OUTER JOIN  commodity c1  ON  invoiceheader.ivh_order_cmd_code  = c1.cmd_code ,
		 #batch 
   WHERE ( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and
	 ( invoiceheader.ivh_hdrnumber between @invoice_no_lo and @invoice_no_hi) AND
   	 ( @invoice_status  in ('ALL', invoiceheader.ivh_invoicestatus)) and
	 ( @revtype1 in('UNK', invoiceheader.ivh_revtype1)) and
	 ( @revtype2 in('UNK', invoiceheader.ivh_revtype2)) and  			
         ( @revtype3 in('UNK', invoiceheader.ivh_revtype3)) and  
         ( @revtype4 in('UNK', invoiceheader.ivh_revtype4)) and
	 ( @billto in ('UNKNOWN',invoiceheader.ivh_billto)) and
	 ( @shipper in ('UNKNOWN', invoiceheader.ivh_shipper)) and
	 ( @consignee in ('UNKNOWN',invoiceheader.ivh_consignee)) and
	 (invoiceheader.ivh_shipdate between @shipdate1 and @shipdate2 ) and
         (invoiceheader.ivh_deliverydate between @deldate1 and @deldate2) and
	 ((invoiceheader.ivh_billdate between @billdate1 and @billdate2) or
	 (invoiceheader.ivh_billdate IS null))
	AND ( invoiceheader.ivh_batch_id = #batch.batch_id )   and
	 ((@invoice_status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) or invoiceheader.ivh_xferdate IS null)) or
	 @invoice_status not in ('XFR'))and
     @usr_id in (ivh_user_id1, ivh_user_id2, 'UNK') --pts 38282 os

/* PTS 15841 - DJM - Get records for MasterBills 	*/
if @include_mbonly = 'Y'
	Begin
		Insert Into #invtemp_tbl
		SELECT  invoiceheader.ivh_invoicenumber,   
		         invoiceheader.ivh_hdrnumber, 
			 invoiceheader.ivh_billto, 
			 @temp_name ivh_billto_name ,
			 @temp_addr 	ivh_billto_addr,
			 @temp_addr2	ivh_billto_addr2,
			 @temp_nmstct ivh_billto_nmctst,
		         invoiceheader.ivh_terms,   	
		         invoiceheader.ivh_totalcharge,   
			 invoiceheader.ivh_shipper,   
			 @temp_name	shipper_name,
			 @temp_addr	shipper_addr,
			 @temp_addr2	shipper_addr2,
			 @temp_nmstct shipper_nmctst,
		         invoiceheader.ivh_consignee,   
			 @temp_name consignee_name,
			 @temp_addr consignee_addr,
			 @temp_addr2	consignee_addr2,
			 @temp_nmstct consignee_nmctst,
		         invoiceheader.ivh_originpoint,   
			 @temp_name originpoint_name,
			 @temp_addr origin_addr,
			 @temp_addr2	origin_addr2,
			 @temp_nmstct origin_nmctst,
		         invoiceheader.ivh_destpoint,   
			 @temp_name destpoint_name,
			 @temp_addr dest_addr,
			 @temp_addr2	dest_addr2,
			 @temp_nmstct dest_nmctst,
		         invoiceheader.ivh_invoicestatus,   
		         invoiceheader.ivh_origincity,   
		         invoiceheader.ivh_destcity,   
		         invoiceheader.ivh_originstate,   
		         invoiceheader.ivh_deststate,
		         invoiceheader.ivh_originregion1,   
		         invoiceheader.ivh_destregion1,   
		         invoiceheader.ivh_supplier,   
		         invoiceheader.ivh_shipdate,   
		         invoiceheader.ivh_deliverydate,   
		         invoiceheader.ivh_revtype1,   
		         invoiceheader.ivh_revtype2,   
		         invoiceheader.ivh_revtype3,   
		         invoiceheader.ivh_revtype4,   
		         invoiceheader.ivh_totalweight,   
		         invoiceheader.ivh_totalpieces,   
		         invoiceheader.ivh_totalmiles,   
		         invoiceheader.ivh_currency,   
		         invoiceheader.ivh_currencydate,   
		         invoiceheader.ivh_totalvolume,   
		         invoiceheader.ivh_taxamount1,   
		         invoiceheader.ivh_taxamount2,   
		         invoiceheader.ivh_taxamount3,   
		         invoiceheader.ivh_taxamount4,   
		         invoiceheader.ivh_transtype,   
		         invoiceheader.ivh_creditmemo,   
		         invoiceheader.ivh_applyto,   
		         invoiceheader.ivh_printdate,   
		         invoiceheader.ivh_billdate,   
		         invoiceheader.ivh_lastprintdate,   
		         invoiceheader.ivh_originregion2,   
		         invoiceheader.ivh_originregion3,   
		         invoiceheader.ivh_originregion4,   
		         invoiceheader.ivh_destregion2,   
		         invoiceheader.ivh_destregion3,   
		         invoiceheader.ivh_destregion4,   
		         invoiceheader.mfh_hdrnumber,   
		         invoiceheader.ivh_remark,   
		         invoiceheader.ivh_driver,   
		         invoiceheader.ivh_tractor,   
		         invoiceheader.ivh_trailer,   
		         invoiceheader.ivh_user_id1,   
		         invoiceheader.ivh_user_id2,   
		         invoiceheader.ivh_ref_number,   
		         invoiceheader.ivh_driver2,   
		         invoiceheader.mov_number,   
		         invoiceheader.ivh_edi_flag,   
		         invoiceheader.ord_hdrnumber,   
		         invoicedetail.ivd_number,   
		         invoicedetail.stp_number,   
		         invoicedetail.ivd_description,   
		         invoicedetail.cht_itemcode,   
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
		         invoicedetail.ivd_type,   
		         invoicedetail.ivd_rateunit,   
		         invoicedetail.ivd_billto,   
			 @temp_name ivd_billto_name,
			 @temp_addr ivd_billto_addr,
			 @temp_addr2	ivd_billto_addr2,
			 @temp_nmstct ivd_billto_nmctst,
		         invoicedetail.ivd_itemquantity,   
		         invoicedetail.ivd_subtotalptr,   
		         invoicedetail.ivd_allocatedrev,   
		         invoicedetail.ivd_sequence,   
		         invoicedetail.ivd_refnum,   
		         invoicedetail.cmd_code,   
		         invoicedetail.cmp_id,   
			 @temp_name	stop_name,
			 @temp_addr	stop_addr,
			 @temp_addr2	stop_addr2,
			 @temp_nmstct stop_nmctst,
		         invoicedetail.ivd_distance,   
		         invoicedetail.ivd_distunit,   
		         invoicedetail.ivd_wgt,   
		         invoicedetail.ivd_wgtunit,   
		         invoicedetail.ivd_count,   
			 invoicedetail.ivd_countunit,   
		         invoicedetail.evt_number,   
		         invoicedetail.ivd_reftype,   
		         invoicedetail.ivd_volume,   
		         invoicedetail.ivd_volunit,   
		         invoicedetail.ivd_orig_cmpid,   
		         invoicedetail.ivd_payrevenue,
			 invoiceheader.ivh_freight_miles,
			 invoiceheader.tar_tarriffnumber,
			 invoiceheader.tar_tariffitem,
			 1 copies,
			 chargetype.cht_basis,
			 chargetype.cht_description,
			 commodity.cmd_name,
			@temp_altid cmp_altid, 
			invoiceheader.ivh_batch_id,
			invoiceheader.ivh_revenue_date,
			'RevType1' revtype1_name,
			'RevType2' revtype2_name,
			'RevType3' revtype3_name,
			'RevType4' revtype4_name,
			invoiceheader.ivh_xferdate,
			invoicedetail.cht_class,
			c1.cmd_stcc,
			no_print =
				 	CASE invoiceheader.ivh_block_printing
					WHEN 'Y' THEN 'DNM'
					ELSE '                    '
					END,
			invoiceheader.tar_number,
			invoiceheader.ivh_order_cmd_code,
			c1.cmd_name order_cmd_name
		--pts40012, jg, outer join conversion
		FROM  chargetype  RIGHT OUTER JOIN  invoicedetail  ON  chargetype.cht_itemcode  = invoicedetail.cht_itemcode   
						LEFT OUTER JOIN  commodity  ON  invoicedetail.cmd_code  = commodity.cmd_code ,
			 invoiceheader  LEFT OUTER JOIN  commodity c1  ON  invoiceheader.ivh_order_cmd_code  = c1.cmd_code ,
			 #batch 
		   WHERE ( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and
			 ( invoiceheader.ivh_hdrnumber between @invoice_no_lo and @invoice_no_hi) AND
			 ( invoiceheader.ivh_invoicestatus = 'NTP' ) and
			 ( @invoice_status  in ('ALL', invoiceheader.ivh_mbstatus)) and
			 ( @revtype1 in('UNK', invoiceheader.ivh_revtype1)) and
			 ( @revtype2 in('UNK', invoiceheader.ivh_revtype2)) and  			
		         ( @revtype3 in('UNK', invoiceheader.ivh_revtype3)) and  
		         ( @revtype4 in('UNK', invoiceheader.ivh_revtype4)) and
			 ( @billto in ('UNKNOWN',invoiceheader.ivh_billto)) and
			 ( @shipper in ('UNKNOWN', invoiceheader.ivh_shipper)) and
			 ( @consignee in ('UNKNOWN',invoiceheader.ivh_consignee)) and
			 (invoiceheader.ivh_shipdate between @shipdate1 and @shipdate2 ) and
		         (invoiceheader.ivh_deliverydate between @deldate1 and @deldate2) and
			 ((invoiceheader.ivh_billdate between @billdate1 and @billdate2) or
			 (invoiceheader.ivh_billdate IS null))
			AND ( invoiceheader.ivh_batch_id = #batch.batch_id )   and
			 ((@invoice_status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) or invoiceheader.ivh_xferdate IS null)) or
			 @invoice_status not in ('XFR'))  and
		    @usr_id in (ivh_user_id1, ivh_user_id2, 'UNK') --pts 38282 os
	
	End
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */
if (select count(*) from #invtemp_tbl) = 0
	begin
	select @ret_value = 0  
	GOTO ERROR_END
	end
/* RETRIEVE COMPANY DATA */	                   			
if @useasbillto = 'BLT'
	begin
	/*	LOR	PTS#4789(SR# 7160)	*/
	If ((select count(*) 
		from company c, #invtemp_tbl t
		where c.cmp_id = t.ivh_billto and
			c.cmp_mailto_name = '') > 0 or
	     (select count(*) 
		from company c, #invtemp_tbl t
		where c.cmp_id = t.ivh_billto and
			c.cmp_mailto_name is null) > 0 or
	     (select count(*)
			from #invtemp_tbl t, chargetype ch, company c
			where c.cmp_id = t.ivh_billto and
				ch.cht_itemcode = t.cht_itemcode and
				ch.cht_primary = 'Y') = 0 or
	     (select count(*) 
		from company c, chargetype ch, #invtemp_tbl t
		where c.cmp_id = t.ivh_billto and
			c.cmp_mailto_name is not null and
			c.cmp_mailto_name not in ('') and
			ch.cht_itemcode = t.cht_itemcode and
			ch.cht_primary = 'Y' and
			t.ivh_terms not in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3)) > 0)
			
		update #invtemp_tbl
		set ivh_billto_name = company.cmp_name,
			 ivh_billto_addr = company.cmp_address1,
			 ivh_billto_addr2 = company.cmp_address2,		
			 ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip,
			#invtemp_tbl.cmp_altid = company.cmp_altid 
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_billto
	Else	
		update #invtemp_tbl
		set ivh_billto_name = company.cmp_mailto_name,
			 ivh_billto_addr = company.cmp_mailto_address1,
			 ivh_billto_addr2 = company.cmp_mailto_address2,		
			 ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct)))+ ' ' + company.cmp_mailto_zip,
			#invtemp_tbl.cmp_altid = company.cmp_altid 
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_billto
	end			
if @useasbillto = 'ORD'
	begin
	update #invtemp_tbl
		set ivh_billto_name = company.cmp_name,
			 ivh_billto_addr = company.cmp_address1,
			 ivh_billto_addr2 = company.cmp_address2,		
			 ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip ,
			#invtemp_tbl.cmp_altid = company.cmp_altid 
		from #invtemp_tbl, company, invoiceheader
		where #invtemp_tbl.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and
				company.cmp_id = invoiceheader.ivh_order_by
	end			
if @useasbillto = 'SHP'
	begin
	update #invtemp_tbl

		set ivh_billto_name = company.cmp_name,
			 ivh_billto_addr = company.cmp_address1,
			 ivh_billto_addr2 = company.cmp_address2,		
			 ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip ,
			#invtemp_tbl.cmp_altid = company.cmp_altid 
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_shipper
	end			
			
	update #invtemp_tbl
		set originpoint_name = company.cmp_name,
			 origin_addr = company.cmp_address1,
			 origin_addr2 = company.cmp_address2,
			 origin_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_originpoint
				
	update #invtemp_tbl
		set destpoint_name = company.cmp_name,
			 dest_addr = company.cmp_address1,
			 dest_addr2 = company.cmp_address2,
			 dest_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_destpoint
				
	update #invtemp_tbl
		set shipper_name = company.cmp_name,
			 shipper_addr = company.cmp_address1,
			 shipper_addr2 = company.cmp_address2,
			 shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_shipper
			
	update #invtemp_tbl
		set consignee_name = company.cmp_name,
			 consignee_addr = company.cmp_address1,
			 consignee_addr2 = company.cmp_address2,
			 consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 

		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_consignee
				
	update #invtemp_tbl
		set stop_name = company.cmp_name,
			 stop_addr = company.cmp_address1,
			 stop_addr2 = company.cmp_address2
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.cmp_id

-- dpete for UNKNOWN companies with cities must get city name from city table	pts5319	
	update #invtemp_tbl
		set 	stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +city.cty_zip 
		from 	#invtemp_tbl, city right outer join stops on city.cty_code = stops.stp_city  --pts40012, jg, outer join conversion
		where 	#invtemp_tbl.stp_number IS NOT NULL
		and	stops.stp_number =  #invtemp_tbl.stp_number
				
/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */
select @counter = 1
while @counter <>  @copies
	begin
	select @counter = @counter + 1
 insert into #invtemp_tbl
 SELECT 
   	 ivh_invoicenumber,   
         ivh_hdrnumber, 
	 ivh_billto, 
	 ivh_billto_name ,
	 ivh_billto_addr,
	 ivh_billto_addr2,
	 ivh_billto_nmctst,
         ivh_terms,   	
         ivh_totalcharge,   
	 ivh_shipper,   
	 shipper_name,
	 shipper_addr,
	 shipper_addr2,
	 shipper_nmctst,
         ivh_consignee,   
	 consignee_name,
	 consignee_addr,
	 consignee_addr2,
	 consignee_nmctst,
         ivh_originpoint,   
	 originpoint_name,
	 origin_addr,
	 origin_addr2,
	 origin_nmctst,
         ivh_destpoint,   
	 destpoint_name,
	 dest_addr,
	 dest_addr2,
	 dest_nmctst,
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
         ivh_printdate,   
         ivh_billdate,   
         ivh_lastprintdate,   
         ivh_originregion2,   
         ivh_originregion3,   
         ivh_originregion4,   
         ivh_destregion2,   
         ivh_destregion3,   
         ivh_destregion4,   
         mfh_hdrnumber,   
         ivh_remark,   
         ivh_driver,   
         ivh_tractor,   
         ivh_trailer,   
         ivh_user_id1,   
         ivh_user_id2,   
         ivh_ref_number,   
         ivh_driver2,   
         mov_number,   
         ivh_edi_flag,   
         ord_hdrnumber,   
         ivd_number,   
         stp_number,   
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
         ivd_type,   
         ivd_rateunit,   
         ivd_billto,  
	 ivd_billto_name,
	 ivd_billto_addr,
	 ivd_billto_addr2,
	 ivd_billto_nmctst,
         ivd_itemquantity,   
         ivd_subtotalptr,   
         ivd_allocatedrev,   
         ivd_sequence,   
         ivd_refnum,   
         cmd_code, 
         cmp_id,   
	 stop_name,
	 stop_addr,
	 stop_addr2,
	 stop_nmctst,
         ivd_distance,   
         ivd_distunit,   
         ivd_wgt,   
         ivd_wgtunit,   
         ivd_count,   
         ivd_countunit,   
         evt_number,   
         ivd_reftype,   
         ivd_volume,   
         ivd_volunit,   
         ivd_orig_cmpid,   
         ivd_payrevenue,
	 ivh_freight_miles,
	 tar_tarriffnumber,
	 tar_tariffitem,
	 @counter,
	 cht_basis,
	 cht_description,
	 cmd_name,
	cmp_altid,
	ivh_batch_id,
	ivh_revenue_date,
	revtype1_name,
	revtype2_name,
	revtype3_name,
	revtype4_name,
		ivh_xferdate,
		cht_class,
		cmd_stcc,
		no_print,
		tar_number,
		ivh_order_cmd_code,
		order_cmd_name
 from #invtemp_tbl
where copies = 1   
	end 
	                                                            	
ERROR_END:
/* FINAL SELECT - FORMS RETURN SET */
select *
from #invtemp_tbl

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */
IF @@ERROR != 0 select @ret_value = @@ERROR 

return @ret_value

GO
GRANT EXECUTE ON  [dbo].[d_inv_edit_report_batch] TO [public]
GO
