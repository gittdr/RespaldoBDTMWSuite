SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  create  procedure [dbo].[invoice_template156](@invoice_nbr   int,   @copies  int)  
as  
/*
*
* 
* NAME:invoice_template156
* dbo.invoice_template156
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Provide a return SET of all the invoices details
* based on the invoice format 35.
*
* RETURNS:
* 0 - IF NO DATA WAS FOUND  
* 1 - IF SUCCESFULLY EXECUTED  
* @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS  
*
* RESULT SETS: 
* See Select Below.
*
* PARAMETERS:
* 001 - @invoice_nbr, int, input, NULL;
*       Invoice number
* 002 - @copies, int, input, NULL;
*       number of copies to print
* REFERENCES: (called by AND calling references only, don't 
*              include table/view/object references)
* N/A
* 
* 
* 
* REVISION HISTORY:
* 06/25/07 PTS 36796 - OS - Created
* 07/14/08 Modified by Michalynn Kelly
* 12/4/2008 44798 pmill new invoice format 156 from 122
*/
declare @temp_name   varchar(100),  
	@temp_addr   varchar(50),  
	@temp_addr2  varchar(50),
	@temp_addr3 varchar(50),  --44798
	@temp_nmstct varchar(36),  
	@temp_altid  varchar(25),  
	@counter    int,  
	@ret_value  int,  
	@temp_terms    varchar(20),
	@temp_refnum	varchar(17)
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
 NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/  
SELECT invoiceheader.ivh_invoicenumber,     
	invoiceheader.ivh_hdrnumber,   
	invoiceheader.ivh_billto,   
	@temp_name ivh_billto_name ,  
	@temp_addr  ivh_billto_addr,  
	@temp_addr2 ivh_billto_addr2, 
 	@temp_addr3 ivh_billto_addr3,   --44798
	@temp_nmstct ivh_billto_nmctst,  
    invoiceheader.ivh_terms,      
    invoiceheader.ivh_totalcharge,     
	invoiceheader.ivh_shipper,     
	@temp_name shipper_name,  
	@temp_addr shipper_addr,  
	@temp_addr2 shipper_addr2, 
	@temp_addr3 shipper_addr3,  --44798
	@temp_nmstct shipper_nmctst,  
    invoiceheader.ivh_consignee,     
	@temp_name consignee_name,  
	@temp_addr consignee_addr,  
	@temp_addr2 consignee_addr2, 
	@temp_addr3 consignee_addr3,  --44798
	@temp_nmstct consignee_nmctst,  
    invoiceheader.ivh_originpoint,     
	@temp_name originpoint_name,  
	@temp_addr origin_addr,  
	@temp_addr2 origin_addr2,  
	@temp_nmstct origin_nmctst,  
    invoiceheader.ivh_destpoint,     
	@temp_name destpoint_name,  
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
	isnull(l.name, 'UNKNOWN') ivh_revtype1,  
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
	end) ivh_showshipper,  
	(Case ivh_showcons   
	when 'UNKNOWN' then invoiceheader.ivh_consignee  
	else IsNull(ivh_showcons,invoiceheader.ivh_consignee)   
	end) ivh_showcons,  
	@temp_terms terms_name,  
	invoiceheader.ivh_carrier,  
	IsNull(ivh_charge,0.0) ivh_charge,
	ivh_revtype3_t = 'RevType3',
	@temp_refnum vin_number,
	invoicedetail.fgt_number,
	la.name revtype3_name,
	@temp_refnum bol_number,    --44798   
	ivh_rateby,
	ord_description
into #invtemp_tbl  
from invoiceheader join invoicedetail on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
	LEFT OUTER JOIN orderheader on orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0 --44798
	left outer join chargetype on chargetype.cht_itemcode = invoicedetail.cht_itemcode    
	left outer join commodity on invoicedetail.cmd_code = commodity.cmd_code   
	left outer join labelfile l on l.abbr = invoiceheader.ivh_revtype1 and l.labeldefinition = 'RevType1'
	left outer join freightdetail fgt ON invoicedetail.fgt_number = fgt.fgt_number
	join labelfile la on la.abbr = invoiceheader.ivh_revtype3 and la.labeldefinition = 'RevType3'       
where invoiceheader.ivh_hdrnumber = @invoice_nbr
   
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
if (select count(*) from #invtemp_tbl) = 0  
begin  
	select @ret_value = 0    
	GOTO ERROR_END  
end  

If Not Exists (Select cmp_mailto_name From company c join #invtemp_tbl t on c.cmp_id = t.ivh_billto
	Where Rtrim(IsNull(cmp_mailto_name,'')) > ''
	And t.ivh_terms in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2,	c.cmp_mailto_crterm3,	
	Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)
	And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End)	
   
update #invtemp_tbl
set ivh_billto_name = company.cmp_name,
--	ivh_billto_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip,
	ivh_billto_nmctst = ISNULL(SUBSTRING(company.cty_nmstct,1,
				CASE
						WHEN CHARINDEX('/',company.cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',company.cty_nmstct) -1
				END),'') + ' ' + company.cmp_zip,

	#invtemp_tbl.cmp_altid = company.cmp_altid,
	ivh_billto_addr = company.cmp_address1,
	ivh_billto_addr2 = company.cmp_address2,
	ivh_billto_addr3 = company.cmp_address3  --44798
from #invtemp_tbl join company on company.cmp_id = #invtemp_tbl.ivh_billto
	
Else	
update #invtemp_tbl
set ivh_billto_name = company.cmp_mailto_name,
	ivh_billto_addr = company.cmp_mailto_address1,
	ivh_billto_addr2 = company.cmp_mailto_address2,
	ivh_billto_addr3 = '', --44798		
--	ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct)))+ ' ' + company.cmp_mailto_zip,
	ivh_billto_nmctst = ISNULL(SUBSTRING(company.mailto_cty_nmstct,1,
				CASE
						WHEN CHARINDEX('/',company.mailto_cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',company.mailto_cty_nmstct) -1
				END),'') + ' ' + company.cmp_mailto_zip,
	#invtemp_tbl.cmp_altid = company.cmp_altid 
from #invtemp_tbl join company on company.cmp_id = #invtemp_tbl.ivh_billto

update #invtemp_tbl  
set originpoint_name = company.cmp_name,  
	origin_addr = company.cmp_address1,  
	origin_addr2 = company.cmp_address2,  
	origin_nmctst = substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip ,'')  
from #invtemp_tbl join company on company.cmp_id = #invtemp_tbl.ivh_originpoint  
	join city on city.cty_code = #invtemp_tbl.ivh_origincity    

update #invtemp_tbl  
set destpoint_name = company.cmp_name,  
	dest_addr = company.cmp_address1,  
	dest_addr2 = company.cmp_address2,  
	dest_nmctst =substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,'')   
from #invtemp_tbl join company on company.cmp_id = #invtemp_tbl.ivh_destpoint
	join city on city.cty_code =  #invtemp_tbl.ivh_destcity 

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
	shipper_addr3 = Case ivh_hideshipperaddr when 'Y'   --44798
    then ''  
    else company.cmp_address3 
	end, 
	--shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip  
	shipper_nmctst = ISNULL(SUBSTRING(company.cty_nmstct,1,
				CASE
						WHEN CHARINDEX('/',company.cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',company.cty_nmstct) -1
				END),'') + ' ' + company.cmp_zip
from #invtemp_tbl join company on company.cmp_id = #invtemp_tbl.ivh_showshipper    

-- There is no shipper city, so if the shipper is UNKNOWN, use the origin city to get the nmstct    
update #invtemp_tbl  
set shipper_nmctst = origin_nmctst  
from #invtemp_tbl  
where #invtemp_tbl.ivh_shipper = 'UNKNOWN'  
   



update #invtemp_tbl  
set consignee_name = company.cmp_name,  
	--consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip,  
	consignee_nmctst = ISNULL(SUBSTRING(company.cty_nmstct,1,
				CASE
						WHEN CHARINDEX('/',company.cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',company.cty_nmstct) -1
				END),'') + ' ' + company.cmp_zip,
	consignee_addr = Case ivh_hideconsignaddr when 'Y'   
    then ''  
    else company.cmp_address1  
	end,      
	consignee_addr2 = Case ivh_hideconsignaddr when 'Y'   
    then ''  
    else company.cmp_address2  
	end,
	consignee_addr3 = Case ivh_hideconsignaddr when 'Y'     --44798
    then ''  
    else company.cmp_address3  
	end    
from #invtemp_tbl join company on company.cmp_id = #invtemp_tbl.ivh_showcons    

-- There is no consignee city, so if the consignee is UNKNOWN, use the dest city to get the nmstct    
update #invtemp_tbl  
set consignee_nmctst = dest_nmctst  
from #invtemp_tbl  
where #invtemp_tbl.ivh_consignee = 'UNKNOWN'   
    
update #invtemp_tbl  
set stop_name = company.cmp_name,  
	stop_addr = company.cmp_address1,  
	stop_addr2 = company.cmp_address2  
from #invtemp_tbl join company on company.cmp_id = #invtemp_tbl.cmp_id  

-- dpete for UNKNOWN companies with cities must get city name from city table pts5319   
update #invtemp_tbl  
set  stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +city.cty_zip   
from  #invtemp_tbl join stops on stops.stp_number =  #invtemp_tbl.stp_number 
	left outer join city on city.cty_code = stops.stp_city    
where  #invtemp_tbl.stp_number IS NOT NULL  

update #invtemp_tbl  
set terms_name = la.name  
from labelfile la  
where la.labeldefinition = 'creditterms' 
and la.abbr = #invtemp_tbl.ivh_terms

--VIN#
UPDATE #invtemp_tbl
SET #invtemp_tbl.vin_number = r.ref_number
FROM referencenumber r
WHERE r.ref_tablekey = #invtemp_tbl.ord_hdrnumber
AND r.ref_table = 'orderheader'
AND r.ref_type = 'VIN'

--BOL ID  44798
UPDATE #invtemp_tbl
SET #invtemp_tbl.bol_number = r.ref_number
FROM referencenumber r
WHERE r.ref_tablekey = #invtemp_tbl.ord_hdrnumber
AND r.ref_table = 'orderheader'
AND r.ref_type = 'BLID'

/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */  
select @counter = 1  
while @counter <>  @copies  
begin  
	select @counter = @counter + 1  
	insert into #invtemp_tbl  
	SELECT ivh_invoicenumber,     
		ivh_hdrnumber,   
		ivh_billto,   
		UPPER(ivh_billto_name) ,  
		ivh_billto_addr,  
		ivh_billto_addr2, 
		ivh_billto_addr3,  --44798 
		ivh_billto_nmctst,  
        ivh_terms,      
        ivh_totalcharge,     
		ivh_shipper,		     
		shipper_name,  
		shipper_addr,  
		shipper_addr2,
		shipper_addr3, --44798  
		shipper_nmctst,  
        ivh_consignee,     
		consignee_name,  
		consignee_addr,  
		consignee_addr2,
		consignee_addr3,   --44798  
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
		UPPER(ivd_billto_name),  
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
		terms_name,  
		ivh_carrier,  
		ivh_charge,
		ivh_revtype3_t,
		vin_number,
		fgt_number,
		revtype3_name,
		bol_number, --44798  
		ivh_rateby,
		ord_description
	from #invtemp_tbl  
	where copies = 1 
	and ivd_charge <> 0    
end   
                                                                
ERROR_END:  
/* FINAL SELECT - FORMS RETURN SET */  
--select *  
--from #invtemp_tbl  
SELECT ivh_invoicenumber,     
	ivh_hdrnumber,   
	ivh_billto,   
	UPPER(ivh_billto_name) ,  
	ivh_billto_addr,  
	ivh_billto_addr2,  
	ivh_billto_addr3, 	--44798
	ivh_billto_nmctst,  
    ivh_terms,      
    ivh_totalcharge,     
	ivh_shipper,		    
	shipper_name,  
	shipper_addr,  
	shipper_addr2,  
	shipper_addr3,   --44798
	shipper_nmctst,  
    ivh_consignee,     
	consignee_name,  
	consignee_addr,  
	consignee_addr2,  
	consignee_addr3,   --44798
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
	UPPER(ivd_billto_name),  
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
	cmp_altid,		
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	ivh_showshipper,  
	ivh_showcons,  
	terms_name,  
	ivh_carrier,
	ivh_charge,
	ivh_revtype3_t,
	vin_number,
	fgt_number,
	revtype3_name,
	bol_number,  --44798  
 	ivh_rateby,
	ord_description
from #invtemp_tbl
where ivd_charge <>0
  
/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 select @ret_value = @@ERROR   
return @ret_value  
GO
GRANT EXECUTE ON  [dbo].[invoice_template156] TO [public]
GO
