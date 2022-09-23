SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[invoice_template126](@invoice_nbr  	INTEGER,
                                     @copies		INTEGER)
as
/*	PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND
	1 - IF SUCCESFULLY EXECUTED
	@@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS

2/2/99 add cmp_altid from useasbillto company to return set
1/5/00 dpete PTS6469 if you have an UNKNOWN consignee or shipper (origin or dest) use the city name in the city table
06/29/2001	Vern Jewett		vmj1	PTS 10870: not returning copy # correctly.
12/5/2 16314 DPETE use GI settings to control terms and linehaul restricitons on mail to
 * 11/30/2007.01 - PTS40464 - JGUO - convert old style outer join syntax to ansi outer join syntax.
*/

DECLARE	@temp_name   	VARCHAR(30) ,
	@temp_addr   	VARCHAR(30) ,
	@temp_addr2  	VARCHAR(30),
	@temp_nmstct 	VARCHAR(30),
	@temp_altid  	VARCHAR(8),
	@counter    	INTEGER,
	@ret_value  	INTEGER,
	@dispatch_date	DATETIME,
	@mov_number	INTEGER

CREATE TABLE #invtemp_tbl
(
	ivh_invoicenumber 	VARCHAR(12) NULL,
	ivh_hdrnumber		INTEGER NULL,
	ivh_billto		VARCHAR(8) NULL,
	ivh_billto_name		VARCHAR(100) NULL,
	ivh_billto_addr		VARCHAR(100) NULL,
	ivh_billto_addr2	VARCHAR(100) NULL,
	ivh_billto_nmctst	VARCHAR(25) NULL,
	ivh_terms		VARCHAR(3) NULL,
	ivh_totalcharge		MONEY NULL,
	ivh_shipper		VARCHAR(8) NULL,
	shipper_name		VARCHAR(100) NULL,
	shipper_addr		VARCHAR(100) NULL,
	shipper_addr2		VARCHAR(100) NULL,
	shipper_nmctst		VARCHAR(25) NULL,
	ivh_consignee		VARCHAR(8) NULL,
	consignee_name		VARCHAR(100) NULL,
	consignee_addr		VARCHAR(100) NULL,
	consignee_addr2		VARCHAR(100) NULL,
	consignee_nmctst	VARCHAR(25) NULL,
	ivh_originpoint		VARCHAR(8) NULL,
	originpoint_name	VARCHAR(100) NULL,
	origin_addr		VARCHAR(100) NULL,
	origin_addr2		VARCHAR(100) NULL,
	origin_nmctst		VARCHAR(25) NULL,
	ivh_destpoint		VARCHAR(8) NULL,
	destpoint_name		VARCHAR(100) NULL,
	dest_addr		VARCHAR(100) NULL,
	dest_addr2		VARCHAR(100) NULL,
	dest_nmctst		VARCHAR(25) NULL,
	ivh_invoicestatus	VARCHAR(6) NULL,   
        ivh_origincity		INTEGER NULL,   
        ivh_destcity		INTEGER NULL,   
        ivh_originstate		VARCHAR(2) NULL,   
        ivh_deststate		VARCHAR(2) NULL,
        ivh_originregion1	VARCHAR(6) NULL,   
        ivh_destregion1		VARCHAR(6) NULL,   
        ivh_supplier		VARCHAR(8) NULL,   
        ivh_shipdate		DATETIME NULL,   
        ivh_deliverydate	DATETIME NULL,   
        ivh_revtype1		VARCHAR(6) NULL,   
        ivh_revtype2		VARCHAR(6) NULL,   
        ivh_revtype3		VARCHAR(6) NULL,   
        ivh_revtype4		VARCHAR(6) NULL,   
        ivh_totalweight		FLOAT NULL,   
        ivh_totalpieces		FLOAT NULL,   
        ivh_totalmiles		FLOAT NULL,   
        ivh_currency		VARCHAR(6) NULL,   
        ivh_currencydate	DATETIME NULL,   
        ivh_totalvolume		FLOAT NULL,   
        ivh_taxamount1		MONEY NULL,   
        ivh_taxamount2		MONEY NULL,   
        ivh_taxamount3		MONEY NULL,   
        ivh_taxamount4		MONEY NULL,   
        ivh_transtype		VARCHAR(6) NULL,   
        ivh_creditmemo		CHAR(1) NULL,   
        ivh_applyto		VARCHAR(12) NULL,   
        ivh_printdate		DATETIME NULL,   
        ivh_billdate		DATETIME NULL,   
        ivh_lastprintdate	DATETIME NULL,   
        ivh_originregion2	VARCHAR(6) NULL,   
        ivh_originregion3	VARCHAR(6) NULL,
	ivh_originregion4	VARCHAR(6) NULL,   
        ivh_destregion2		VARCHAR(6) NULL,   
        ivh_destregion3		VARCHAR(6) NULL,   
        ivh_destregion4		VARCHAR(6) NULL,   
        mfh_hdrnumber		INTEGER NULL,   
        ivh_remark		VARCHAR(254) NULL,   
        ivh_driver		VARCHAR(8) NULL,   
        ivh_tractor		VARCHAR(8) NULL,   
        ivh_trailer		VARCHAR(13) NULL,   
        ivh_user_id1		VARCHAR(20) NULL,   
        ivh_user_id2		VARCHAR(20) NULL,   
        ivh_ref_number		VARCHAR(30) NULL,   
        ivh_driver2		VARCHAR(8) NULL,   
        mov_number		INTEGER NULL,   
        ivh_edi_flag		VARCHAR(30) NULL,   
        ord_hdrnumber		INTEGER NULL,   
        ivd_number		INTEGER NULL,   
        stp_number		INTEGER NULL,   
        ivd_description		VARCHAR(60) NULL,   
        cht_itemcode		VARCHAR(6) NULL,   
        ivd_quantity		FLOAT NULL,   
        ivd_rate		MONEY NULL,   
        ivd_charge		MONEY NULL,   
        ivd_taxable1		CHAR(1) NULL,   
        ivd_taxable2		CHAR(1) NULL,   
	ivd_taxable3		CHAR(1) NULL,   
        ivd_taxable4		CHAR(1) NULL,   
        ivd_unit		VARCHAR(6) NULL,   
        cur_code		VARCHAR(6) NULL,   
        ivd_currencydate	DATETIME NULL,   
        ivd_glnum		VARCHAR(32) NULL,   
        ivd_type		VARCHAR(6) NULL,   
        ivd_rateunit		VARCHAR(6) NULL,   
        ivd_billto		VARCHAR(8) NULL,   
	ivd_billto_name		VARCHAR(100) NULL,
	ivd_billto_addr		VARCHAR(100) NULL,
	ivd_billto_addr2	VARCHAR(100) NULL,
	ivd_billto_nmctst	VARCHAR(25) NULL,
        ivd_itemquantity	FLOAT NULL,   
        ivd_subtotalptr		INTEGER NULL,   
        ivd_allocatedrev	MONEY NULL,   
        ivd_sequence		INTEGER NULL,   
        ivd_refnum		VARCHAR(30) NULL,   
        cmd_code		VARCHAR(8) NULL,   
        cmp_id			VARCHAR(8) NULL,   
	stop_name		VARCHAR(100) NULL,
	stop_addr		VARCHAR(100) NULL,
	stop_addr2		VARCHAR(100) NULL,
	stop_nmctst		VARCHAR(25) NULL,
        ivd_distance		FLOAT NULL,   
        ivd_distunit		VARCHAR(6) NULL,   
        ivd_wgt			FLOAT NULL,   
        ivd_wgtunit		VARCHAR(6) NULL,   
        ivd_count		DECIMAL(10,2) NULL,   
	ivd_countunit		VARCHAR(6) NULL,   
        evt_number		INTEGER NULL,   
        ivd_reftype		VARCHAR(6) NULL,   
        ivd_volume		FLOAT NULL,   
        ivd_volunit		VARCHAR(6) NULL,   
        ivd_orig_cmpid		VARCHAR(8) NULL,   
        ivd_payrevenue		MONEY NULL,
	ivh_freight_miles	FLOAT NULL,
	tar_tarriffnumber	VARCHAR(12) NULL,
	tar_tariffitem		VARCHAR(12) NULL,
	copies			INTEGER NULL,
	cht_basis		VARCHAR(6) NULL,
	cht_description		VARCHAR(30) NULL,
	cmd_name		VARCHAR(60) NULL,
	cmp_altid		VARCHAR(25) NULL,
	ivh_hideshipperaddr	CHAR(1) NULL,
	ivh_hideconsignaddr	CHAR(1) NULL,
	ivh_showshipper		VARCHAR(8) NULL,
	ivh_showcons		VARCHAR(8) NULL,
	ivh_charge		MONEY NULL,
	dispatch_date		DATETIME NULL
)

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1

/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET 
	NOTE: 'COPY' - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/
INSERT INTO #invtemp_tbl
   SELECT invoiceheader.ivh_invoicenumber,   
          invoiceheader.ivh_hdrnumber, 
	  invoiceheader.ivh_billto, 
	  @temp_name,
	  @temp_addr,
	  @temp_addr2,
	  @temp_nmstct,
          invoiceheader.ivh_terms,   	
          invoiceheader.ivh_totalcharge,   
	  invoiceheader.ivh_shipper,   
	  @temp_name,
	  @temp_addr,
	  @temp_addr2,
	  @temp_nmstct,
          invoiceheader.ivh_consignee,   
	  @temp_name,
	  @temp_addr,
	  @temp_addr2,
	  @temp_nmstct,
          invoiceheader.ivh_originpoint,   
	  @temp_name,
	  @temp_addr,
	  @temp_addr2,
	  @temp_nmstct,
          invoiceheader.ivh_destpoint,   
	  @temp_name,
	  @temp_addr,
	  @temp_addr2,
	  @temp_nmstct,
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
	  @temp_name,
	  @temp_addr,
	  @temp_addr2,
	  @temp_nmstct,
          invoicedetail.ivd_itemquantity,   
          invoicedetail.ivd_subtotalptr,   
          invoicedetail.ivd_allocatedrev,   
          invoicedetail.ivd_sequence,   
          invoicedetail.ivd_refnum,   
          invoicedetail.cmd_code,   
          invoicedetail.cmp_id,   
	  @temp_name,
	  @temp_addr,
	  @temp_addr2,
	  @temp_nmstct,
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
	  1,
	  chargetype.cht_basis,
	  chargetype.cht_description,
	  commodity.cmd_name,
	  @temp_altid,
	  ivh_hideshipperaddr,
	  ivh_hideconsignaddr,
	  (Case ivh_showshipper 
		when 'UNKNOWN' then invoiceheader.ivh_shipper
		else IsNull(ivh_showshipper,invoiceheader.ivh_shipper) 
	  end),
	  (Case ivh_showcons 
		when 'UNKNOWN' then invoiceheader.ivh_consignee
		else IsNull(ivh_showcons,invoiceheader.ivh_consignee) 
	  end),
	  IsNull(ivh_charge,0.0),
	  @dispatch_date
    FROM chargetype  RIGHT OUTER JOIN  invoicedetail  ON  chargetype.cht_itemcode  = invoicedetail.cht_itemcode   
		LEFT OUTER JOIN  commodity  ON  invoicedetail.cmd_code  = commodity.cmd_code ,
		invoiceheader 
   WHERE ( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and
--	 (chargetype.cht_itemcode =* invoicedetail.cht_itemcode) and
--	 (invoicedetail.cmd_code *= commodity.cmd_code) and
	  invoiceheader.ivh_hdrnumber =  @invoice_nbr
	-- ( invoiceheader.ivh_hdrnumber between @invoice_no_lo and @invoice_no_hi) AND
   --	 ( @invoice_status  in ('ALL', invoiceheader.ivh_invoicestatus)) and
	-- ( @revtype1 in('UNK', invoiceheader.ivh_revtype1)) and
	-- ( @revtype2 in('UNK', invoiceheader.ivh_revtype2)) and  			
  --       ( @revtype3 in('UNK', invoiceheader.ivh_revtype3)) and  
  --       ( @revtype4 in('UNK', invoiceheader.ivh_revtype4)) and
	-- ( @billto in ('UNKNOWN',invoiceheader.ivh_billto)) and
	-- ( @shipper in ('UNKNOWN', invoiceheader.ivh_shipper)) and
	-- ( @consignee in ('UNKNOWN',invoiceheader.ivh_consignee)) and
	-- (invoiceheader.ivh_shipdate between @shipdate1 and @shipdate2 ) and
   --      (invoiceheader.ivh_deliverydate between @deldate1 and @deldate2) and
	-- ((invoiceheader.ivh_billdate between @billdate1 and @billdate2) or
	-- (invoiceheader.ivh_billdate IS null))
	
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */
if (select count(*) from #invtemp_tbl) = 0
	begin
	select @ret_value = 0  
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
set 	stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +city.cty_zip 
from 	#invtemp_tbl, city  RIGHT OUTER JOIN  stops  ON  city.cty_code  = stops.stp_city
where 	#invtemp_tbl.stp_number IS NOT NULL
	and	stops.stp_number =  #invtemp_tbl.stp_number
	--and	city.cty_code =* stops.stp_city

UPDATE #invtemp_tbl
   SET dispatch_date = stops.stp_arrivaldate
  FROM #invtemp_tbl join stops ON #invtemp_tbl.mov_number = stops.mov_number AND
                                  stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)
                                                        FROM stops
                                                       WHERE stops.mov_number = #invtemp_tbl.mov_number and
                                                             stops.stp_event = 'HLT')
 				
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
	 ivh_hideshipperaddr,
	 ivh_hideconsignaddr,
	 ivh_showshipper,
	 ivh_showcons,
	 IsNull(ivh_charge,0) ivh_charge,
	 dispatch_date
	from #invtemp_tbl
	where copies = 1   
end 
	                                                            	
ERROR_END:
/* FINAL SELECT - FORMS RETURN SET */
select   ivh_invoicenumber,   
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

	 --vmj1+	@counter is constant for all rows!
	 copies,
--	 @counter,
	 --vmj1-

	 cht_basis,
	 cht_description,
	 cmd_name,
	 ivh_showshipper,
	 ivh_showcons,
	 ivh_charge,
         dispatch_date
from #invtemp_tbl

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */
IF @@ERROR != 0 select @ret_value = @@ERROR 
return @ret_value

GO
GRANT EXECUTE ON  [dbo].[invoice_template126] TO [public]
GO
