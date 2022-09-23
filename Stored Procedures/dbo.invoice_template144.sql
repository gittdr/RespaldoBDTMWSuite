SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[invoice_template144](@invoice_nbr   int,@copies  int)  
as  
/* PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND  
 1 - IF SUCCESFULLY EXECUTED  
 @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS  
  
	PTS 42880 - DJM - New Invoice Format.  Initially copied from invoice_template120
	PTS 44397  -DJM - Modified to default the cmp_misc4 value to 15 if it's null.
*/  
  
declare 
	@temp_name   varchar(100) ,  
	@temp_addr   varchar(100) ,  
	@temp_addr2  varchar(100),  
	@temp_nmstct varchar(30),  
	@temp_altid  varchar(25),  
	@counter    int,  
	@ret_value  int,  
	@temp_terms    varchar(20),  
	@varchar50 varchar(50),
	@varchar255 varchar(255),
	@cmd_code varchar(8),
	@MinFgt int,
	@MinOrd int,@ref_number varchar(30), @count int,@minseq int, @minref varchar(30),
	@ref_string varchar(254), @MinRefType varchar(6), @Minstp int, @minname varchar(100),
	@MinIvdNumber int,
	@MinFgtSeq INT,
	@SEQ INT 



  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
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
	Case
		When invoiceheader.ivh_tractor = 'UNKNOWN ' Then ''      		
		Else invoiceheader.ivh_tractor
		End ivh_tractor,
	Case
		When invoiceheader.ivh_trailer = 'UNKNOWN ' Then ''      		
		Else invoiceheader.ivh_trailer
		End ivh_trailer,    
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
	invoicedetail.ivd_sequence + 999 as ivd_sequence,     
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
	cht_rollintoLH = coalesce(invoicedetail.cht_rollintoLH, 0),
	invoiceheader.ivh_freight_miles,  
	invoiceheader.tar_tarriffnumber,  
	invoiceheader.tar_tariffitem,  
	1 copies,  
	chargetype.cht_basis,  
	chargetype.cht_description,
	cht_primary = coalesce(cht_primary, 'N'),
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
	@varchar255 freight_refnumbers  ,
	@varchar255 stops_refnumbers,
	@varchar50 cmp_misc4
into #invtemp_tbl  
FROM invoiceheader inner join invoicedetail on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
              left outer join chargetype on chargetype.cht_itemcode = invoicedetail.cht_itemcode
              left outer join commodity on invoicedetail.cmd_code = commodity.cmd_code
WHERE invoiceheader.ivh_hdrnumber = @invoice_nbr
union all
select invoiceheader.ivh_invoicenumber,     
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
	Case
		When invoiceheader.ivh_tractor = 'UNKNOWN ' Then ''      		
		Else invoiceheader.ivh_tractor
		End ivh_tractor,
	Case
		When invoiceheader.ivh_trailer = 'UNKNOWN ' Then ''      		
		Else invoiceheader.ivh_trailer
		End ivh_trailer,    
	invoiceheader.ivh_user_id1,     
	invoiceheader.ivh_user_id2,     
	invoiceheader.ivh_ref_number,     
	invoiceheader.ivh_driver2,     
	invoiceheader.mov_number,     
	invoiceheader.ivh_edi_flag,     
	invoiceheader.ord_hdrnumber,     
	0,     
	stops.stp_number,     
	freightdetail.fgt_description,     
	null,     
	null,     
	0,     
	null,  
	null ivd_taxable1,   -- taxable flags not set on ivd for gst,pst,etc    
	null ivd_taxable2,  
	null ivd_taxable3,  
	null ivd_taxable4,  
	null,     
	null,     
	null,     
	null,     
	null,     
	null,     
	null,     
	@temp_name ivd_billto_name,  
	@temp_addr ivd_billto_addr,  
	@temp_addr2 ivd_billto_addr2,  
	@temp_nmstct ivd_billto_nmctst,  
	null,     
	null,     
	null,     
	fgt_sequence,
	null,     
	freightdetail.cmd_code,     
	company.cmp_id,     
	@temp_name stop_name,  
	@temp_addr stop_addr,  
	@temp_addr2 stop_addr2,  
	@temp_nmstct stop_nmctst,  
	null,     
	null,     
	freightdetail.fgt_weight,     
	freightdetail.fgt_weightunit,     
	null,     
	null,     
	null,     
	null,     
	null,     
	null,     
	null,     
	null,  
	0 cht_rollintoLH,
	invoiceheader.ivh_freight_miles,  
	invoiceheader.tar_tarriffnumber,  
	invoiceheader.tar_tariffitem,  
	1 copies,  
	null cht_basis,  
	null cht_description,
	'Y' cht_primary,
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
	@varchar255 freight_refnumbers  ,
	@varchar255 stops_refnumberss,
	@varchar50 cmp_misc4
from stops left outer join freightdetail on stops.stp_number = freightdetail.stp_number
        left outer join commodity on freightdetail.cmd_code = commodity.cmd_code
        inner join company on stops.cmp_id = company.cmp_id,
        invoiceheader
where stops.ord_hdrnumber = (select top 1 invoiceheader.ord_hdrnumber from invoiceheader where invoiceheader.ivh_hdrnumber = @invoice_nbr)
  and stp_sequence = (select min(stp_sequence) from stops where ord_hdrnumber = (select top 1 invoiceheader.ord_hdrnumber from invoiceheader where invoiceheader.ivh_hdrnumber = @invoice_nbr) and stp_type = 'PUP')
  and invoiceheader.ivh_hdrnumber = @invoice_nbr

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
			cmp_contact = company.cmp_contact,
			cmp_misc4 = company.cmp_misc4 --	PTS 42880
		  from #invtemp_tbl, company  
		  where company.cmp_id = #invtemp_tbl.ivh_billto  

 Else   
	  update #invtemp_tbl  
	  set ivh_billto_name = company.cmp_mailto_name,  
		ivh_billto_addr =  company.cmp_mailto_address1 ,  
		ivh_billto_addr2 = company.cmp_mailto_address2,     
		ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct)))+ ' ' + IsNull(company.cmp_mailto_zip,''),  
		#invtemp_tbl.cmp_altid = company.cmp_altid ,  
		cmp_contact = company.cmp_contact, 
		cmp_misc4 = company.cmp_misc4 --	PTS 42880
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
--where company.cmp_id = #invtemp_tbl.ivh_shipper   
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
--where company.cmp_id = #invtemp_tbl.ivh_consignee   
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
from  #invtemp_tbl, city RIGHT OUTER JOIN stops ON city.cty_code = stops.stp_city
where  #invtemp_tbl.stp_number IS NOT NULL  
 and stops.stp_number =  #invtemp_tbl.stp_number  
 --and city.cty_code =* stops.stp_city  
  
update #invtemp_tbl  
set terms_name = la.name  
from labelfile la  
where la.labeldefinition = 'creditterms' and  
     la.abbr = #invtemp_tbl.ivh_terms  


--PTS# 26601 ILB 01/27/2005
--freight level reference numbers
select  @minord = min(ord_hdrnumber) from #invtemp_tbl
set @minstp = 0
set @count = 0
set @minseq = 0
set @minref = ''
set @minreftype = ''
set @ref_string = ''
set @minfgt = 0
set @cmd_code = ''
set @MinIvdNumber = 0
set @minfgtseq = 0
SET @SEQ = 0

WHILE (SELECT COUNT(*) FROM #invtemp_tbl WHERE stp_number > @MinStp) > 0
	BEGIN
          SELECT @MinStp = (SELECT MIN(stp_number) FROM #invtemp_tbl WHERE stp_number > @MinStp) 	     	 
--          print 'Minstp: ' + cast(@MinStp as varchar)

	        WHILE (select count(*) from freightdetail where stp_number = @minstp AND fgt_sequence >@minfgtseq) > 0					
        	   Begin 
		    SELECT @MinFgtSeq = (select Min(fgt_SEQUENCE) from freightdetail where stp_number = @Minstp AND fgt_sequence >@minfgtseq)	
		    SELECT @MinFgt    = (select Min(fgt_number) from freightdetail where stp_number = @Minstp and fgt_sequence = @minfgtseq)
		    SELECT @MinIvdNumber = (select ivd_number from invoicedetail where fgt_number = @MinFgt and ivh_hdrnumber = @invoice_nbr)
		    SELECT @cmd_code  = (select cmd_code from freightdetail where fgt_number = @minFgt and fgt_sequence = @minfgtseq)			

            select @REF_STRING = @REF_STRING + ref_type + ': ' + ref_number + ','
            from referencenumber
            where ord_hdrnumber = @MinOrd
              and ref_tablekey  = @MinFgt
              and ref_table     = 'freightdetail'
            order by ref_sequence;
             /* 38712 getting SQL error invalid length parameter */ 
            If len(@ref_string) > 1
              set @REF_STRING = left(coalesce(@REF_STRING,''),len(coalesce(@REF_STRING,'')) - 1);
            set @MinIvdNumber = coalesce(@MinIvdNumber, 0);

			UPDATE #invtemp_tbl
		           SET freight_refnumbers = @REF_STRING
		         WHERE ivd_number = @MinIvdNumber
                   and cmd_code = @cmd_code

			set @minref = ''	
			set @minreftype = ''	
			set @ref_string = ''
			set @cmd_code = ''			
		END
		
		SET @MinFgtSeq = 0
	END  


--Stop level reference numbers
set @minstp = 0
set @minref = ''
set @minreftype = ''
set @minseq = 0
set @ref_string = ''
set @MinIvdNumber = 0

WHILE (SELECT COUNT(*) FROM #invtemp_tbl WHERE stp_number > @MinStp) > 0
	BEGIN
          SELECT @MinStp = (SELECT MIN(stp_number) FROM #invtemp_tbl WHERE stp_number > @MinStp)
          
	  WHILE (SELECT COUNT(*) 
                   FROM referencenumber 
                  WHERE ref_sequence > @MinSeq and 
                        ref_tablekey = @Minstp and 
                        ord_hdrnumber = @MinOrd and ref_table = 'stops') > 0
	      	 BEGIN
	               
	 	 SELECT @count = @count + 1	
                 
                 SELECT @MinSeq = (SELECT MIN(ref_sequence) FROM referencenumber WHERE ref_sequence > @MinSeq and ref_tablekey = @Minstp and ord_hdrnumber = @MinOrd and ref_table = 'stops')       	       
                 	  

  	         select @MinRef = ref_number,
	                @MinRefType = ref_type
	           from referencenumber
		  where ref_sequence = @MinSeq and
		        ref_tablekey = @Minstp and
                        ord_hdrnumber =@MinOrd and
                        ref_table = 'stops' 
				                 
		 
	         IF @count = 1
			IF @MinRef <> ''
			BEGIN					
				SELECT @REF_STRING = @MinRefType+': '+@MINREF					
	                END
		
		 IF @count = 2
			IF @MinRef <> ''
			BEGIN					 
			        SELECT @REF_STRING = @REF_STRING+','+@MinRefType+': '+@MINREF			
	                END
		 IF @count = 3
			IF @MinRef <> ''
			BEGIN
				SELECT @REF_STRING = @REF_STRING+','+@MinRefType+': '+@MINREF			
	                END

		END

	 	UPDATE #invtemp_tbl
		   SET stops_refnumbers = isnull(@REF_STRING,'')
	         WHERE stp_number = @Minstp 
                       
		set @minseq = 0
                set @count = 0	                       
		set @minref = ''	
		set @minreftype = ''	
		set @ref_string = ''


	END

--only show the first stop name for multiple records
set @minstp = 0
set @minseq = 0
set @MinIvdNumber = 0
set @minname = ''
WHILE (SELECT COUNT(*) FROM #invtemp_tbl WHERE ivd_sequence > @Minseq) > 0
--WHILE (SELECT COUNT(*) FROM #invtemp_tbl WHERE stp_number > @MinStp) > 0
	BEGIN
          --SELECT @MinStp = (SELECT MIN(stp_number) FROM #invtemp_tbl WHERE stp_number > @MinStp)
          SELECT @Minseq = (SELECT MIN(ivd_sequence) FROM #invtemp_tbl WHERE ivd_sequence > @Minseq)

	  --print cast(@Minseq as varchar(20))
	  
	  --SELECT @MinName = (select min(stop_name) from #invtemp_tbl where stp_number = @MinStp)
          SELECT @MinName = (select min(stop_name) from #invtemp_tbl where ivd_sequence = @Minseq)
	  
	  --print @minname	

          SELECT @MinIvdNumber = (select min(ivd_number) from #invtemp_tbl where stp_number = @minstp and stop_name = @minname ) 
	  
	  --print cast(@MinIvdNumber as varchar(20))
	
         
	 Update #invtemp_tbl
             set stop_name = '',
                 stop_nmctst = '',
                 stop_addr = '',
                 stop_addr2 = ''
           where stop_name = @minname and
		 ivd_sequence <> @Minseq	

         set @minname = ''
         set @minivdnumber = 0
                 
	END     
--END PTS# 26601 ILB 01/27/2005



      
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
		ivh_taxamount1,    -- 50 
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
		ivd_description,     -- 80
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
		ivd_itemquantity,     -- 100
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
		ivd_volunit,     -- 120
		ivd_orig_cmpid,     
		ivd_payrevenue,  
		cht_rollintoLH,
		ivh_freight_miles,  
		tar_tarriffnumber,  
		tar_tariffitem,  
		@counter,  
		cht_basis,  
		cht_description,  
		cht_primary,
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
		cons_geoloc ,
		--PTS# 22601 ILB 01/27/2005
		isnull(freight_refnumbers,'') freight_refnumbers,
		isnull(stops_refnumbers,'') stops_refnumbers,
		--END PTS# 22601 ILB 01/27/2005 
		isNull(cmp_misc4,'15') cmp_misc4
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
	isNull(ivh_totalcharge,0) ivh_totalcharge,     
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
	ivh_destpoint,     -- 25
	destpoint_name,  
	dest_addr,  
	dest_addr2,  
	dest_nmctst,  
	ivh_invoicestatus,     
	ivh_origincity,     
	ivh_destcity,     
	ivh_originstate,     
	ivh_deststate,     
	ivh_originregion1,     -- 35
	ivh_destregion1,     
	ivh_supplier,     
	ivh_shipdate,     
	ivh_deliverydate,     
	ivh_revtype1,     
	ivh_revtype2,     
	ivh_revtype3,     
	ivh_revtype4,     
	ivh_totalweight,     
	ivh_totalpieces,     -- 45
	ivh_totalmiles,     
	ivh_currency,     
	ivh_currencydate,     
	ivh_totalvolume,   
	ivh_taxamount1,    -- 50 
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
	ivh_trailer,     -- 70
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
	isNull(ivd_quantity,0) ivd_quantity,     
	isNull(ivd_rate,0) ivd_rate,     
	isNull(ivd_charge,0) ivd_charge,     
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
	ivd_itemquantity,     -- 100
	ivd_subtotalptr,     
	ivd_allocatedrev,     
	ivd_sequence,     
	ivd_refnum,     
	cmd_code,   
	cmp_id,     
	isnull(stop_name,'')stop_name,  
	isnull(stop_addr,'')stop_addr,  
	isnull(stop_addr2,'')stop_addr2,  
	isnull(stop_nmctst,'')stop_nmctst,  
	ivd_distance,     
	ivd_distunit,     
	ivd_wgt,     
	ivd_wgtunit,     
	ivd_count,     
	ivd_countunit,     
	evt_number,     
	ivd_reftype,     
	ivd_volume,     
	ivd_volunit,     -- 120
	ivd_orig_cmpid,     
	ivd_payrevenue,  
	ivh_freight_miles,  
	tar_tarriffnumber,  
	tar_tariffitem,  
	copies,  
	cht_basis,  
	cht_description,  
	cht_primary,
	cmd_name,  
	cmp_altid,  
	ivh_showshipper,  
	ivh_showcons,
	terms_name,  
	ivh_billto_addr3,  
	cmp_contact,  
	shipper_geoloc,  
	cons_geoloc,
	--PTS# 22601 ILB 01/27/2005
	isnull(freight_refnumbers,'') freight_refnumbers,
	isnull(stops_refnumbers,'') stops_refnumbers,
	--END PTS# 22601 ILB 01/27/2005 
	cht_rollintolh,
	isNull(cmp_misc4,'15') cmp_misc4
from #invtemp_tbl  

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 select @ret_value = @@ERROR   
return @ret_value
  
GO
GRANT EXECUTE ON  [dbo].[invoice_template144] TO [public]
GO
