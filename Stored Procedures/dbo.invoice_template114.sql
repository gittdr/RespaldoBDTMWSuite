SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  create procedure [dbo].[invoice_template114](@invoice_nbr int, @copies int)  
as
/**
 * 
 * NAME:
 * dbo.invoice_template114
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Return data for invoice format 114
 *
 * RETURNS:
 * 0 - IF NO DATA WAS FOUND  
 * 1 - IF SUCCESFULLY EXECUTED
 * @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS   
 *
 * RESULT SETS: 
 * see retrun SET
 *
 * PARAMETERS:
 * 001 - @invoice_nbr INT,
 * 002 - @copies INT
 *
 * REVISION HISTORY:
 * 05/03/07.01 PTS36791 - OS - Created stored proc as modification of proc for invoice_template
 * 9/25/07 DPETE 39565 Customer needs to use fgt_class3 rather than fgt_class
 *
 **/  
  
declare @temp_name   varchar(100) ,  
 @temp_addr   varchar(100) ,  
 @temp_addr2  varchar(100),  
 @temp_nmstct varchar(30),  
 @temp_altid  varchar(25),  
 @counter    int,  
 @ret_value  int,  
 @temp_terms    varchar(20),  
 @varchar50 varchar(50)  
  

/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
 NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/ 
create table #invtemp_tbl   
(ivh_invoicenumber varchar(13) null,     
  ivh_hdrnumber int  null,  
  ivh_billto varchar(8) null,
   ivh_billto_name varchar(100) null,
  ivh_billto_addr varchar(100) null,
  ivh_billto_addr2 varchar(100) null,       
  ivh_billto_nmctst varchar(36) null,
   ivh_terms varchar(20) null,   
  ivh_totalcharge money null,
  ivh_shipper varchar(8) null,
  shipper_name varchar(100) null,
  shipper_addr varchar(100) null,
  shipper_addr2 varchar(100) null,
  shipper_nmctst varchar(36) null,
  ivh_consignee varchar(8) null, 
  consignee_name varchar(100) null, 
 consignee_addr varchar(100) null,
  consignee_addr2 varchar(100) null,
  consignee_nmctst varchar(36) null,
  ivh_originpoint varchar(8) null,  
  originpoint_name varchar(100) null,
  origin_addr varchar(100) null,
  origin_addr2 varchar(100) null,
  origin_nmctst varchar(36) null,
  ivh_destpoint varchar(8) null,  
  destpoint_name varchar(100) null,
  dest_addr varchar(100) null,
  dest_addr2 varchar(100) null,
  dest_nmctst varchar(36) null,
  ivh_invoicestatus varchar(6) null,   
  ivh_origincity int  null,    
  ivh_destcity int null,   
  ivh_originstate varchar(2) null,   
  ivh_deststate varchar(2) null,
  ivh_originregion1 varchar(6) null, 
  ivh_destregion1 varchar(6) null,   
  ivh_supplier varchar(8) null,   
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
  ivh_currencydate datetime null,   
  ivh_totalvolume float null,    
  ivh_taxamount1 money null,    
  ivh_taxamount2 money null,   
  ivh_taxamount3 money null,   
  ivh_taxamount4 money null,  
  ivh_transtype varchar(6) null, 
 ivh_creditmemo char(1) null,   
  ivh_applyto varchar(12) null, 
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
  ivh_trailer varchar(13) null,   
  ivh_user_id1 varchar(20) null,    
  ivh_user_id2 varchar(20) null,   
  ivh_ref_number varchar(30) null,   
  ivh_driver2 varchar(8) null,    
  mov_number int null,    
  ivh_edi_flag varchar(30) null,   
  ord_hdrnumber int null,   
  ivd_number int null,   
  stp_number int null,    
  ivd_description varchar(60) null,  
  cht_itemcode varchar(6) null,   
  ivd_quantity float null,   
  ivd_rate money null,   
  ivd_charge money null,
   ivd_taxable1 char(1) null,
   ivd_taxable2 char(1) null,
   ivd_taxable3 char(1) null,
   ivd_taxable4 char(1) null,
   ivd_unit varchar(6) null,  
   cur_code varchar(6) null,   
   ivd_currencydate datetime null,   
   ivd_glnum varchar(32) null,   
   ivd_type varchar(6) null,  
   ivd_rateunit varchar(6) null,     
   ivd_billto varchar(8) null,    
   ivd_billto_name varchar(100) null,
   ivd_billto_addr varchar(100) null, 
   ivd_billto_addr2 varchar(100) null,  
   ivd_billto_nmctst varchar(36) null, 
   ivd_itemquantity float null,   
  ivd_subtotalptr int null,    
   ivd_allocatedrev money null,     
   ivd_sequence int null,     
   ivd_refnum varchar(30) null,   
   cmd_code varchar(8) null,     
   cmp_id varchar(8) null,    
  stop_name varchar(100) null, 
   stop_addr varchar(100) null, 
   stop_addr2 varchar(100) null, 
   stop_nmctst varchar(36) null, 
   ivd_distance float null,   
    ivd_distunit varchar(6) null,     
   ivd_wgt float null,   
    ivd_wgtunit varchar(6) null,     
    ivd_count float null,    
    ivd_countunit varchar(6) null,    
    evt_number int null,     
    ivd_reftype varchar(6) null,    
    ivd_volume float null,    
    ivd_volunit varchar(6) null,     
    ivd_orig_cmpid varchar(8) null,    
    ivd_payrevenue money null, 
   ivh_freight_miles float null, 
  tar_tarriffnumber varchar(12) null, 
  tar_tariffitem varchar(12) null,  
  copies int null,  
  cht_basis varchar(6) null, 
  cht_description varchar(30) null,  
  cmd_name varchar(60) null, 
  cmp_altid varchar(25) null, 
   ivh_hideshipperaddr CHAR(1) null, 
 ivh_hideconsignaddr CHAR(1) null, 
  ivh_showshipper varchar(8) null,    
 ivh_showcons varchar(8) null,  
 terms_name varchar(10) null,  
 ivh_charge MONEY null,
 ivh_billto_addr3  VARCHAR(100) null,
 cmp_contact VARCHAR(50) null,
 shipper_geoloc VARCHAR(50) null, 
 cons_geoloc VARCHAR(50) null,
 ivh_order_cmd_code VARCHAR(8) null,
 cmd_class VARCHAR(8)  null 
    )

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
 insert into #invtemp_tbl  
 SELECT  invoiceheader.ivh_invoicenumber,     
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
         SUBSTRING(invoiceheader.ivh_originstate,1,2),  -- defined 6   
         SUBSTRING(invoiceheader.ivh_deststate,1,2),  -- defined 6
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
         SUBSTRING(invoiceheader.ivh_remark,1,254), -- defined 255     
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
   ivd_taxable1 =  IsNull(chargetype.cht_taxtable1,invoicedetail.ivd_taxable1),   -- taxable flags not set on ivd for gst,pst,etc    
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
 end) ivh_showshipper,  
 (Case ivh_showcons   
  when 'UNKNOWN' then invoiceheader.ivh_consignee  
  else IsNull(ivh_showcons,invoiceheader.ivh_consignee)   
 end) ivh_showcons,  
 @temp_terms terms_name,  
 IsNull(ivh_charge,0) ivh_charge,  
 @temp_addr2    ivh_billto_addr3,  
 @varchar50 cmp_contact,  
 @varchar50 shipper_geoloc,  
 @varchar50 cons_geoloc,
 invoiceheader.ivh_order_cmd_code,
 c2.cmd_class2  -- ***WAS CMD_CLASS ***  c2.cmd_class
 
    FROM invoiceheader join invoicedetail on (invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber)
		left outer join chargetype on (chargetype.cht_itemcode = invoicedetail.cht_itemcode) 
		left outer join commodity on (invoicedetail.cmd_code = commodity.cmd_code)
		left outer join commodity c2 on (invoiceheader.ivh_order_cmd_code = c2.cmd_code)   
   WHERE  invoiceheader.ivh_hdrnumber = @invoice_nbr  
   
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
if (select count(*) from #invtemp_tbl) = 0  
begin  
	select @ret_value = 0    
	GOTO ERROR_END  
end  
 
If Not Exists (Select cmp_mailto_name From company c, #invtemp_tbl t  
	Where c.cmp_id = t.ivh_billto  
	And Rtrim(IsNull(cmp_mailto_name,'')) > ''  
	And t.ivh_terms in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3,   
    Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)  
	And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End )   
  
update #invtemp_tbl  
set ivh_billto_name = company.cmp_name,  
	ivh_billto_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,''),  
	#invtemp_tbl.cmp_altid = company.cmp_altid,  
    ivh_billto_addr = company.cmp_address1,  
    ivh_billto_addr2 = company.cmp_address2,  
    ivh_billto_addr3 = company.cmp_address3,  
	cmp_contact = company.cmp_contact  
from #invtemp_tbl join company on (company.cmp_id = #invtemp_tbl.ivh_billto)  

Else

update #invtemp_tbl  
set ivh_billto_name = company.cmp_mailto_name,  
    ivh_billto_addr =  company.cmp_mailto_address1 ,  
    ivh_billto_addr2 = company.cmp_mailto_address2,     
	ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct)))+ ' ' + IsNull(company.cmp_mailto_zip,''),  
	#invtemp_tbl.cmp_altid = company.cmp_altid ,  
	cmp_contact = company.cmp_contact  
from #invtemp_tbl join company on (company.cmp_id = #invtemp_tbl.ivh_billto)  
  
update #invtemp_tbl  
set originpoint_name = company.cmp_name,  
	origin_addr = company.cmp_address1,  
	origin_addr2 = company.cmp_address2,  
	origin_nmctst = substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip ,'')  
from #invtemp_tbl join company on (company.cmp_id = #invtemp_tbl.ivh_originpoint)
	join city on (city.cty_code = #invtemp_tbl.ivh_origincity)   

update #invtemp_tbl  
set destpoint_name = company.cmp_name,  
	dest_addr = company.cmp_address1,  
	dest_addr2 = company.cmp_address2,  
	dest_nmctst =substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,'')   
from #invtemp_tbl join company on (company.cmp_id = #invtemp_tbl.ivh_destpoint)
	join city on (city.cty_code =  #invtemp_tbl.ivh_destcity)  

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
	shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,''),  
	Shipper_geoloc = IsNull(cmp_geoloc,'')  
from #invtemp_tbl join company on (company.cmp_id = #invtemp_tbl.ivh_showshipper)  
  
-- There is no shipper city, so if the shipper is UNKNOWN, use the origin city to get the nmstct    
update #invtemp_tbl  
set shipper_nmctst = origin_nmctst  
from #invtemp_tbl  
-- PTS 28466 -- BL (start)  
-- ONLY show stop city/state if the show shipper city/state has no value
where rtrim(isnull(#invtemp_tbl.shipper_nmctst, ''))  = ''  
-- PTS 28466 -- BL (end)  
      
update #invtemp_tbl  
set consignee_name = company.cmp_name,  
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
from #invtemp_tbl join company on (company.cmp_id = #invtemp_tbl.ivh_showcons)  

-- There is no consignee city, so if the consignee is UNKNOWN, use the dest city to get the nmstct    
update #invtemp_tbl  
set consignee_nmctst = dest_nmctst  
from #invtemp_tbl  
-- PTS 28466 -- BL (start)  
-- ONLY show stop city/state if the show consignee city/state has no value
where rtrim(isnull(#invtemp_tbl.consignee_nmctst, ''))  = ''  
-- PTS 28466 -- BL (end)  
    
update #invtemp_tbl  
set stop_name = company.cmp_name,  
	stop_addr = company.cmp_address1,  
	stop_addr2 = company.cmp_address2  
from #invtemp_tbl join company on (company.cmp_id = #invtemp_tbl.cmp_id)  

-- dpete for UNKNOWN companies with cities must get city name from city table pts5319   
update #invtemp_tbl  
set  stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +IsNull(city.cty_zip,'')   
from  #invtemp_tbl join stops on (stops.stp_number =  #invtemp_tbl.stp_number)
	left outer join city on (city.cty_code = stops.stp_city) 
where  #invtemp_tbl.stp_number IS NOT NULL  

update #invtemp_tbl  
set terms_name = la.name  
from labelfile la  
where la.labeldefinition = 'creditterms' 
and la.abbr = #invtemp_tbl.ivh_terms  
      
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
 terms_name,  
 IsNull(ivh_charge,0) ivh_charge,  
        ivh_billto_addr3,  
 cmp_contact,  
 shipper_geoloc,  
 cons_geoloc,
 ivh_order_cmd_code,
 cmd_class
 from #invtemp_tbl  
 where copies = 1     
 end   
                                                                
ERROR_END:  
/* FINAL SELECT - FORMS RETURN SET */  
--select *  
--from #invtemp_tbl  
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
  terms_name,  
         ivh_billto_addr3,  
 cmp_contact,  
 shipper_geoloc,  
 cons_geoloc,
 ivh_order_cmd_code,
 cmd_class
 from #invtemp_tbl
  
/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 select @ret_value = @@ERROR   
return @ret_value  

GO
GRANT EXECUTE ON  [dbo].[invoice_template114] TO [public]
GO
