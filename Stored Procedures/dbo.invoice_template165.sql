SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  create procedure [dbo].[invoice_template165](@invoice_nbr   int,@copies  int)  
as  
/* PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND  
 1 - IF SUCCESFULLY EXECUTED  
 @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS  
  
4/28/09 PTS 46930 copy of invoice template 2 for format 165
*/  
  
declare @temp_name   varchar(100) ,  
 @temp_addr   varchar(100) ,  
 @temp_addr2  varchar(100),  
 @temp_nmstct varchar(30),  
 @temp_altid  varchar(25),  
 @counter    int,  
 @ret_value  int,  
 @temp_terms    varchar(20),  
 @varchar50 varchar(50),
 @orddescription varchar(60),
 @ordcontact varchar(30),
 @ordbycmpmisc1 varchar(254),
 @rollintoLHAmt money,
 @rateconvertion float



  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  

select @orddescription = ord_description,
@ordcontact = ord_contact,
@ordbycmpmisc1 = isnull(cmp_misc1,'')
from orderheader
left outer join company on ord_company = cmp_id
where ord_hdrnumber =
(select ord_hdrnumber 
from invoiceheader
where ivh_hdrnumber = @invoice_nbr)

select @orddescription = isnull(@orddescription,''),@ordcontact = isnull(@ordcontact,''),
@ordbycmpmisc1 = isnull(@ordbycmpmisc1,'')
  
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
  invoiceheader.ivh_invoicestatus,      
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
  invoicedetail.ivd_type,     
  invoicedetail.ivd_rateunit,     
  invoicedetail.ivd_sequence,     
  invoicedetail.ivd_refnum,     
  invoicedetail.cmd_code,     
  invoicedetail.cmp_id,     
  @temp_name stop_name,  
  @temp_nmstct stop_nmctst,  
  invoicedetail.ivd_distance,     
  invoicedetail.ivd_distunit,     
  invoicedetail.ivd_wgt,     
  invoicedetail.ivd_wgtunit,     
  invoicedetail.ivd_count,     
  invoicedetail.ivd_countunit,       
  invoicedetail.ivd_reftype,     
  invoicedetail.ivd_volume,     
  invoicedetail.ivd_volunit,     
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
  ivh_showshipper,  
  ivh_showcons,
  ivh_charge,  
  @temp_addr2    ivh_billto_addr3,  
  @ordcontact ord_contact,  
  @orddescription ord_description,
  ordbycmp_misc1 = @ordbycmpmisc1,
  invoicedetail.cht_rollintolh
  into #invtemp_tbl
  FROM invoiceheader
  join invoicedetail on invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
  left outer join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
  left outer join commodity on invoicedetail.cmd_code = commodity.cmd_code  
  WHERE  invoiceheader.ivh_hdrnumber = @invoice_nbr 
  and ivd_charge <> 0 

   
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
if (select count(*) from #invtemp_tbl) = 0  
 begin  
   select @ret_value = 0    
   GOTO ERROR_END  
 end  

/*     *******************ROLLINTOLH************************     */
/* Handle possible roll into lh */

select @rollintoLHAmt = sum(ivd_charge)
from #invtemp_tbl where cht_rollintolh = 1

select @rollintoLHAmt = isnull(@rollintoLHAmt,0)

If @rollintoLHAmt <> 0 and exists(select 1 from #invtemp_tbl where (ivd_type = 'SUB' or cht_itemcode = 'MIN') and ivd_quantity <> 0) 
  BEGIN 
      -- determine if a rate conversion factor is involved in the line haul rate
      If exists (select 1 from #invtemp_tbl where cht_itemcode = 'MIN')
        BEGIN
          select @rateconvertion = unc_factor
          from #invtemp_tbl ttbl
          join unitconversion on ivd_unit = unc_from and ivd_rateunit = unc_to and unc_convflag = 'R'
          where ttbl.cht_itemcode = 'MIN'
          
          select @rateconvertion = isnull(@rateconvertion,1) 

          update #invtemp_tbl
          set ivd_charge = 
            case cht_itemcode
            when 'MIN' then ivd_charge + @rollintoLHAmt
            else 0
            end,
          ivd_rate = 
            case ivd_quantity
            when 1 then round((ivd_charge + @rollintoLHAmt) / @rateconvertion,4)
            else round((ivd_charge + @rollintoLHAmt) / (@rateconvertion * ivd_quantity),4)
            end
          from #invtemp_tbl tmp
          where ivd_type = 'SUB' or cht_itemcode = 'MIN'
        END
            
      else 
        BEGIN
          select @rateconvertion = unc_factor
          from #invtemp_tbl ttbl
          join unitconversion on ivd_unit = unc_from and ivd_rateunit = unc_to and unc_convflag = 'R'
          where ttbl.ivd_type = 'SUB'
          
          select @rateconvertion = isnull(@rateconvertion,1) 

          update #invtemp_tbl
          set ivd_charge =  ivd_charge + @rollintoLHAmt,
          ivd_rate = 
            case ivd_quantity
            when 1 then round((ivd_charge + @rollintoLHAmt) / @rateconvertion,4)
            else round((ivd_charge + @rollintoLHAmt) / (@rateconvertion * ivd_quantity),4)
            end
          from #invtemp_tbl tmp
          where ivd_type = 'SUB'
        END

    delete from #invtemp_tbl where cht_rollintolh = 1

  END
 /*     *******************ROLLINTOLH  END ********************     */
/*  set company location information */     
  
If Not Exists (
   Select cmp_mailto_name 
   From company c, #invtemp_tbl t  
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
   ivh_billto_addr3 = company.cmp_address3
   from #invtemp_tbl, company  
   where company.cmp_id = #invtemp_tbl.ivh_billto  
 Else   
   update #invtemp_tbl  
   set ivh_billto_name = company.cmp_mailto_name,  
   ivh_billto_addr =  company.cmp_mailto_address1 ,  
   ivh_billto_addr2 = company.cmp_mailto_address2,     
   ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct)))+ ' ' + IsNull(company.cmp_mailto_zip,''),  
   #invtemp_tbl.cmp_altid = company.cmp_altid 
   from #invtemp_tbl, company  
   where company.cmp_id = #invtemp_tbl.ivh_billto  
 

update #invtemp_tbl  
set shipper_name = company.cmp_name,  
 shipper_addr = 
    Case ivh_hideshipperaddr   
      when 'Y' then ''  
      else company.cmp_address1  
      end,  
 shipper_addr2 = 
    Case ivh_hideshipperaddr
       when 'Y'   then ''  
      else company.cmp_address2  
      end,  
 shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,'')
from #invtemp_tbl, company   
where company.cmp_id = #invtemp_tbl.ivh_showshipper  
  

      
update #invtemp_tbl  
set consignee_name = company.cmp_name,  
 consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +IsNull(company.cmp_zip, ''), 
 consignee_addr = 
   Case ivh_hideconsignaddr    
     when 'Y' then ''  
     else company.cmp_address1  
     end,      
 consignee_addr2 = 
   Case ivh_hideconsignaddr   
     when 'Y' then ''  
     else company.cmp_address2  
     end
 from #invtemp_tbl, company  
 where company.cmp_id = #invtemp_tbl.ivh_showcons     

    
update #invtemp_tbl  
set stop_name = company.cmp_name
from #invtemp_tbl, company  
where company.cmp_id = #invtemp_tbl.cmp_id  
  
-- dpete for UNKNOWN companies with cities must get city name from city table pts5319   
update #invtemp_tbl  
set  stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +IsNull(city.cty_zip,'')   
from  #invtemp_tbl, city  RIGHT OUTER JOIN  stops  ON  city.cty_code  = stops.stp_city   --pts40188 outer join conversion
where  #invtemp_tbl.stp_number IS NOT NULL  
 and stops.stp_number =  #invtemp_tbl.stp_number  
  


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
  ivh_invoicestatus,     
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
  ivd_type,     
  ivd_rateunit,     
  ivd_sequence,     
  ivd_refnum,     
  cmd_code,   
  cmp_id,     
  stop_name,  
  stop_nmctst,  
  ivd_distance,     
  ivd_distunit,     
  ivd_wgt,     
  ivd_wgtunit,     
  ivd_count,     
  ivd_countunit,       
  ivd_reftype,     
  ivd_volume,     
  ivd_volunit,     
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
  ivh_charge, 
  ivh_billto_addr3,  
  ord_contact,  
  ord_description,
  ordbycmp_misc1 ,
  cht_rollintolh
  from #invtemp_tbl  
  where copies = 1     
 end   
                                                              
ERROR_END:  
/* FINAL SELECT - FORMS RETURN SET */  

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
  ivh_invoicestatus,     
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
  ivd_type,     
  ivd_rateunit,     
  ivd_sequence,     
  ivd_refnum,     
  cmd_code,   
  cmp_id,     
  stop_name,  
  stop_nmctst,  
  ivd_distance,     
  ivd_distunit,     
  ivd_wgt,     
  ivd_wgtunit,     
  ivd_count,     
  ivd_countunit,      
  ivd_reftype,     
  ivd_volume,     
  ivd_volunit,     
  ivh_freight_miles,  
  tar_tarriffnumber,  
  tar_tariffitem,  
  copies,  
  cht_basis,  
  cht_description,  
  cmd_name,  
  cmp_altid,  
--  ivh_hideshipperaddr,  
--  ivh_hideconsignaddr,  
  ivh_showshipper,  
  ivh_showcons,
  ivh_charge,  
  ivh_billto_addr3,  
  ord_contact,  
  ord_description,
  ordbycmp_misc1
-- cht_rollintolh 
 from #invtemp_tbl  
/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 select @ret_value = @@ERROR   
return @ret_value  
  

GO
GRANT EXECUTE ON  [dbo].[invoice_template165] TO [public]
GO
