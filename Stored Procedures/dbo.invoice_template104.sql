SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[invoice_template104]  (@p_invoice_nbr int, @p_copies int)			
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
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 *2/2/99 add cmp_altid from useasbillto company to return set  
 *1/5/00 dpete PTS6469 if you have an UNKNOWN consignee or shipper (origin or dest) use the city name in the city table  
 *06/29/2001 Vern Jewett  vmj1 PTS 10870: not returning copy # correctly.  
 *04/22/2002  Jyang add terms_name to return set  
 *12/5/2 16314 DPETE use company settings to control terms and linehaul restricitons on mail to  
 *DPETE 16739 3/26/03 Add cmp_contact for billto company, shipper_geoloc, cons geoloc  to return set for format 41  
 *09/27/2006 - PTS# 34086 - Imari L. Bremer - Add new invoice format 102
 *12/19/2006 - PTS35515 - jguo - correct ansi outer join and its performance problem 
 */
  
declare @temp_name   varchar(30) ,  
 @temp_addr      varchar(30) ,  
 @temp_addr2     varchar(30),  
 @temp_nmstct    varchar(30),  
 @temp_altid     varchar(25),  
 @counter        int ,  
 @ret_value      int ,  
 @temp_terms     varchar(20) ,  
 @varchar50      varchar(50) ,
--PTS# 19351 ILB 11/19/03
 @stp_number        int ,
 @ivh_showshipper   varchar(8),
 @shipper_id        varchar(8),
 @IVH_HDRNUMBER     int ,
 @IVH_INVOICENUMBER varchar(12),
 @ord_hdrnumber     int ,
 @billdate          datetime ,
 @shipdate          datetime ,
 @tractor           varchar(8) ,
 @trailer           varchar(8),
 @freight_miles     int ,
 @billto            varchar(8),
 @fgt_no            int ,
 @stp_no            int ,
 @cmd_code          varchar(8),
 @fgt_desc          varchar(60),
 @fgt_wgt           float ,
 @fgt_wgtunit       varchar(6),
 @fgt_quantity      float,
 @fgt_vol           float,
 @fgt_cnt           int
--PTS# 19351 ILB 11/19/03   
  
/* SET FOR A SUCCESSFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
 NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/  
  
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
 	@varchar50 cons_geoloc  
    into #invtemp_tbl  
    FROM --invoiceheader, invoicedetail, chargetype, commodity  
	 invoiceheader JOIN invoicedetail ON (invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and invoiceheader.ivh_hdrnumber = @p_invoice_nbr)  --pts35515
         LEFT OUTER JOIN chargetype ON ( chargetype.cht_itemcode = invoicedetail.cht_itemcode)   
         --RIGHT OUTER JOIN chargetype ON ( chargetype.cht_itemcode = invoicedetail.cht_itemcode)   --pts35515
         LEFT OUTER JOIN commodity ON (invoicedetail.cmd_code = commodity.cmd_code) 

   --WHERE --(invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and  
  	 --(chargetype.cht_itemcode =* invoicedetail.cht_itemcode) and  
  	 --(invoicedetail.cmd_code *= commodity.cmd_code) and  
         --invoiceheader.ivh_hdrnumber = @p_invoice_nbr  --pts35515

/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
if (select count(*) from #invtemp_tbl) = 0  
 begin  
 select @ret_value = 0    
 GOTO ERROR_END  
 end  


--PTS#19351 ILB 11/19/03
DELETE 
  FROM #INVTEMP_TBL
 WHERE IVD_TYPE = 'PUP'

SELECT DISTINCT @ivh_showshipper   = ivh_showshipper,
                @SHIPPER_ID        = IVH_SHIPPER,
                @IVH_HDRNUMBER     = IVH_HDRNUMBER,
                @IVH_INVOICENUMBER = IVH_INVOICENUMBER,
                @ord_hdrnumber     = ord_hdrnumber,
                @billdate          = ivh_billdate,
                @shipdate          = ivh_shipdate,
                @tractor           = ivh_tractor,
                @trailer           = ivh_trailer,
	        @freight_miles     = ivh_freight_miles,
		@billto            = ivh_billto
FROM #INVTEMP_TBL

--Create a cursor based on the select statement below
DECLARE fgt_cursor CURSOR FOR  

--ILB 11/25/2003
SELECT fgt_number,stp_number,cmd_code,fgt_description,fgt_weight,fgt_quantity,
       fgt_volume, fgt_count,fgt_weightunit
  FROM freightdetail
-- WHERE stp_number = @stp_number
 WHERE stp_number IN (select distinct(stp_number) 
                        from stops
                       where stp_type = 'PUP' and
                             ord_hdrnumber = @ord_hdrnumber)
                     
ORDER BY fgt_sequence desc
--ILB 11/25/2003
    
--Populate the cursor based on the select statement above  
OPEN fgt_cursor  
  
--Execute the initial fetch of the first secondary trailer based on the leg
FETCH NEXT FROM fgt_cursor INTO @fgt_no,@stp_no,@cmd_code,@fgt_desc,@fgt_wgt,
                                @fgt_quantity,@fgt_vol,@fgt_cnt,@fgt_wgtunit
  
--If the fetch is succesful continue to loop
WHILE @@fetch_status = 0  
 BEGIN  
        INSERT INTO #invtemp_tbl
   	(ord_hdrnumber,cmp_id,IVH_SHIPPER,ivh_showshipper, IVD_TYPE, IVH_CHARGE, 
    	 COPIES,IVD_NUMBER,IVH_HDRNUMBER,IVH_INVOICENUMBER, ivh_billdate,ivh_shipdate,
    	 ivh_tractor,ivh_trailer,ivh_freight_miles,ivh_billto,cht_basis,cht_description,
         ivd_sequence )
	VALUES
   	(@ord_hdrnumber, @shipper_id ,@shipper_id, @ivh_showshipper, 'PUP', 0,
    	 1,0, @IVH_HDRNUMBER, @IVH_INVOICENUMBER,@billdate,@shipdate,
    	 @tractor,@trailer,@freight_miles,@billto,'SHP','Freight (Default)',
         0)
 
	Update #invtemp_tbl
	   set stp_number         = @stp_no,
	       ivd_description    = @fgt_desc,
	       cmd_name           = @fgt_desc,
	       cmd_code           = @cmd_code,
	       ivd_wgt            = Case
     					When @fgt_wgt <> 0 Then @fgt_wgt
                                        When @fgt_vol <> 0 Then @fgt_vol
                                        When @fgt_cnt <> 0 Then @fgt_cnt
     					Else @fgt_quantity
     				    End ,
	       ivd_wgtunit        = @fgt_wgtunit
	  from #invtemp_tbl
	 where #invtemp_tbl.ivd_description is null and
	       #invtemp_tbl.ord_hdrnumber = @ord_hdrnumber

	Update #invtemp_tbl 
           SET ivd_sequence = ivd_sequence + 1

   	--Fetch the next freightdetail in the list
   	FETCH NEXT FROM fgt_cursor INTO @fgt_no,@stp_no,@cmd_code,@fgt_desc,@fgt_wgt,
                                        @fgt_quantity,@fgt_vol,@fgt_cnt,@fgt_wgtunit 
  
 END 
  
--Close cursor  
CLOSE fgt_cursor

--Release cusor resources  
DEALLOCATE fgt_cursor

--PTS# 19351 ILB 11/19/03


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
  from #invtemp_tbl, company  
  where company.cmp_id = #invtemp_tbl.ivh_billto  
 Else   
  update #invtemp_tbl  
  set ivh_billto_name = company.cmp_mailto_name,  
    ivh_billto_addr =  company.cmp_mailto_address1 ,  
    ivh_billto_addr2 = company.cmp_mailto_address2,     
   ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct)))+ ' ' + IsNull(company.cmp_mailto_zip,''),  
   #invtemp_tbl.cmp_altid = company.cmp_altid ,  
   cmp_contact = company.cmp_contact  
  from #invtemp_tbl, company  
  where company.cmp_id = #invtemp_tbl.ivh_billto  
 --end  
 
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
 shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,''),  
 Shipper_geoloc = IsNull(cmp_geoloc,'')  
from #invtemp_tbl, company  
where company.cmp_id = #invtemp_tbl.ivh_showshipper  
  
-- There is no shipper city, so if the shipper is UNKNOWN, use the origin city to get the nmstct    
update #invtemp_tbl  
set shipper_nmctst = origin_nmctst  
from #invtemp_tbl  
where #invtemp_tbl.ivh_shipper = 'UNKNOWN'  
      
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
  
-- dpete for UNKNOWN companies with cities must get city name from city table pts5319   
update #invtemp_tbl  
set  stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +IsNull(city.cty_zip,'')   
--from  #invtemp_tbl, stops,city  
from  stops JOIN #invtemp_tbl ON (stops.stp_number = #invtemp_tbl.stp_number) 
      RIGHT OUTER JOIN city ON (city.cty_code = stops.stp_city )
where 	#invtemp_tbl.stp_number IS NOT NULL
--where  #invtemp_tbl.stp_number IS NOT NULL  
-- and stops.stp_number =  #invtemp_tbl.stp_number  
-- and city.cty_code =* stops.stp_city  
  
update #invtemp_tbl  
set terms_name = la.name  
from labelfile la  
where la.labeldefinition = 'creditterms' and  
     la.abbr = #invtemp_tbl.ivh_terms  
     
/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */  
select @counter = 1  
while @counter <>  @p_copies  
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
 cons_geoloc  
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
 cons_geoloc  
 from #invtemp_tbl  
/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 select @ret_value = @@ERROR   
return @ret_value 
GO
GRANT EXECUTE ON  [dbo].[invoice_template104] TO [public]
GO
