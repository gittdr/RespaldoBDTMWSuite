SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[invoice_template84]  (@p_invoice_nbr int, @p_copies int)			
AS

/**
 * 
 * NAME:
 * dbo.invoice_template84
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the invoice detail records 
 * based on the invoice number selected in the interface. PTS 29756
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
 * 001 - @invoice_nbr, int, input, null;
 *       This parameter indicates the INVOICE NUMBER(ie.ivh_hdrnumber)
 *       for which the invoice will be printed. The value must be 
 *       non-null and non-empty.
 * 002 - @copies, int, input, null;
 *       This parameter indicates the number of hard copies 
 *       to print. The value must be non-null and 
 *       non-empty. 
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 **/


declare	@v_temp_name   varchar(30) ,
	@v_temp_addr   varchar(30) ,
	@v_temp_addr2  varchar(30),
	@v_temp_nmstct varchar(30),
	@v_temp_altid  varchar(25),
	@v_counter    int,
	@v_ret_value  int,
	@v_ivd_number int,
	@v_last_ivd_number int,
	@v_seq int,
	@v_reftype varchar(6),
	@v_refnum  varchar(30),
	@v_pupcount int,
	@v_pup_stp_no int,
        @v_TermsMustMatchGISetting char(1),
        @v_ChargesMustIncludeLinehaul char(1),
        @v_cmp_name varchar(30),
	@v_cmp_id varchar(8),
        @MinStp int,
        @v_stp_type varchar(3)

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @v_ret_value = 1
/* prior default behavoir for mail to override was terms must match and invoice must include linehaul charges */
Select @v_TermsMustMatchGISetting = Left(Upper(IsNull(gi_string1,'Y')),1) From generalinfo Where gi_name = 'MailToTermsMustMatchToApply'
Select @v_TermsMustMatchGISetting = IsNull(@v_TermsMustMatchGISetting,'Y')
Select @v_ChargesMustIncludeLinehaul = Left(Upper(IsNull(gi_string1,'Y')),1) From generalinfo Where gi_name = 'MailToOverridesOnlyLineHaul'
Select @v_ChargesMustIncludeLinehaul = IsNull(@v_ChargesMustIncludeLinehaul,'Y')

/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET 
	NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/


 SELECT distinct  invoiceheader.ivh_invoicenumber,   
         invoiceheader.ivh_hdrnumber, 
	 invoiceheader.ivh_billto, 
	 @v_temp_name ivh_billto_name ,
	 @v_temp_addr 	ivh_billto_addr,
	 @v_temp_addr2	ivh_billto_addr2,
	 @v_temp_nmstct ivh_billto_nmctst,
         invoiceheader.ivh_terms,   	
         invoiceheader.ivh_totalcharge,   
	 invoiceheader.ivh_shipper,   
	 @v_temp_name	shipper_name,
	 @v_temp_addr	shipper_addr,
	 @v_temp_addr2	shipper_addr2,
	 @v_temp_nmstct shipper_nmctst,
         invoiceheader.ivh_consignee,   
	 @v_temp_name consignee_name,
	 @v_temp_addr consignee_addr,
	 @v_temp_addr2	consignee_addr2,
	 @v_temp_nmstct consignee_nmctst,
         invoiceheader.ivh_originpoint,   
	 @v_temp_name originpoint_name,
	 @v_temp_addr origin_addr,
	 @v_temp_addr2	origin_addr2,
	 @v_temp_nmstct origin_nmctst,
         invoiceheader.ivh_destpoint,   
	 @v_temp_name destpoint_name,
	 @v_temp_addr dest_addr,
	 @v_temp_addr2	dest_addr2,
	 @v_temp_nmstct dest_nmctst,
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
	 @v_temp_name ivd_billto_name,
	 @v_temp_addr ivd_billto_addr,
	 @v_temp_addr2	ivd_billto_addr2,
	 @v_temp_nmstct ivd_billto_nmctst,
         invoicedetail.ivd_itemquantity,   
         invoicedetail.ivd_subtotalptr,   
         invoicedetail.ivd_allocatedrev,   
         invoicedetail.ivd_sequence,   
         invoicedetail.ivd_refnum, 
	 invoicedetail.cmd_code,   
         invoicedetail.cmp_id,   
	 @v_temp_name	stop_name,
	 @v_temp_addr	stop_addr,
	 @v_temp_addr2	stop_addr2,
	 @v_temp_nmstct stop_nmctst,
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
	 @v_temp_altid cmp_altid,
	 0 pup_stp_number,
	 0 fgt_number,
	 0 fgt_sequence,
	 @v_reftype fgt_reftype,
	 @v_refnum fgt_refnum,
	 @v_temp_name	pup_stop_name,
	 @v_temp_addr	pup_stop_addr,
	 @v_temp_addr2	pup_stop_addr2,
	 @v_temp_nmstct pup_stop_nmctst,
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	IsNull(ivh_charge,0) ivh_charge
    into #invtemp_tbl
  FROM invoiceheader JOIN invoicedetail ON ( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) 
       RIGHT OUTER JOIN chargetype  ON (chargetype.cht_itemcode = invoicedetail.cht_itemcode)
       LEFT OUTER JOIN commodity ON (invoicedetail.cmd_code = commodity.cmd_code)
 WHERE invoiceheader.ivh_hdrnumber = @p_invoice_nbr 
	-- ( invoiceheader.ivh_hdrnumber between @invoice_no_lo and @invoice_no_hi) AND
   	-- ( @invoice_status  in ('ALL', invoiceheader.ivh_invoicestatus)) and
	-- ( @revtype1 in('UNK', invoiceheader.ivh_revtype1)) and
	-- ( @revtype2 in('UNK', invoiceheader.ivh_revtype2)) and  			
   --      ( @revtype3 in('UNK', invoiceheader.ivh_revtype3)) and  
  --       ( @revtype4 in('UNK', invoiceheader.ivh_revtype4)) and
	-- ( @billto in ('UNKNOWN',invoiceheader.ivh_billto)) and
	-- ( @shipper in ('UNKNOWN', invoiceheader.ivh_shipper)) and
	-- ( @consignee in ('UNKNOWN',invoiceheader.ivh_consignee)) and
--	 (invoiceheader.ivh_shipdate between @shipdate1 and @shipdate2 ) and
 --        (invoiceheader.ivh_deliverydate between @deldate1 and @deldate2) and
	-- ((invoiceheader.ivh_billdate between @billdate1 and @billdate2) or
	-- (invoiceheader.ivh_billdate IS null))
	
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */
if (select count(*) from #invtemp_tbl) = 0
	begin
	select @v_ret_value = 0  
	GOTO ERROR_END
	end

select @v_last_ivd_number = 0
Select @v_ivd_number = min(ivd_number) from #invtemp_tbl where ivd_number > @v_last_ivd_number

While @v_ivd_number > 0
Begin
	select @v_seq = isNull(min(freightdetail.fgt_sequence),0) 
	from #invtemp_tbl tmp , freightdetail
	where tmp.ivd_number = @v_ivd_number and
		freightdetail.stp_number = tmp.stp_number and
		freightdetail.cmd_code = tmp.cmd_code and
		freightdetail.fgt_sequence > (select isNull(max(tmp2.fgt_sequence), 0)
						from #invtemp_tbl tmp2
						Where tmp.stp_number = tmp2.stp_number and
							tmp.cmd_code = tmp2.cmd_code)

	Update #invtemp_tbl
	Set #invtemp_tbl.fgt_number = freightdetail.fgt_number,
	 #invtemp_tbl.fgt_sequence = freightdetail.fgt_sequence,
	 #invtemp_tbl.fgt_reftype = freightdetail.fgt_reftype,
	 #invtemp_tbl.fgt_refnum = freightdetail.fgt_refnum
	from freightdetail
	where #invtemp_tbl.ivd_number = @v_ivd_number and
		freightdetail.stp_number = #invtemp_tbl.stp_number and
		freightdetail.cmd_code = #invtemp_tbl.cmd_code and
		freightdetail.fgt_sequence = @v_seq
	
	select @v_last_ivd_number = @v_ivd_number
	select @v_ivd_number = min(isnull(ivd_number,0)) from #invtemp_tbl where ivd_number > @v_last_ivd_number
End	

/* RETRIEVE COMPANY DATA */	                   			
--if @useasbillto = 'BLT'
--	begin
/*	DPETE use GI settings to control requirement to match on terms and linehaul
--	LOR	PTS#4789(SR# 7160)	
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
			ch.cht_primary = 'Y' and ch.cht_basis='SHP') = 0 or
	     (select count(*) 
		from company c, chargetype ch, #invtemp_tbl t
		where c.cmp_id = t.ivh_billto and
			c.cmp_mailto_name is not null and
			c.cmp_mailto_name not in ('') and
			ch.cht_itemcode = t.cht_itemcode and
			ch.cht_primary = 'Y' and
			ch.cht_basis='SHP' and
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
			 ivh_billto_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,''),
			#invtemp_tbl.cmp_altid = company.cmp_altid 
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_billto
	Else	
		update #invtemp_tbl
		set ivh_billto_name = company.cmp_mailto_name,
			 ivh_billto_addr = company.cmp_mailto_address1,
			 ivh_billto_addr2 = company.cmp_mailto_address2,		
			 ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct)))+ ' ' + IsNull(company.cmp_mailto_zip,''),
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
*/		
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
where company.cmp_id = #invtemp_tbl.ivh_shipper

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
where company.cmp_id = #invtemp_tbl.ivh_consignee
	
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

-- dpete for UNKNOWN companies with cities must get city name from city table pts5319   
update #invtemp_tbl
set   stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +city.cty_zip 
from  stops JOIN #invtemp_tbl ON (stops.stp_number = #invtemp_tbl.stp_number) 
      RIGHT OUTER JOIN city ON (city.cty_code = stops.stp_city )
where #invtemp_tbl.stp_number IS NOT NULL 
--from  #invtemp_tbl, stops,city  
--where  #invtemp_tbl.stp_number IS NOT NULL  
-- and stops.stp_number =  #invtemp_tbl.stp_number 
-- and city.cty_code =* stops.stp_city  

-- DJM - Find the PUP stop for the Commodities in InvoiceDetail
Update #invtemp_tbl
Set pup_stp_number = stops.stp_number
from stops, freightdetail fd1, freightdetail fd2, #invtemp_tbl
where stops.ord_hdrnumber = #invtemp_tbl.ord_hdrnumber and
	#invtemp_tbl.stp_number = fd1.stp_number and
	#invtemp_tbl.cmd_code = fd1.cmd_code and
	#invtemp_tbl.fgt_reftype = fd1.fgt_reftype and
	#invtemp_tbl.fgt_refnum = fd1.fgt_refnum and
	stops.stp_type = 'PUP' and
	stops.stp_number = fd2.stp_number and
	fd2.fgt_refnum = fd1.fgt_refnum and
-- RE - 5/23/01 - PTS 10963
	#invtemp_tbl.stp_number <> 0
	
/* If there is only one PUP stop, it must be the Pickup for all the  cars	*/
/*Update #invtemp_tbl
Set pup_stp_number = stops.stp_number
from stops, #invtemp_tbl, stops pupcount
where stops.ord_hdrnumber = #invtemp_tbl.ord_hdrnumber and 
	isNull(#invtemp_tbl.pup_stp_number, 0) = 0 and
	stops.stp_type = 'PUP' and
	not exists (select stp_number from stops s2
			where s2.ord_hdrnumber = #invtemp_tbl.ord_hdrnumber and
				s2.stp_type = 'PUP' and
				s2.stp_number <> stops.stp_number)	*/

update #invtemp_tbl
set pup_stop_name = company.cmp_name,
	pup_stop_addr = company.cmp_address1,
	pup_stop_addr2 = company.cmp_address2
from #invtemp_tbl, company, stops
where #invtemp_tbl.pup_stp_number > 0 and
	#invtemp_tbl.pup_stp_number is not null and
	#invtemp_tbl.pup_stp_number = stops.stp_number and
	stops.cmp_id = company.cmp_id
	
update #invtemp_tbl
set 	pup_stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +city.cty_zip
from  	stops JOIN #invtemp_tbl ON (stops.stp_number = #invtemp_tbl.stp_number) 
      	RIGHT OUTER JOIN city ON (city.cty_code = stops.stp_city )
where 	#invtemp_tbl.stp_number IS NOT NULL 
		and #invtemp_tbl.pup_stp_number > 0

--bcy
-- from 	#invtemp_tbl, stops,city
-- where 	#invtemp_tbl.pup_stp_number IS NOT NULL
-- 	and #invtemp_tbl.pup_stp_number > 0
-- 	and	stops.stp_number =  #invtemp_tbl.pup_stp_number
-- 	and	city.cty_code =* stops.stp_city


--PTS# 33019 ILB 05/22/2006
SET @MinStp      = 0
SET @v_cmp_name  = ''
SET @v_cmp_id = ''
SET @v_stp_type = ''

WHILE (SELECT COUNT(*) FROM #invtemp_tbl WHERE stp_number > @MinStp ) > 0
	BEGIN
		SELECT @MinStp = (SELECT MIN(stp_number)
                            	    FROM #invtemp_tbl 
                           	   WHERE stp_number > @MinStp)

		select @v_cmp_name = cmp_name,
                       @v_cmp_id   = cmp_id ,
                       @v_stp_type = stp_type
                  from stops
		 where stp_number = @MinStp                      

		--print @v_cmp_id
                --print cast(@MinStp as varchar(20))	
		--print @v_stp_type	
		
		IF @v_stp_type = 'DRP'
		BEGIN
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
			where company.cmp_id = @v_cmp_id and
                	      stp_number = @MinStp 
                      

			UPDATE #invtemp_tbl 
                   	   SET ivh_consignee = @v_cmp_id
		 	 WHERE stp_number = @MinStp
		END

		
		IF @v_stp_type = 'PUP'
		BEGIN
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
			where company.cmp_id = @v_cmp_id and
                              stp_number = @MinStp


			UPDATE #invtemp_tbl 
                   	   SET ivh_shipper = @v_cmp_id
		 	 WHERE stp_number = @MinStp			
		END
		
	END 
--PTS# 33019 ILB 05/22/2006
			
/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */
select @v_counter = 1
while @v_counter <>  @p_copies
begin
	select @v_counter = @v_counter + 1
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
	 @v_counter,
	 cht_basis,
	 cht_description,
	 cmd_name,
	 cmp_altid,
	 pup_stp_number,
	 fgt_number,
	 fgt_sequence,
	 fgt_reftype,
	 fgt_refnum,
	 pup_stop_name,
	 pup_stop_addr,
	 pup_stop_addr2,
	 pup_stop_nmctst,
	 ivh_hideshipperaddr,
	 ivh_hideconsignaddr,
	IsNull(ivh_charge,0) ivh_charge
	from #invtemp_tbl
	where copies = 1   
end 
	                                                            	
ERROR_END:
/* FINAL SELECT - FORMS RETURN SET */
SELECT 	 ivh_invoicenumber,   
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
         ivh_deliverydate as delivery_date,   
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
         ivd_description= CASE when isNull(ivd_description,'') ='' or ivd_description = 'UNKNOWN' THEN cht_description else ivd_description END,   
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
	 cmp_altid,
	 pup_stp_number,
	 fgt_number,
	 fgt_sequence,
	 fgt_reftype,
	 fgt_refnum,
	 pup_stop_name,
	 pup_stop_addr,
	 pup_stop_addr2,
	 pup_stop_nmctst
from #invtemp_tbl

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */
IF @@ERROR != 0 select @v_ret_value = @@ERROR 
return @v_ret_value

GO
GRANT EXECUTE ON  [dbo].[invoice_template84] TO [public]
GO
