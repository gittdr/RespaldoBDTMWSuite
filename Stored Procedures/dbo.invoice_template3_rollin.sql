SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[invoice_template3_rollin](@invoice_nbr  	int,  @copies		int)

as
/*	PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND
	1 - IF SUCCESFULLY EXECUTED
	@@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS

addition of invoiceheader tar number and invoicedetail tariff information   to output PTS 3963 10/5/98
06/29/2001	Vern Jewett		vmj1	PTS 10870: not returning copy # correctly.
12/31/2001	Vern Jewett		vmj2	PTS 12778: Rolled-In Accessorials are getting added to another accessorial, in addition to
									the LineHaul charge. 
12/5/2 16314 DPETE use GI settings to control terms and linehaul restricitons on mail to 
 * 11/13/2007.01 ? PTS40188 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
*/


declare	@temp_name   varchar(30) ,
	@temp_addr   varchar(30) ,
	@temp_addr2  varchar(30),
	@temp_nmstct varchar(30),
	@counter    int,
	@ret_value  int	,
	@varchar8  varchar(8)

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1


/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1


/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET 
	NOTE: 'COPY' - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/


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
	 invoiceheader.tar_number,
	invoicedetail.tar_number as ivd_tarnumber,
	invoicedetail.tar_tariffnumber as ivd_tartariffnumber,
	invoicedetail.tar_tariffitem as ivd_tartariffitem,
	@varchar8 as cmp_altid,
	chargetype.cht_primary as cht_primary,
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	(Case ivh_showshipper 
		when 'UNKNOWN' then invoiceheader.ivh_shipper
		else IsNull(ivh_showshipper,invoiceheader.ivh_shipper) 
	end) ivh_showshipper,
	(Case ivh_showcons 
		when 'UNKNOWN' then invoiceheader.ivh_consignee
		else IsNull(ivh_showcons,invoiceheader.ivh_consignee) 
	end) ivh_showcons,
	IsNull(ivh_charge,0.0) ivh_charge
    into #invtemp_tbl
    FROM invoicedetail  LEFT OUTER JOIN  commodity  ON  invoicedetail.cmd_code  = commodity.cmd_code ,
		invoiceheader,
		chargetype 
   WHERE ( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and
	 (chargetype.cht_itemcode = invoicedetail.cht_itemcode) and /* JET removed outer join 10/5/98 */
-- LOR PTS# 15875      (chargetype.cht_rollintolh = 0) AND 
       (IsNUll(invoicedetail.cht_rollintolh,0) = 0) AND 
	invoiceheader.ivh_hdrnumber = @invoice_nbr
--	 ( invoiceheader.ivh_hdrnumber between @invoice_no_lo and @invoice_no_hi) AND
--   	 ( @invoice_status  in ('ALL', invoiceheader.ivh_invoicestatus)) and
--	 ( @revtype1 in('UNK', invoiceheader.ivh_revtype1)) and
--	 ( @revtype2 in('UNK', invoiceheader.ivh_revtype2)) and  			
 --        ( @revtype3 in('UNK', invoiceheader.ivh_revtype3)) and  
 --        ( @revtype4 in('UNK', invoiceheader.ivh_revtype4)) and
--	 ( @billto in ('UNKNOWN',invoiceheader.ivh_billto)) and
	-- ( @shipper in ('UNKNOWN', invoiceheader.ivh_shipper)) and
	-- ( @consignee in ('UNKNOWN',invoiceheader.ivh_consignee)) and
--	 (invoiceheader.ivh_shipdate between @shipdate1 and @shipdate2 ) and
 --        (invoiceheader.ivh_deliverydate between @deldate1 and @deldate2) and
--	 ((invoiceheader.ivh_billdate between @billdate1 and @billdate2) or
	-- (invoiceheader.ivh_billdate Is null))
	
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */
if (select count(*) from #invtemp_tbl) = 0
	begin
	select @ret_value = 0  
	GOTO ERROR_END
	end

  SELECT ivd.ivh_hdrnumber, 
         SUM(ivd.ivd_rate) rate, 
         SUM(ivd.ivd_charge) charge 
    INTO #invtemp_tbl2 
    FROM invoiceheader ivh, invoicedetail ivd, chargetype cht
   WHERE (cht.cht_itemcode = ivd.cht_itemcode) AND 
-- LOR PTS# 15875         (cht.cht_rollintolh = 1) AND 
		(IsNull(ivd.cht_rollintolh,0) = 1) AND 
		ivh.ivh_hdrnumber = @invoice_nbr And
     --    (ivh.ivh_hdrnumber BETWEEN @invoice_no_lo AND @invoice_no_hi) AND 
     --    (@invoice_status IN ('ALL', ivh.ivh_invoicestatus)) AND 
     --    (@revtype1 IN ('UNK', ivh.ivh_revtype1)) AND 
    --     (@revtype2 IN ('UNK', ivh.ivh_revtype2)) AND 
     --    (@revtype3 IN ('UNK', ivh.ivh_revtype3)) AND 
     --    (@revtype4 IN ('UNK', ivh.ivh_revtype4)) AND 
     --    (@billto IN ('UNKNOWN',ivh.ivh_billto)) AND 
    --     (@shipper IN ('UNKNOWN', ivh.ivh_shipper)) AND 
    --     (@consignee IN ('UNKNOWN',ivh.ivh_consignee)) AND 
     --    (ivh.ivh_shipdate BETWEEN @shipdate1 AND @shipdate2) AND 
     --    (ivh.ivh_deliverydate BETWEEN @deldate1 AND @deldate2) AND 
     --    ((ivh.ivh_billdate BETWEEN @billdate1 AND @billdate2) OR 
      --    (ivh.ivh_billdate Is NULL)) AND
-- RE - 02/13/02 - PTS #13342
		 (ivh.ivh_hdrnumber = ivd.ivh_hdrnumber) 
GROUP BY ivd.ivh_hdrnumber

 
	-- PTS 11193 - DJM - Removed Rollup limit to code 'LHF'. Limit to cht_unbasis of Flat
        -- AND #invtemp_tbl.cht_itemcode = 'LHF'
IF (SELECT COUNT(*) FROM #invtemp_tbl2) > 0
UPDATE #invtemp_tbl 
   SET #invtemp_tbl.ivd_rate = #invtemp_tbl.ivd_rate + #invtemp_tbl2.rate,
       #invtemp_tbl.ivd_charge = #invtemp_tbl.ivd_charge + #invtemp_tbl2.charge 
  FROM #invtemp_tbl2, chargetype
 WHERE #invtemp_tbl.ivh_hdrnumber = #invtemp_tbl2.ivh_hdrnumber 
	AND #invtemp_tbl.cht_itemcode = chargetype.cht_itemcode
	AND chargetype.cht_basisunit = 'FLT'
	--vmj2+
	AND	chargetype.cht_primary = 'Y'
	--vmj2-


/* RETRIEVE COMPANY DATA */	                   			
--if @useasbillto = 'BLT'
--begin
/*	
	--LOR	PTS#4789(SR# 7160)	
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
		ch.cht_primary = 'Y')  = 0 or
    (select count(*) 
	from company c, chargetype ch, #invtemp_tbl t
	where c.cmp_id = t.ivh_billto and
		c.cmp_mailto_name is not null and
		c.cmp_mailto_name not in ('') and
		ch.cht_itemcode = t.cht_itemcode and
		ch.cht_primary = 'Y' and
		t.ivh_terms not in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3)) > 0)
	*/
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
--end			
/*
if @useasbillto = 'ORD'
	begin

	update #invtemp_tbl
		set ivh_billto_name = company.cmp_name,
			 ivh_billto_addr = company.cmp_address1,
			 ivh_billto_addr2 = company.cmp_address2,		
			 ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip 
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
			 ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip 
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_shipper
	end			
	*/		
update #invtemp_tbl
set originpoint_name = company.cmp_name,
	origin_addr = company.cmp_address1,
	origin_addr2 = company.cmp_address2,
	origin_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,'') 
from #invtemp_tbl, company, city
where company.cmp_id = #invtemp_tbl.ivh_originpoint
	and city.cty_code = ivh_origincity
				
update #invtemp_tbl
set destpoint_name = company.cmp_name,
	dest_addr = company.cmp_address1,
	dest_addr2 = company.cmp_address2,
	dest_nmctst =substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,'') 
from #invtemp_tbl, company, city
where company.cmp_id = #invtemp_tbl.ivh_destpoint
	and city.cty_code = ivh_destcity
		
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
	shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
from #invtemp_tbl, company
--where company.cmp_id = #invtemp_tbl.ivh_shipper
where company.cmp_id = #invtemp_tbl.ivh_showshipper
		
update 	#invtemp_tbl
set 	shipper_nmctst = origin_nmctst
where      ivh_shipper = 'UNKNOWN'
					
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
--where company.cmp_id = #invtemp_tbl.ivh_consignee
where company.cmp_id = #invtemp_tbl.ivh_showcons
		
update 	#invtemp_tbl
set 	consignee_nmctst = dest_nmctst
where      ivh_consignee  = 'UNKNOWN'				

update #invtemp_tbl
set stop_name = company.cmp_name,
	 stop_addr = company.cmp_address1,
	 stop_addr2 = company.cmp_address2,
	 stop_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
from #invtemp_tbl, company
where company.cmp_id = #invtemp_tbl.cmp_id

-- dpete for UNKNOWN companies with cities must get city name from city table	pts5319	
update #invtemp_tbl
set 	stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +city.cty_zip 
from 	#invtemp_tbl, city  RIGHT OUTER JOIN  stops  ON  city.cty_code  = stops.stp_city --pts40188 outer join conversion
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
	tar_number,
	ivd_tarnumber,
	ivd_tartariffnumber,
	ivd_tartariffitem,
	cmp_altid,
	cht_primary,
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	ivh_showshipper,
	ivh_showcons,
	ivh_charge
	from #invtemp_tbl
	where copies = 1   
end 
                                                      	
ERROR_END:
/* FINAL SELECT - FORMS RETURN SET */
select ivh_invoicenumber,   
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
	tar_number,
	ivd_tarnumber,
	ivd_tartariffnumber,
	ivd_tartariffitem,
	cmp_altid,
	cht_primary,
	ivh_showshipper,
	ivh_showcons
from #invtemp_tbl

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */
IF @@ERROR != 0 select @ret_value = @@ERROR 
return @ret_value

GO
GRANT EXECUTE ON  [dbo].[invoice_template3_rollin] TO [public]
GO
