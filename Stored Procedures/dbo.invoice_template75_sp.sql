SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[invoice_template75_sp] 	(@p_invoice_nbr	int, @p_copies int)
as

/**
 * 
 * NAME:
 * dbo.invoice_template75_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the invoice detail records 
 * based on the invoice number selected in the interface.
 *
 * RETURNS:
 * 0 - IF NO DATA WAS FOUND  
 * 1 - IF SUCCESFULLY EXECUTED  
 * @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_invoice_nbr, int, input, null;
 *       This parameter indicates the INVOICE NUMBER(ie.ivh_hdrnumber)
 *       for which the invoice will be printed. The value must be 
 *       non-null and non-empty.
 * 002 - @p_copies, int, input, null;
 *       This parameter indicates the number of hard copies 
 *       to print. The value must be non-null and 
 *       non-empty. 
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 * 06/19/2003 - PTS18758 - Vern Jewett - Original, copied from invoice_template11.  
 * 10/19/2005 - PTS29596 - Imari Bremer- Add logic to include stop ref numbers in the header of the invoice and exclude all ref numbers when printing a Misc. invoice
 * 06/05/2008 - PTS42937 - S. Glenn Behra - Change join syntax for performance
 **/



declare	@v_temp_name   		varchar(60)
	,@v_temp_addr   		varchar(100)
	,@v_temp_addr2  		varchar(100)
	,@v_temp_nmstct		varchar(30)
	,@v_temp_altid  		varchar(8)
        ,@v_varchar255            varchar(255)
	,@v_counter    		int
	,@v_ret_value			int	
	,@v_ls_cht_itemcode_1	varchar(6)
	,@v_ls_cht_itemcode_2	varchar(6)
	,@v_ls_cht_itemcode_3	varchar(6)
	,@v_ls_cht_itemcode_4	varchar(6)
	,@v_varchar20             varchar(20)
	,@v_minref                varchar(20)
        ,@v_minseq                int
        ,@v_ORD_HDR               INT
        ,@v_last_seq 		int
        ,@v_next_seq 		int
        ,@v_i 			INT
        ,@v_sql 			Nvarchar(1024)
        ,@v_minstp                int
        ,@v_minord		int
	,@v_refnums		varchar(255)
	,@v_stop_len 		int
	,@v_stop_refnumbers	varchar(255)
	,@v_stop_refnums		varchar(255)
        ,@v_varchar30             varchar(30)
	--reed
	,@v_rs2 			varchar(200)
        ,@v_cnt2 			int,
        @v_ivd_number int,		-- NQ
        @v_ivd_refnum varchar(30)	-- NQ
	--reed


/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @v_ret_value = 1

/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET */
CREATE TABLE #invtemp_tbl
(ivh_invoicenumber varchar(12) not null ,     
 ivh_hdrnumber int null,   
 ivh_billto varchar(8) null,   
 ivh_billto_name varchar(100) null,  
 ivh_billto_addr varchar(100) null,  
 ivh_billto_addr2 varchar(100)null,           
 ivh_billto_nmctst varchar(30)null,  
 ivh_terms char(3) null,      
 ivh_totalcharge money null,     
 ivh_shipper varchar(8) null,     
 shipper_name varchar(100) null ,  
 shipper_addr varchar(100) null,  
 shipper_addr2 varchar(100) null,  
 shipper_nmctst varchar(30) null,  
 ivh_consignee varchar(8) null,     
 consignee_name varchar(100) null,  
 consignee_addr varchar(100) null,  
 consignee_addr2 varchar(100) null ,  
 consignee_nmctst varchar(30) null,  
 ivh_originpoint varchar(8)null,     
 originpoint_name varchar(100) null,  
 origin_addr varchar(100) null,  
 origin_addr2 varchar(100) null,  
 origin_nmctst varchar(30) null,  
 ivh_destpoint varchar(8) null,     
 destpoint_name varchar(100) null,  
 dest_addr varchar(100) null,  
 dest_addr2 varchar(100) null,  
 dest_nmctst varchar(30) null,
 ivh_invoicestatus varchar(6) null,     
 ivh_origincity int null,     
 ivh_destcity int null,     
 ivh_originstate char(2) null,     
 ivh_deststate char(2) null,  
 ivh_originregion1 varchar(6) null,     
 ivh_destregion1 varchar(6) null,     
 ivh_supplier varchar(8)null,     
 ivh_shipdate datetime null,     
 ivh_deliverydate datetime null,     
 ivh_revtype1 varchar(6) null,     
 ivh_revtype2 varchar(6) null,     
 ivh_revtype3 varchar(6) null,     
 ivh_revtype4 varchar(6) null,
 ivh_totalweight float null,     
 ivh_totalpieces float null,     
 ivh_totalmiles float null,     
 ivh_currency varchar(6) null,     
 ivh_currencydate datetime null ,     
 ivh_totalvolume float null,     
 ivh_taxamount1 money null,     
 ivh_taxamount2 money null,     
 ivh_taxamount3 money null,     
 ivh_taxamount4 money null,     
 ivh_transtype varchar(6) null,     
 ivh_creditmemo char(1) null,     
 ivh_applyto varchar(12)null,     
 ivh_printdate datetime null,     
 ivh_billdate datetime null,     
 ivh_lastprintdate datetime null,     
 ivh_originregion2 varchar(6) null,     
 ivh_originregion3 varchar(6) null,     
 ivh_originregion4 varchar(6) null,     
 ivh_destregion2 varchar(6) null,     
 ivh_destregion3 varchar(6) null,     
 ivh_destregion4 varchar(6) null,     
 mfh_hdrnumber int null,     
 ivh_remark varchar(254) null,     
 ivh_driver varchar(8) null,     
 ivh_tractor varchar(8) null,     
 ivh_trailer varchar(13),     
 ivh_user_id1 char(20) null,     
 ivh_user_id2 char(20) null,     
 ivh_ref_number varchar(30) null,     
 ivh_driver2 varchar(8) null,     
 mov_number int null,     
 ivh_edi_flag char(30) null,     
 ord_hdrnumber int null,    
 ivd_number int null,     
 stp_number int null,     
 ivd_description varchar(254) null,     
 cht_itemcode varchar(6) null,     
 ivd_quantity float null,     
 ivd_rate money null,     
 ivd_charge money null,  
 ivd_taxable1 char(1) null, 
 ivd_taxable2 char(1) null, 
 ivd_taxable3 char(1) null, 
 ivd_taxable4 char(1) null, 
 ivd_unit char(6) null,     
 cur_code char(6) null,     
 ivd_currencydate datetime null,     
 ivd_glnum char(32) null,     
 ivd_type char(6) null,     
 ivd_rateunit char(6) null,     
 ivd_billto char(8) null,     
 ivd_billto_name varchar(100) null,  
 ivd_billto_addr varchar(100) null,  
 ivd_billto_addr2 varchar(100) null,  
 ivd_billto_nmctst varchar(30) null,  
 ivd_itemquantity float null,     
 ivd_subtotalptr int null,     
 ivd_allocatedrev money null,     
 ivd_sequence int null,     
 ivd_refnum varchar(30)null,     
 cmd_code varchar(8) null,     
 cmp_id varchar(8) null,     
 stop_name varchar(100) null,  
 stop_addr varchar(100) null,  
 stop_addr2 varchar(100) null,  
 stop_nmctst varchar(30) null,  
 ivd_distance float null,     
 ivd_distunit varchar(6) null,     
 ivd_wgt float null,     
 ivd_wgtunit varchar(6) null,     
 ivd_count decimal(10,2) null,     
 ivd_countunit char(6) null,     
 evt_number int null,     
 ivd_reftype varchar(6) null,     
 ivd_volume float null,     
 ivd_volunit char(6) null,     
 ivd_orig_cmpid char(8) null,     
 ivd_payrevenue money null,  
 ivh_freight_miles float null,  
 tar_tarriffnumber varchar(12) null,  
 tar_tariffitem varchar(12) null,  
 copies int null,  
 cht_basis varchar(6)null,  
 cht_description varchar(30) null,  
 cmd_name varchar(60),  
 cmp_altid varchar(25) null,  
 ivh_hideshipperaddr char(1) null,  
 ivh_hideconsignaddr char(1) null,  
 ivh_showshipper varchar(8) null,  
 ivh_showcons varchar(8) null,  


 ivh_charge money null,  
 subtotal_section int null,
 ord_bol1 varchar(30) null,
 ord_bol2 varchar(30) null,
 ord_bol3 varchar(30) null,
 ord_bol4 varchar(30) null,
 ord_bol5 varchar(30) null,
 refnums varchar(255) null,
 stop_refnumbers varchar(255)null) 

/* NOTE: 'COPY' - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/
INSERT INTO #invtemp_tbl
SELECT ivh.ivh_invoicenumber,   
         ivh.ivh_hdrnumber, 
		 ivh.ivh_billto, 
		 @v_temp_name ivh_billto_name ,
		 @v_temp_addr 	ivh_billto_addr,
		 @v_temp_addr2	ivh_billto_addr2,
		 @v_temp_nmstct ivh_billto_nmctst,
         ivh.ivh_terms,   	
         ivh.ivh_totalcharge,   
		 ivh.ivh_shipper,   
		 @v_temp_name	shipper_name,
		 @v_temp_addr	shipper_addr,
		 @v_temp_addr2	shipper_addr2,
		 @v_temp_nmstct shipper_nmctst,
         ivh.ivh_consignee,   
		 @v_temp_name consignee_name,
		 @v_temp_addr consignee_addr,
		 @v_temp_addr2	consignee_addr2,
		 @v_temp_nmstct consignee_nmctst,
         ivh.ivh_originpoint,   
		 @v_temp_name originpoint_name,
		 @v_temp_addr origin_addr,
		 @v_temp_addr2	origin_addr2,
		 @v_temp_nmstct origin_nmctst,
         ivh.ivh_destpoint,   
		 @v_temp_name destpoint_name,
		 @v_temp_addr dest_addr,
		 @v_temp_addr2	dest_addr2,
		 @v_temp_nmstct dest_nmctst,
         ivh.ivh_invoicestatus,   
         ivh.ivh_origincity,   
         ivh.ivh_destcity,   
         ivh.ivh_originstate,   
         ivh.ivh_deststate,
         ivh.ivh_originregion1,   
         ivh.ivh_destregion1,   
         ivh.ivh_supplier,   
         ivh.ivh_shipdate,   
         ivh.ivh_deliverydate,   
         ivh.ivh_revtype1,   
         ivh.ivh_revtype2,   
         ivh.ivh_revtype3,   
         ivh.ivh_revtype4,   
         ivh.ivh_totalweight,   
         ivh.ivh_totalpieces,   
         ivh.ivh_totalmiles,   
         ivh.ivh_currency,   
         ivh.ivh_currencydate,   
         ivh.ivh_totalvolume,   
         ivh.ivh_taxamount1,   
         ivh.ivh_taxamount2,   
         ivh.ivh_taxamount3,   
         ivh.ivh_taxamount4,   
         ivh.ivh_transtype,   
         ivh.ivh_creditmemo,   
         ivh.ivh_applyto,   
         ivh.ivh_printdate,   
         ivh.ivh_billdate,   
         ivh.ivh_lastprintdate,   
         ivh.ivh_originregion2,   
         ivh.ivh_originregion3,   
         ivh.ivh_originregion4,   
         ivh.ivh_destregion2,   
         ivh.ivh_destregion3,   
         ivh.ivh_destregion4,   
         ivh.mfh_hdrnumber,   
         ivh.ivh_remark,   
         ivh.ivh_driver,   
         ivh.ivh_tractor,   
         ivh.ivh_trailer,   
         ivh.ivh_user_id1,   
         ivh.ivh_user_id2,   
         ivh.ivh_ref_number,   
         ivh.ivh_driver2,   
         ivh.mov_number,   
         ivh.ivh_edi_flag,   
         ivh.ord_hdrnumber,   
         ivd.ivd_number,   
         ivd.stp_number,   
         ivd.ivd_description,   
         ivd.cht_itemcode,   
         ivd.ivd_quantity,   
         ivd.ivd_rate,   
         ivd.ivd_charge,   
         ivd.ivd_taxable1,   
         ivd.ivd_taxable2,   
		 ivd.ivd_taxable3,   
         ivd.ivd_taxable4,   
         ivd.ivd_unit,   
         ivd.cur_code,   
         ivd.ivd_currencydate,   
         ivd.ivd_glnum,   
         ivd.ivd_type,   
         ivd.ivd_rateunit,   
         ivd.ivd_billto,   
		 @v_temp_name ivd_billto_name,
		 @v_temp_addr ivd_billto_addr,
		 @v_temp_addr2	ivd_billto_addr2,
		 @v_temp_nmstct ivd_billto_nmctst,
         ivd.ivd_itemquantity,   
         ivd.ivd_subtotalptr,   
         ivd.ivd_allocatedrev,   
         ivd.ivd_sequence,   
         ivd.ivd_refnum,   
         ivd.cmd_code,   
         ivd.cmp_id,   
		 @v_temp_name	stop_name,
		 @v_temp_addr	stop_addr,
		 @v_temp_addr2	stop_addr2,
		 @v_temp_nmstct stop_nmctst,
         ivd.ivd_distance,   
         ivd.ivd_distunit,   
         ivd.ivd_wgt,   
         ivd.ivd_wgtunit,   
         ivd.ivd_count,   
		 ivd.ivd_countunit,   
         ivd.evt_number,   
         ivd.ivd_reftype,   
         ivd.ivd_volume,   
         ivd.ivd_volunit,   
         ivd.ivd_orig_cmpid,   
         ivd.ivd_payrevenue,
		 ivh.ivh_freight_miles,
		 ivh.tar_tarriffnumber,
		 ivh.tar_tariffitem,
		 1 copies,
		 cht.cht_basis,
		 cht.cht_description,
		 cmd.cmd_name,
		 @v_temp_altid cmp_altid,
		 ivh_hideshipperaddr,
		 ivh_hideconsignaddr,
		 (Case ivh_showshipper 
			when 'UNKNOWN' then ivh.ivh_shipper
			else IsNull(ivh_showshipper,ivh.ivh_shipper) 
		 	end) ivh_showshipper,
		 (Case ivh_showcons 
			when 'UNKNOWN' then ivh.ivh_consignee
			else IsNull(ivh_showcons,ivh.ivh_consignee) 
			end) ivh_showcons,
		 IsNull(ivh_charge,0.0) ivh_charge,
		 (case	ivd.cht_itemcode
			when '*FES' then 3
			else 1
			end) subtotal_section,
                  @v_varchar20 ord_bol1,
                  @v_varchar20 ord_bol2,
                  @v_varchar20 ord_bol3,
                  @v_varchar20 ord_bol4,
                  @v_varchar20 ord_bol5,
                  isnull(@v_varchar255,'') refnums,
                  -- PTS 56371 NQIAO 04/25/2011 starts
                  --isnull(@v_varchar255,'') stop_refnumber
                  isnull(ivd_refnum, isnull(@v_varchar255,'')) stop_refnumber   -- PTS 56371 NQIAO 04/25/2011 ends
 /* PTS 42937 SGB 06/05/2008 Changed Join syntax for performance                  
  FROM invoiceheader AS ivh JOIN invoicedetail as ivd ON ( ivd.ivh_hdrnumber = ivh.ivh_hdrnumber ) 
       RIGHT OUTER JOIN chargetype as cht ON (cht.cht_itemcode = ivd.cht_itemcode)
       LEFT OUTER JOIN commodity as cmd ON (ivd.cmd_code = cmd.cmd_code)
  */
  	FROM invoiceheader AS ivh JOIN invoicedetail as ivd ON  ivd.ivh_hdrnumber = ivh.ivh_hdrnumber 
		   LEFT OUTER JOIN chargetype as cht ON ivd.cht_itemcode = cht.cht_itemcode 
       LEFT OUTER JOIN commodity as cmd ON ivd.cmd_code = cmd.cmd_code
 WHERE ivh.ivh_hdrnumber = @p_invoice_nbr
--FROM	 invoiceheader, 
--		 invoicedetail, 
--		 chargetype, 
--		 commodity
--  WHERE	 ( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber )
--	and	 (chargetype.cht_itemcode =* invoicedetail.cht_itemcode) 
--	and	 (invoicedetail.cmd_code *= commodity.cmd_code) 
--	and	 invoiceheader.ivh_hdrnumber =  @p_invoice_nbr
	
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */
if (select count(*) from #invtemp_tbl) = 0
	begin
	select @v_ret_value = 0  
	GOTO ERROR_END
	end


/* RETRIEVE COMPANY DATA */	                   			
  If Not Exists (Select cmp_mailto_name From company c, #invtemp_tbl t
        Where c.cmp_id = t.ivh_billto
			And Rtrim(IsNull(cmp_mailto_name,'')) > ''
			And t.ivh_terms in (c.cmp_mailto_crterm1,	c.cmp_mailto_crterm2,	c.cmp_mailto_crterm3,	
				Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)
			And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End	)	

		update #invtemp_tbl
		set ivh_billto_name = company.cmp_name,
			 ivh_billto_addr = company.cmp_address1,
			 ivh_billto_addr2 = company.cmp_address2,		
			 ivh_billto_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip,
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

update #invtemp_tbl
set originpoint_name = company.cmp_name,
	origin_addr = company.cmp_address1,
	origin_addr2 = company.cmp_address2,
	origin_nmctst = substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip ,'')
from #invtemp_tbl, company, city
where company.cmp_id = #invtemp_tbl.ivh_originpoint
	and city.cty_code = #invtemp_tbl.ivh_origincity   
	
update #invtemp_tbl
set destpoint_name = company.cmp_name,
	dest_addr = company.cmp_address1,
	dest_addr2 = company.cmp_address2,
	dest_nmctst =substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,'') 
from #invtemp_tbl, company, city
where company.cmp_id = #invtemp_tbl.ivh_destpoint
	and city.cty_code =  #invtemp_tbl.ivh_destcity 
				
update #invtemp_tbl
set shipper_name = company.cmp_name,
	shipper_addr = Case ivh_hideshipperaddr when 'Y' 
				then ''
				else company.cmp_address1
			end,
	shipper_addr2 = Case ivh_hideshipperaddr when 'Y' 
				then ''
				else company.cmp_address2
			end,
	shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip 
from #invtemp_tbl, company
where company.cmp_id = #invtemp_tbl.ivh_showshipper

-- There is no shipper city, so if the shipper is UNKNOWN, use the origin city to get the nmstct  
update #invtemp_tbl
set shipper_nmctst = origin_nmctst
from #invtemp_tbl
where #invtemp_tbl.ivh_shipper = 'UNKNOWN'
								
update #invtemp_tbl
set consignee_name = company.cmp_name,
	consignee_addr = Case ivh_hideconsignaddr when 'Y' 
				then ''
				else company.cmp_address1
			end,			 
	consignee_addr2 = Case ivh_hideconsignaddr when 'Y' 
				then ''
				else company.cmp_address2
			end,
	consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
from #invtemp_tbl, company
where company.cmp_id = #invtemp_tbl.ivh_showcons
				
	
-- There is no consignee city, so if the consignee is UNKNOWN, use the dest city to get the nmstct  
update #invtemp_tbl
set consignee_nmctst = dest_nmctst
from #invtemp_tbl
where #invtemp_tbl.ivh_consignee = 'UNKNOWN'	
		
update #invtemp_tbl
set stop_name = company.cmp_name,
	stop_addr = company.cmp_address1,
	stop_addr2 = company.cmp_address2
from #invtemp_tbl, company
where company.cmp_id = #invtemp_tbl.cmp_id

-- dpete for UNKNOWN companies with cities must get city name from city table	pts5319	
update #invtemp_tbl
set   stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +city.cty_zip 
from  stops JOIN #invtemp_tbl ON (stops.stp_number = #invtemp_tbl.stp_number) 
      RIGHT OUTER JOIN city ON (city.cty_code = stops.stp_city )
where #invtemp_tbl.stp_number IS NOT NULL  

--where #invtemp_tbl.stp_number IS NOT NULL 
--from 	#invtemp_tbl, stops,city
--where 	#invtemp_tbl.stp_number IS NOT NULL
--	and	stops.stp_number =  #invtemp_tbl.stp_number
--	and	city.cty_code =* stops.stp_city

--If ivh_currency is blank, get it from the Bill-To Company profile..
update	#invtemp_tbl

  set	ivh_currency = c.cmp_currency
  from	#invtemp_tbl i
		,company c
  where	(i.ivh_currency is null
		or i.ivh_currency = '?'
		or i.ivh_currency = 'UNK'
		or i.ivh_currency = '')
	and	c.cmp_id = i.ivh_billto


--Set subtotal_section to 2 on rows which are Fuel Surcharge; start by getting the
--set of charge types which belong in this section from GeneralInfo..
select	@v_ls_cht_itemcode_1 = gi_string1
		,@v_ls_cht_itemcode_2 = gi_string2
		,@v_ls_cht_itemcode_3 = gi_string3
		,@v_ls_cht_itemcode_4 = gi_string4
  from	generalinfo
  where	gi_name = 'FuelSurchargeChargeTypes'

update	#invtemp_tbl
  set	subtotal_section = 2
  where	cht_itemcode in (@v_ls_cht_itemcode_1, @v_ls_cht_itemcode_2, @v_ls_cht_itemcode_3, 
							@v_ls_cht_itemcode_4)


--PTS# 18296 ILB
set @v_last_seq = 0
set @v_next_seq = 0
set @v_i = 1
select @v_ord_hdr = (select min(ord_hdrnumber) from #invtemp_tbl) 

While 1=1
BEGIN
 select @v_next_seq = min(ref_sequence)
   from referencenumber
  where ref_type = 'BL#' AND
	ref_table = 'orderheader' AND
	ref_tablekey = @v_ord_hdr AND
	ref_sequence > @v_last_seq

-- PTS 20247 -- BL (start)
-- if @v_last_seq is null BREAK
 if @v_next_seq is null BREAK
-- PTS 20247 -- BL (end)

 Select @v_minref = ref_number 
   from referencenumber 
  where ref_type = 'BL#' AND
	ref_table = 'orderheader' AND
	ref_tablekey = @v_ord_hdr AND
	ref_sequence = @v_next_seq

 if @v_i > 5 BREAK
 
 SELECT @v_sql = 'update #invtemp_tbl set ord_bol'+ convert(varchar, @v_i) +' = ''' + @v_minref + ''''
 exec sp_executesql @v_sql

 select @v_i = @v_i +1
 select @v_last_seq = @v_next_seq
END


--new code
--include order-level refnums and any stops-level refnums of type BL#
--in comma-separated list with ref_type
begin
--declare @v_num varchar(12)
declare @v_rs varchar(200)
declare @v_cnt int
select @v_rs = ','
select @v_cnt = 0
while 1=1
begin
	select @v_cnt = min(ref_sequence)
	from referencenumber
	where 	ord_hdrnumber = @v_ord_hdr
		and (ref_table='orderheader' and ord_hdrnumber <> 0
		or (ref_table='stops' and ref_type='BL#' and ord_hdrnumber <> 0))
		and ref_sequence > @v_cnt
	if @v_cnt is NULL BREAK
		select @v_rs = @v_rs + ref_type + ': ' + ref_number + ', ' 
		from referencenumber 
		where ord_hdrnumber = @v_ord_hdr
		and (ref_table='orderheader' and ord_hdrnumber<>0
		or (ref_table='stops' and ref_type='BL#' and ord_hdrnumber <> 0))
		and ref_sequence = @v_cnt
end
end


Update #invtemp_tbl
   set refnums = substring(LEFT(@v_rs, len(@v_rs)-1), 2, len(@v_rs)) 

set @v_minstp = 0
set @v_minref = ''
set @v_minseq = 0
set @v_minord = 0
set @v_stop_refnumbers = ''
set @v_stop_refnums = ''

while 1=1

begin

	select 	@v_minstp = min(stp_number)
	from 	#invtemp_tbl  
	where	stp_number > @v_minstp

	if @v_minstp is NULL BREAK

--	select @v_minstp
	select @v_rs2= ','
	select @v_cnt2 = 0

			while 1=1
			begin
				select @v_cnt2 = min(ref_sequence)
				from referencenumber
				where ref_tablekey = @v_minstp
					and ref_table = 'stops'
					and ref_sequence > @v_cnt2
				if @v_cnt2 is NULL BREAK
			
					select @v_rs2= @v_rs2+ ref_type +': '+ref_number + ', '
					from referencenumber 
					where ref_tablekey = @v_minstp
					and ref_table = 'stops'
					and ref_sequence = @v_cnt2
			end

			update #invtemp_tbl
			set stop_refnumbers = substring(LEFT(@v_rs2, len(@v_rs2)-1), 2, len(@v_rs2))
			where 	stp_number = @v_minstp

end

-- PTS 56371 NQIAO 04/25/2011 <START>
while 1=1
begin
	select	@v_ivd_number = min(ivd_number)
	from	#invtemp_tbl
	where ivd_number > isnull(@v_ivd_number, '')
	
	if @v_ivd_number is NULL BREAK
	
	select 	@v_ivd_refnum = ivd_reftype + ': ' + ivd_refnum
	from	invoicedetail
	where	ivh_hdrnumber = @p_invoice_nbr
	and		ivd_number = @v_ivd_number
	 
	update #invtemp_tbl
	set stop_refnumbers = @v_ivd_refnum
	where ivd_number = @v_ivd_number
end
-- PTS 56371 NQIAO 04/25/2011 <END>

/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */
select @v_counter = 1
while @v_counter <>  @p_copies
begin
	select @v_counter = @v_counter + 1

	insert into #invtemp_tbl
 	  SELECT  ivh_invoicenumber,   
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
		 @v_counter,
		 cht_basis,
		 cht_description,
		 cmd_name,
		 cmp_altid,
		 ivh_hideshipperaddr,
		 ivh_hideconsignaddr,
		 ivh_showshipper,
		 ivh_showcons,
		 IsNull(ivh_charge,0) ivh_charge,
		 subtotal_section,
		 ord_bol1,
          	 ord_bol2,
          	 ord_bol3,
          	 ord_bol4,
          	 ord_bol5,
                 refnums,
                 stop_refnumbers
	  from #invtemp_tbl
	  where copies = 1   
end 
                                                          	
ERROR_END:
/* FINAL SELECT - FORMS RETURN SET */
select	 ivh_invoicenumber,   
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
		 copies,
		 cht_basis,
		 cht_description,
		 cmd_name,
		 ivh_showshipper,
	 	 ivh_showcons,
		 subtotal_section,
          ord_bol1,
          ord_bol2,

          ord_bol3,
          ord_bol4,
          ord_bol5,
          refnums,
          stop_refnumbers
from #invtemp_tbl

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */
IF @@ERROR != 0 select @v_ret_value = @@ERROR 
return @v_ret_value
GO
GRANT EXECUTE ON  [dbo].[invoice_template75_sp] TO [public]
GO
