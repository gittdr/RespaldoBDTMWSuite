SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[invoice_template101](@invoice_nbr   int,@copies  int)  
as  


/**
* NAME:
* dbo.INVOICE_TEMPLATE101
*
* TYPE:
* Stored procedure
*
* RETURNS: 
* PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND  
* 1 - IF SUCCESFULLY EXECUTED  
* @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS  
*	  
* modified from some other proc by Michalynn Kelly for invoice format 87
 *   returned from customer May 2007 as working in production
* PTS 38026 make performance change for Junhai
* PTS 46281 SGB 02/27/2009 performance change by removing join to stops table to update temp table when not needed
* PTS 46642 SGB 03/26/2009 GST tax should not have count weight or volume / Description should be chargetype 
**/  


DECLARE @temp_name   		VARCHAR(30) ,  
 	@temp_addr   		VARCHAR(30) ,  
 	@temp_addr2  		VARCHAR(30),  
 	@temp_nmstct 		VARCHAR(30),  
 	@temp_altid  		VARCHAR(25),  
 	@counter    		INT,  
 	@ret_value  		INT,  
 	@temp_terms    		VARCHAR(20),  
 	@VARCHAR50 		VARCHAR(50),
 	@VARCHAR20 		VARCHAR(20),
 	@VARCHAR6 		VARCHAR(6), 
  	@v_showcons       	VARCHAR(8),
	@v_sum		   	FLOAT,
        @v_stp_mfh_sequence     INT,
	@v_mov_number		INT

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
SELECT @ret_value = 1  
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
SELECT @ret_value = 1  
  
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
NOTE: COPY - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/  

 SELECT (Case 
	When invoiceheader.ivh_invoicenumber like '%A' THEN REPLACE(invoiceheader.ivh_invoicenumber,'A','')
	When invoiceheader.ivh_invoicenumber like '%B' THEN REPLACE(invoiceheader.ivh_invoicenumber,'B','')
	When invoiceheader.ivh_invoicenumber like '%C' THEN REPLACE(invoiceheader.ivh_invoicenumber,'C','')
	When invoiceheader.ivh_invoicenumber like '%D' THEN REPLACE(invoiceheader.ivh_invoicenumber,'D','')
	When invoiceheader.ivh_invoicenumber like '%E' THEN REPLACE(invoiceheader.ivh_invoicenumber,'E','')
	When invoiceheader.ivh_invoicenumber like 'S%' THEN REPLACE(invoiceheader.ivh_invoicenumber,'S','')
	Else ivh_invoicenumber
              End) ivh_invoicenumber, 
	invoiceheader.ivh_hdrnumber,   
  	invoiceheader.ivh_billto,   
  	@temp_name ivh_billto_name ,  
  	@temp_addr  ivh_billto_addr,  
  	@temp_addr2 ivh_billto_addr2,           
  	@temp_nmstct ivh_billto_nmctst,  
        invoiceheader.ivh_terms,      
        invoiceheader.ivh_totalcharge,     
  	invoiceheader.ivh_shipper,     
  	@temp_name shipper_name,  
  	@temp_addr shipper_addr,  
  	@temp_addr2 shipper_addr2,  
  	@temp_nmstct shipper_nmctst,  
        invoiceheader.ivh_consignee,     
  	@temp_name consignee_name,  
  	@temp_addr consignee_addr,  
  	@temp_addr2 consignee_addr2,  
  	@temp_nmstct consignee_nmctst,  
        invoiceheader.ivh_originpoINT,     
  	@temp_name originpoINT_name,  
  	@temp_addr origin_addr,  
  	@temp_addr2 origin_addr2,  
  	@temp_nmstct origin_nmctst,  
        invoiceheader.ivh_destpoINT,     
  	@temp_name destpoINT_name,  
  	@temp_addr dest_addr,  

  	@temp_addr2 dest_addr2,  
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
        invoiceheader.ivh_prINTdate,     
        invoiceheader.ivh_billdate,     
        invoiceheader.ivh_lastprINTdate,     
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
   	ivd_taxable1 =IsNull(chargetype.cht_taxtable1,invoicedetail.ivd_taxable1),   -- taxable flags not set on ivd for gst,pst,etc    
   	ivd_taxable2 =IsNull(chargetype.cht_taxtable2,invoicedetail.ivd_taxable2),  
   	ivd_taxable3 =IsNull(chargetype.cht_taxtable3,invoicedetail.ivd_taxable3),  
   	ivd_taxable4 =IsNull(chargetype.cht_taxtable4,invoicedetail.ivd_taxable4),  
        invoicedetail.ivd_unit,     
        invoicedetail.cur_code,     
        invoicedetail.ivd_currencydate,     
        invoicedetail.ivd_glnum,     
        invoicedetail.ivd_type,     
        invoicedetail.ivd_rateunit,     
        invoicedetail.ivd_billto,     
  	@temp_name ivd_billto_name,  
  	@temp_addr ivd_billto_addr,  
  	@temp_addr2 ivd_billto_addr2,  
 	@temp_nmstct ivd_billto_nmctst,  
        invoicedetail.ivd_itemquantity,     
        invoicedetail.ivd_subtotalptr,     
        invoicedetail.ivd_allocatedrev,     
        invoicedetail.ivd_sequence,     
        invoicedetail.ivd_refnum,     
        invoicedetail.cmd_code,     
        invoicedetail.cmp_id,     
  	@temp_name stop_name,  
  	@temp_addr stop_addr,  
  	@temp_addr2 stop_addr2,  
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
 	ivh_hideshipperaddr,  
 	ivh_hideconsignaddr,  
 	(Case ivh_showshipper   
  		when 'UNKNOWN' then invoiceheader.ivh_shipper  
  		else IsNull(ivh_showshipper,invoiceheader.ivh_shipper)   
 		end) 
	ivh_showshipper,  
 	(Case ivh_showcons   
  		when 'UNKNOWN' then invoiceheader.ivh_consignee  
  		else IsNull(ivh_showcons,invoiceheader.ivh_consignee)   
 		end) 
	ivh_showcons,
  		--PTS# 24173 ILB 08/06/2005  
 	ivh_definition ,
 	@VARCHAR20 fgt_refnum,
 	@VARCHAR6 fgt_reftype,
 		--PTS# 24173 ILB 08/06/2005
 	@temp_terms terms_name,
	@v_sum total_pup_wgt,
	@counter stp_mfh_sequence,  
 	IsNull(ivh_charge,0) ivh_charge,  
 	@temp_addr2    ivh_billto_addr3,  
 	@VARCHAR50 cmp_contact,  
 	@VARCHAR50 shipper_geoloc,  
 	@VARCHAR50 cons_geoloc 

INTO 	#invtemp_tbl  
FROM 	invoiceheader, 
	invoicedetail
	LEFT OUTER JOIN chargetype ON chargetype.cht_itemcode = invoicedetail.cht_itemcode
	--RIGHT OUTER JOIN commodity ON commodity.cmd_code = invoicedetail.cmd_code
	LEFT OUTER JOIN commodity ON commodity.cmd_code = invoicedetail.cmd_code

WHERE	(invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber) 
	and 	invoiceheader.ivh_hdrnumber = @invoice_nbr  
	

   
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
if (SELECT count(*) from #invtemp_tbl) = 0  
 begin  
 SELECT @ret_value = 0    
 GOTO ERROR_END  
 end  


 If Not Exists (SELECT cmp_mailto_name From company c, #invtemp_tbl t  
        		Where c.cmp_id = t.ivh_billto  
   			And Rtrim(IsNull(cmp_mailto_name,'')) > ''  
   			And t.ivh_terms in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3,   
    			Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)  
   			And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End )   
  
  update #invtemp_tbl  
  set 	ivh_billto_name = company.cmp_name,  
   	ivh_billto_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,''),  
   	#invtemp_tbl.cmp_altid = company.cmp_altid,  
    	ivh_billto_addr = company.cmp_address1,  
    	ivh_billto_addr2 = company.cmp_address2,  
        ivh_billto_addr3 = company.cmp_address3,  
   	cmp_contact = company.cmp_contact  
  from #invtemp_tbl, company  
  where company.cmp_id = #invtemp_tbl.ivh_billto  
 Else   
  update #invtemp_tbl  
  set 	ivh_billto_name = company.cmp_mailto_name,  
    	ivh_billto_addr =  company.cmp_mailto_address1 ,  
    	ivh_billto_addr2 = company.cmp_mailto_address2,     
   	ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct)))+ ' ' + IsNull(company.cmp_mailto_zip,''),  
   	#invtemp_tbl.cmp_altid = company.cmp_altid ,  
   	cmp_contact = company.cmp_contact  
  from #invtemp_tbl, company  
  where company.cmp_id = #invtemp_tbl.ivh_billto  
 --end  

  update #invtemp_tbl  
  set 	 originpoINT_name = company.cmp_name,  
 	 origin_addr = company.cmp_address1,  
 	 origin_addr2 = company.cmp_address2,  
 	 origin_nmctst = substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip ,'')  
  from   #invtemp_tbl, company, city  
  where  company.cmp_id = #invtemp_tbl.ivh_originpoINT  
 	 and city.cty_code = #invtemp_tbl.ivh_origincity     
      
  update #invtemp_tbl  
  set 	 destpoINT_name = company.cmp_name,  
 	 dest_addr = company.cmp_address1,  
 	 dest_addr2 = company.cmp_address2,  
 	 dest_nmctst =substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,'')   
  from   #invtemp_tbl, company, city  
  where  company.cmp_id = #invtemp_tbl.ivh_destpoINT  
 	 and city.cty_code =  #invtemp_tbl.ivh_destcity   
  
  update #invtemp_tbl  
  set 	 shipper_name = company.cmp_name,  
 	 shipper_addr = Case ivh_hideshipperaddr when 'Y'   
    	 then ''  
    	 else company.cmp_address1  
   end,  
 	 shipper_addr2 = Case ivh_hideshipperaddr when 'Y'   
    	 then ''  
    	 else company.cmp_address2  
   end,  
 	 shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,''),  
 	 Shipper_geoloc = IsNull(cmp_geoloc,'')  
  from   #invtemp_tbl, company  
   
  where  company.cmp_id = #invtemp_tbl.ivh_showshipper  
  
-- There is no shipper city, so if the shipper is UNKNOWN, use the origin city to get the nmstct    
  update #invtemp_tbl  
  set 	 shipper_nmctst = origin_nmctst  
  from   #invtemp_tbl  
  where  #invtemp_tbl.ivh_shipper = 'UNKNOWN'  
  
  update #invtemp_tbl  
  set 	 ivd_refnum = stops.stp_refnum,
	 ivd_reftype = stops.stp_reftype  
  from   #invtemp_tbl, stops
  where  #invtemp_tbl.stp_number = stops.stp_number 
	 and stops.stp_mfh_sequence = 1  

    
  update #invtemp_tbl  
  set 	 consignee_name = company.cmp_name,  
 	 consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +IsNull(company.cmp_zip, ''), 
 	 consignee_addr = Case ivh_hideconsignaddr when 'Y'   
    	 then ''  
    	 else company.cmp_address1  
   end,      
 	 consignee_addr2 = Case ivh_hideconsignaddr when 'Y'   
    	 then ''  
    	 else company.cmp_address2  
   end,  
 	 cons_geoloc = IsNull(cmp_geoloc,'')  
  from   #invtemp_tbl, company  
   
  where  company.cmp_id = #invtemp_tbl.ivh_showcons     
   
-- There is no consignee city, so if the consignee is UNKNOWN, use the dest city to get the nmstct    
update #invtemp_tbl  
set 	consignee_nmctst = dest_nmctst  
from #invtemp_tbl  
where #invtemp_tbl.ivh_consignee = 'UNKNOWN'  

update #invtemp_tbl  
   set  stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))
  from  #invtemp_tbl, 
	city 
	LEFT OUTER JOIN stops ON stops.stp_city = city.cty_code

 where  #invtemp_tbl.stp_number IS NOT NULL  
 	and stops.stp_number =  #invtemp_tbl.stp_number  
 	and #invtemp_tbl.cht_basis <> 'ACC'

 update #invtemp_tbl
    set stop_nmctst = substring(cty.cty_nmstct,1, (charindex('/', cty.cty_nmstct)))
   from #invtemp_tbl, city cty, company cmp
  where #invtemp_tbl.cmp_id = cmp.cmp_id and
        cmp.cmp_city = cty.cty_code and
        cht_basis = 'ACC'
--END PTS# 25424  

update #invtemp_tbl  
   set stop_name = cmp.cmp_name,  
       stop_addr = cmp.cmp_address1,  
       stop_addr2 = cmp.cmp_address2, 
--PTS# 25424 12/31/2004 ILB
       stop_nmctst = stop_nmctst +' '+IsNull(cmp.cmp_zip,'')   
--END PTS# 25424 12/31/2004 ILB 
 from #invtemp_tbl, company cmp 
 where cmp.cmp_id = #invtemp_tbl.cmp_id   


update #invtemp_tbl  
set terms_name = la.name  
from labelfile la  
where la.labeldefinition = 'creditterms' and  
     la.abbr = #invtemp_tbl.ivh_terms  

-- PTS# 24173 ILB 08/10/2004
update #invtemp_tbl
   set fgt_refnum = fgt.fgt_refnum,
       fgt_reftype = Case
      		When isnull(fgt.fgt_refnum,'') <> '' Then fgt.fgt_reftype      		
      		Else ''
      		End 
  from #invtemp_tbl, freightdetail fgt,  stops stp
 where #invtemp_tbl.ivh_hdrnumber = @invoice_nbr and
       #invtemp_tbl.stp_number = stp.stp_number and      
       #invtemp_tbl.ord_hdrnumber = stp.ord_hdrnumber and 
       fgt.stp_number = stp.stp_number    
-- PTS# 24173 ILB 08/10/2004



-- PTS# 31570 MRK 03/21/2006
SELECT @v_showcons = min(ivh_showcons) from  #invtemp_tbl where ivh_showcons is not null

update #invtemp_tbl  
   set 	consignee_name = company.cmp_name,  
 	consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +IsNull(company.cmp_zip, ''), 
 	consignee_addr = Case ivh_hideconsignaddr when 'Y'   
    	then ''  
    	else company.cmp_address1  
   end,      
 	consignee_addr2 = Case ivh_hideconsignaddr when 'Y'   
    	then ''  
    	else company.cmp_address2  
   end,  
 	cons_geoloc = IsNull(cmp_geoloc,'')  
 from   company
where 	company.cmp_id = @v_showcons   
set   @v_mov_number = 0
SELECT @v_mov_number = min(mov_number) from #invtemp_tbl
set @v_stp_mfh_sequence = 0
--prINT 'michalynn'
--prINT cast(@v_stp_mfh_sequence as VARCHAR(20))
SELECT @v_stp_mfh_sequence = min(stp_mfh_sequence) from  stops 
where ord_hdrnumber <> 0 and mov_number = @v_mov_number
--prINT 'michalynn'
--prINT cast(@v_stp_mfh_sequence as VARCHAR(20))


update #invtemp_tbl
set 	stp_number = stops.stp_number,
	cmp_id = stops.cmp_id,
	cmd_code = stops.cmd_code,
	stop_name = stops.cmp_name,
	stop_nmctst = substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,''),  
	ivd_refnum = stops.stp_refnum,
	stop_addr = stops.stp_address,
	ivd_reftype = stops.stp_reftype,
	ivd_wgt = stops.stp_weight,
	ivd_type = stops.stp_type,
        ivd_description = stops.stp_description,
	ivd_count = stops.stp_count,
	ivd_countunit = stops.stp_countunit
	
from 	#invtemp_tbl, stops, city
where 	#invtemp_tbl.ord_hdrnumber = stops.ord_hdrnumber
	and #invtemp_tbl.stp_number is NULL
	and stops.stp_city = city.cty_code
	and #invtemp_tbl.cht_basis <> 'ACC'
	and stops.stp_mfh_sequence = @v_stp_mfh_sequence
    and stops.ord_hdrnumber > 0 

--PTS 46642 BEGIN GST tax should not have count weight or volume / Description should be chargetype
update #invtemp_tbl
SET ivd_wgt = 0,
ivd_count = 0,
ivd_volume = 0,
stop_name = UPPER(cht_itemcode),
stop_nmctst = '',
ivd_refnum = '',
ivd_reftype = '',
ivd_description = ''
where cht_basis = 'TAX'

--PTS 46642 END

--set @v_sum = 0
SELECT 	@v_sum = (SELECT sum(ivd_wgt)from #invtemp_tbl where #invtemp_tbl.ivd_type = 'PUP')
update 	#invtemp_tbl
	set total_pup_wgt  = @v_sum
	--PTS 46281 SGB 02/27/2009 removed join to stops not needed this is a straight update
--from 	#invtemp_tbl, stops
--	where #invtemp_tbl.stp_number = stops.stp_number or #invtemp_tbl.stp_number = NULL
	
/* DPETE copy of proc from customer gets error here
Update #invtemp_tbl
   set #invtemp_tbl.stp_mfh_sequence = stops.stp_mfh_sequence
  from stops
 where #invtemp_tbl.stp_number = stops.stp_number

Update #invtemp_tbl
   set #invtemp_tbl.stp_mfh_sequence = 999999999
  from #invtemp_tbl
 where #invtemp_tbl.stp_number = NULL
*/

-- PTS# 31570 MRK 03/21/2006
--INVOICE_TEMPLATE101 1506450, 1    
/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */  
SELECT @counter = 1  
while @counter <>  @copies  
 	begin  
 	SELECT @counter = @counter + 1  
  	insert INTo #invtemp_tbl  
  
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
	ivh_originpoINT,     
	originpoINT_name,  
	origin_addr,  
	origin_addr2,  
	origin_nmctst,  
	ivh_destpoINT,     
	destpoINT_name,  
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
	ivh_prINTdate,     
	ivh_billdate,     
	ivh_lastprINTdate,     
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
	--PTS# 24173 ILB 08/06/2005  
	ivh_definition ,
	isnull(fgt_refnum,'')fgt_refnum,
	isnull(fgt_reftype,'')fgt_reftype,
	--PTS# 24173 ILB 08/06/2005 
	terms_name, 
	total_pup_wgt, 
	stp_mfh_sequence,
	IsNull(ivh_charge,0) ivh_charge,  
	ivh_billto_addr3,  
	cmp_contact,  
	shipper_geoloc,  
	cons_geoloc 
	
from #invtemp_tbl  
where copies = 1    
end   
	                                        
ERROR_END:  
/* FINAL SELECT - FORMS RETURN SET */  
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
	ivh_originpoINT,     
	
	originpoINT_name,  
	origin_addr,  
	origin_addr2,  
	origin_nmctst,  
	ivh_destpoINT,     
	destpoINT_name,  
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
	ivh_prINTdate,     
	ivh_billdate,     
	ivh_lastprINTdate,     
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
	--vmj1+ @counter is constant for all rows!  
	copies,  
	--  @counter,  
	--vmj1-  
	cht_basis,  
	cht_description,  
	cmd_name,  
	cmp_altid,  
	ivh_showshipper,  
	ivh_showcons,  
	--PTS# 24173 ILB 08/06/2005  
	ivh_definition ,
	isnull(fgt_refnum,'') fgt_refnum,
	isnull(fgt_reftype,'')fgt_reftype,
	--PTS# 24173 ILB 08/06/2005 
	terms_name,  
	total_pup_wgt,
	stp_mfh_sequence,
	ivh_billto_addr3,  
	cmp_contact,  
	shipper_geoloc,  
	cons_geoloc 
	
	
from 	#invtemp_tbl
order by stp_mfh_sequence  

GO
GRANT EXECUTE ON  [dbo].[invoice_template101] TO [public]
GO
