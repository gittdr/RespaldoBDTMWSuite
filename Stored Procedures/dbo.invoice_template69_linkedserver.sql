SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
  
create procedure [dbo].[invoice_template69_linkedserver](@invoice_nbr   int,@copies  int)    
  
as    
  
SET NOCOUNT ON   
  
SET ANSI_NULLS ON  
  
SET ANSI_WARNINGS ON  
  
   
  
/******  CODE MUST BE UNCOMMENTED OUT AT  <<>>  TO WORK FOR  MW Logisitics call to their GP server ********************** 
   to test standalone comment out into ##invtemp_tbl_temp    near end of proc
   this passes the data to invoice_template69 so it can return it to the datawindow


PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND    
  
 1 - IF SUCCESFULLY EXECUTED    
  
 @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS    
  
   
  
CUSTOMER (M&W)  WILL UNCOMMENT OUT HARD CODE TO GET TO GP BALANCE DUE    
  
 * 11/14/2007.01 ? PTS40188 - JGUO ? convert old style outer join syntax to ansi outer join syntax.  
 * 11/16/2007.01 - JG (40360)due to distributed query issue, the proc is renamed, a wrapper invoice_template69 will call this proc  
 * 11/16/2007    - DPETE PTS40360 customer not getting commodities for all deliveries
 * 12/20/07      - DPETE PTS 40360 zip code is coming from the city table for some locations
 * 08/23/2010 - SGB PTS 53556 increase size of  @temp_nmstct from varchar(30) to varchar(35) 
*/    
  
    
  
declare @temp_name   varchar(100) ,    
  
 @temp_addr   varchar(100) ,    
  
 @temp_addr2  varchar(100),    
  
 @temp_nmstct varchar(35),    -- PTS 53556 increase size of  @temp_nmstct from varchar(30) to varchar(35)
  
 @temp_altid  varchar(25),    
  
 @counter    int,    
  
 @ret_value  int,    
  
 @temp_terms    varchar(20),    
  
 @varchar50 varchar(50),  
  
 @gp_less_previous_payments   money,  
  
 @gp_balance_due  money,  
  
 @gp_invoicenumber      varchar(12),  
  
 @ivh_revtype1          VARCHAR(6)  
  
   
  
--DPH PTS 27645  CUSTOMER UNCOMMENTS TO MAKE COONECT TO GP WORK FOR THEM
/*   (Do not unvomment this section, code was moved lower down 12/10/07)
select 	@gp_invoicenumber = ivh_invoicenumber
from	invoiceheader
where	ivh_hdrnumber = @invoice_nbr

select 	@gp_balance_due = CURTRXAM
from	cledev.GreatPlainsBrentRN.dbo.rm20101  --servername.databasename.dbo.rm20101
where	DOCNUMBR = @gp_invoicenumber

select 	@gp_less_previous_payments = ORTRXAMT - @gp_balance_due
from	cledev.GreatPlainsBrentRN.dbo.rm20101  --servername.databasename.dbo.rm20101
where 	DOCNUMBR = @gp_invoicenumber
--DPH PTS 27645 
  */
  
   
  
--Do Not Comment Out  
  
select @gp_balance_due = IsNull(@gp_balance_due, 0)  
  
Select @gp_less_previous_payments = IsNull(@gp_less_previous_payments, 0)  
  
--Do Not Comment Out  
  
    
  
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
  
         invoicedetail.stp_number stp_number,       
  
         invoicedetail.ivd_description,       
  
         invoicedetail.cht_itemcode,       
  
         invoicedetail.ivd_quantity,       
  
         invoicedetail.ivd_rate,       
  
         invoicedetail.ivd_charge,    
  
   --invoicedetail.ivd_taxable1,       
  
         --invoicedetail.ivd_taxable2,       
  
 -- invoicedetail.ivd_taxable3,       
  
         --invoicedetail.ivd_taxable4,     
  
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
  
 @gp_less_previous_payments gp_less_previous_payments,  
  
 @gp_balance_due gp_balance_due ,  
  
 invoicedetail.ivd_remark,  
  
 0 stop_weight,  
  
 0 stop_count,  
  
 0 stop_volume  
  
    into #invtemp_tbl    
  
    FROM chargetype  RIGHT OUTER JOIN  invoicedetail  ON  chargetype.cht_itemcode  = invoicedetail.cht_itemcode     
  
            LEFT OUTER JOIN  commodity  ON  invoicedetail.cmd_code  = commodity.cmd_code ,  
  
            invoiceheader    
  
   WHERE ( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and    
  
       invoiceheader.ivh_hdrnumber = @invoice_nbr    
  
--  ( invoiceheader.ivh_hdrnumber between @invoice_no_lo and @invoice_no_hi) AND    
  
--     ( @invoice_status  in ('ALL', invoiceheader.ivh_invoicestatus)) and    
  
--  ( @revtype1 in('UNK', invoiceheader.ivh_revtype1)) and    
  
--  ( @revtype2 in('UNK', invoiceheader.ivh_revtype2)) and         
  
--         ( @revtype3 in('UNK', invoiceheader.ivh_revtype3)) and      
  
--         ( @revtype4 in('UNK', invoiceheader.ivh_revtype4)) and    
  
--  ( @billto in ('UNKNOWN',invoiceheader.ivh_billto)) and    
  
--  ( @shipper in ('UNKNOWN', invoiceheader.ivh_shipper)) and    
  
--  ( @consignee in ('UNKNOWN',invoiceheader.ivh_consignee)) and    
  
--  (invoiceheader.ivh_shipdate between @shipdate1 and @shipdate2 ) and    
  
--         (invoiceheader.ivh_deliverydate between @deldate1 and @deldate2) and    
  
--  ((invoiceheader.ivh_billdate between @billdate1 and @billdate2) or    
  
--  (invoiceheader.ivh_billdate IS null))    
  
     
  
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */    
  
if (select count(*) from #invtemp_tbl) = 0    
  
 begin    
  
 select @ret_value = 0      
  
 GOTO ERROR_END    
  
 end   
  
/*  <<>>   
  
--PTS28452 MBR 12/13/05 Moved Dan Hudec's original code here and tied it to the revtype1 field  
  
-- for which GP database to connect to.  
  
--  CUSTOMER (M&W) UNCOMMENTS CODE TO MAKE CONENCTION TO GP  
  
   
  
SELECT @ivh_revtype1 = ISNULL(MIN(ivh_revtype1), 'UNK')  
  
  FROM #invtemp_tbl  
  
    
  
IF @ivh_revtype1 = 'MWLT' OR @ivh_revtype1 = 'UNK'  
  
BEGIN    
  
  --DPH PTS 27645  
  
      select      @gp_invoicenumber = ivh_invoicenumber  
  
        from      invoiceheader  
  
       where      ivh_hdrnumber = @invoice_nbr  
  
   
  
      select      @gp_balance_due = CURTRXAM  
  
        from      mwltmw.mwl.dbo.rm20101  --servername.databasename.dbo.rm20101  
  
       where      DOCNUMBR = @gp_invoicenumber  
  
   
  
      select      @gp_less_previous_payments = ORTRXAMT - @gp_balance_due  
  
        from      mwltmw.mwl.dbo.rm20101  --servername.databasename.dbo.rm20101  
  
       where      DOCNUMBR = @gp_invoicenumber  
  
--DPH PTS 27645   
  
END  
  
   
  
IF @ivh_revtype1 = 'MWBL'  
  
BEGIN    
  
  --DPH PTS 27645  
  
      select      @gp_invoicenumber = ivh_invoicenumber  
  
        from      invoiceheader  
  
       where      ivh_hdrnumber = @invoice_nbr  
  
   
  
      select      @gp_balance_due = CURTRXAM  
  
        from      mwltmw.mwb.dbo.rm20101  --servername.databasename.dbo.rm20101  
  
       where      DOCNUMBR = @gp_invoicenumber  
  
   
  
      select      @gp_less_previous_payments = ORTRXAMT - @gp_balance_due  
  
        from      mwltmw.mwb.dbo.rm20101  --servername.databasename.dbo.rm20101  
  
       where      DOCNUMBR = @gp_invoicenumber  
  
--DPH PTS 27645   
  
END  
  
   
  
IF @ivh_revtype1 = 'MWIR'  
  
BEGIN    
  
  --DPH PTS 27645  
  
      select      @gp_invoicenumber = ivh_invoicenumber  
  
        from      invoiceheader  
  
  where      ivh_hdrnumber = @invoice_nbr  
  
   
  
      select      @gp_balance_due = CURTRXAM  
  
        from      mwltmw.mwi.dbo.rm20101  --servername.databasename.dbo.rm20101  
  
       where      DOCNUMBR = @gp_invoicenumber  
  
   
  
      select      @gp_less_previous_payments = ORTRXAMT - @gp_balance_due  
  
        from      mwltmw.mwi.dbo.rm20101  --servername.databasename.dbo.rm20101  
  
       where      DOCNUMBR = @gp_invoicenumber  
  
--DPH PTS 27645   
  
END    
  
<<>> */  
--Do Not Comment Out  
  
select @gp_balance_due = IsNull(@gp_balance_due, 0)  
  
Select @gp_less_previous_payments = IsNull(@gp_less_previous_payments, 0)  
  
Update #invtemp_tbl  
  
   set gp_balance_due = @gp_balance_due,  
  
       gp_less_previous_payments = @gp_less_previous_payments  
  
--Do Not Comment Out    
  
    
  
  If Not Exists (Select cmp_mailto_name From company c, #invtemp_tbl t    
  
        Where c.cmp_id = t.ivh_billto    
  
   And Rtrim(IsNull(cmp_mailto_name,'')) > ''    
  
   And t.ivh_terms in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3,     
  
    Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)    
  
   And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End )     
  
    
  
  update #invtemp_tbl    
  
  set ivh_billto_name = company.cmp_name,    
  
   ivh_billto_nmctst = case charindex('/', company.cty_nmstct)
     when 0 then company.cty_nmstct + ' ' + IsNull(company.cmp_zip,'')
     else  substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct) ))+ ' ' + IsNull(company.cmp_zip,'') /* leaving / in return works with DW */
     end,    
  
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
    ivh_billto_nmctst = 
     case charindex('/',company.mailto_cty_nmstct)
       when 0 then company.mailto_cty_nmstct + ' ' + ISNULL(cmp_mailto_zip ,'')
       else substring(company.mailto_cty_nmstct,1, (charindex('/',company.mailto_cty_nmstct) ))+ ' ' + ISNULL(cmp_mailto_zip ,'') /* leaving / in return works with DW */
    end           ,   
  
   #invtemp_tbl.cmp_altid = company.cmp_altid   
  
  from #invtemp_tbl, company    
  
  where company.cmp_id = #invtemp_tbl.ivh_billto    
  
 --end    
  
   
  
update #invtemp_tbl    
  
set originpoint_name = company.cmp_name,    
  
 origin_addr = company.cmp_address1,    
  
 origin_addr2 = company.cmp_address2,    
  
 origin_nmctst = case charindex('/',company.cty_nmstct)
    when 0 then company.cty_nmstct+ ' ' + ISNULL(cmp_zip ,'')
    else substring(company.cty_nmstct,1, (charindex('/',company.cty_nmstct) ))+ ' ' + ISNULL(cmp_zip ,'') /* leaving / in return works with DW */
    end           
 
from #invtemp_tbl, company   
where company.cmp_id = #invtemp_tbl.ivh_originpoint    
       
  
        
  
update #invtemp_tbl    
  
set destpoint_name = company.cmp_name,    
  
 dest_addr = company.cmp_address1,    
  
 dest_addr2 = company.cmp_address2,    
  
 dest_nmctst = case charindex('/',company.cty_nmstct)
    when 0 then company.cty_nmstct+ ' ' + ISNULL(cmp_zip ,'')
    else substring(company.cty_nmstct,1, (charindex('/',company.cty_nmstct) ))+ ' ' + ISNULL(cmp_zip ,'') /* leaving / in return works with DW */
    end           
  
from #invtemp_tbl, company  
  
where company.cmp_id = #invtemp_tbl.ivh_destpoint    
      
  
    
  
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
  
 shipper_nmctst = case charindex('/',company.cty_nmstct)
    when 0 then company.cty_nmstct+ ' ' + ISNULL(cmp_zip ,'')
    else substring(company.cty_nmstct,1, (charindex('/',company.cty_nmstct) ))+ ' ' + ISNULL(cmp_zip ,'') /* leaving / in return works with DW */
    end           
  
   
  
from #invtemp_tbl, company    
  
--where company.cmp_id = #invtemp_tbl.ivh_shipper     
  
where company.cmp_id = #invtemp_tbl.ivh_showshipper    
  
    
  
-- There is no shipper city, so if the shipper is UNKNOWN, use the origin city to get the nmstct      
  
update #invtemp_tbl    
  
set shipper_nmctst = origin_nmctst    
  
from #invtemp_tbl    
  
where #invtemp_tbl.ivh_shipper = 'UNKNOWN'      
   
  
   
  
   
  
--PTS37763 MBR 06/01/07  
  
update #invtemp_tbl    
  
set consignee_name = company.cmp_name,    
  
 consignee_addr = company.cmp_address1,    
  
 consignee_addr2 = company.cmp_address2,    
  
 consignee_nmctst =case charindex('/',company.cty_nmstct)
    when 0 then company.cty_nmstct + ' ' + ISNULL(cmp_zip ,'')
    else substring(company.cty_nmstct,1, (charindex('/',company.cty_nmstct) ))+ ' ' + ISNULL(cmp_zip ,'') /* leaving / in return works with DW */
    end           
  
from #invtemp_tbl, company   
  
where company.cmp_id = #invtemp_tbl.ivh_showcons 
  
  
      
  
update #invtemp_tbl    
  
set stop_name = company.cmp_name,    
  
 stop_addr = company.cmp_address1,    
  
 stop_addr2 = company.cmp_address2    
  
from #invtemp_tbl, company    
  
where company.cmp_id = #invtemp_tbl.cmp_id    
  
    
  
-- dpete for UNKNOWN companies with cities must get city name from city table pts5319     
  
update #invtemp_tbl    
  
set  stop_nmctst = case charindex('/',company.cty_nmstct)
               when 0 then company.cty_nmstct + ' ' + ISNULL(cmp_zip ,'')
               else substring(company.cty_nmstct,1, (charindex('/',company.cty_nmstct) - 1))+ ' ' + ISNULL(cmp_zip ,'')
               end               
from  #invtemp_tbl, company   
where    #invtemp_tbl.cmp_id <> 'UNKNOWN'
and  company.cmp_id = #invtemp_tbl.cmp_id 
/*  customer said they were getting city zips with the following code uncommented

update #invtemp_tbl     
set  stop_nmctst = case charindex('/',city.cty_nmstct)
               when 0 then city.cty_nmstct + ' ' + ISNULL(cty_zip ,'')
                 else substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct) - 1))+ ' ' + ISNULL(cty_zip ,'')
                 end    
from  #invtemp_tbl
join stops on #invtemp_tbl.stp_number = stops.stp_number
join city on stp_city = cty_code  
where    #invtemp_tbl.cmp_id = 'UNKNOWN'

  */
    
  
update #invtemp_tbl    
  
set terms_name = la.name    
  
from labelfile la    
  
where la.labeldefinition = 'creditterms' and    
  
     la.abbr = #invtemp_tbl.ivh_terms   
  
   
  
UPDATE #invtemp_tbl  
  
SET stop_weight = (SELECT ISNULL(SUM(ivd_wgt), 0)  
  
                     FROM invoicedetail  
  
                    WHERE invoicedetail.ivh_hdrnumber = #invtemp_tbl.ivh_hdrnumber AND  
  
                          invoicedetail.stp_number = #invtemp_tbl.stp_number AND  
  
                          #invtemp_tbl.stp_number > 0 AND  
  
                          #invtemp_tbl.stp_number IS NOT NULL)  
  
   
  
UPDATE #invtemp_tbl  
  
SET stop_count = (SELECT ISNULL(SUM(ivd_count), 0)  
  
                    FROM invoicedetail  
  
                   WHERE invoicedetail.ivh_hdrnumber = #invtemp_tbl.ivh_hdrnumber AND  
  
                         invoicedetail.stp_number = #invtemp_tbl.stp_number AND  
  
                         #invtemp_tbl.stp_number > 0 AND  
  
                         #invtemp_tbl.stp_number IS NOT NULL)  
  
   
  
UPDATE #invtemp_tbl  
  
SET stop_volume = (SELECT ISNULL(SUM(ivd_volume), 0)  
  
                     FROM invoicedetail  
  
                    WHERE invoicedetail.ivh_hdrnumber = #invtemp_tbl.ivh_hdrnumber AND  
  
                          invoicedetail.stp_number = #invtemp_tbl.stp_number AND  
  
                          #invtemp_tbl.stp_number > 0 AND  
  
                          #invtemp_tbl.stp_number IS NOT NULL) 

declare @minstp int,@minseq int
select @minstp =  min(stp_number) from #invtemp_tbl where stp_number > 0
while @minstp > 0
begin
  select @minseq = min(ivd_sequence) from #invtemp_tbl where stp_number = @minstp
  delete from #invtemp_tbl where stp_number = @minstp and ivd_sequence > @minseq
  select @minstp = min (stp_number) from #invtemp_tbl where stp_number > 0 and stp_number > @minstp
end
       
  
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
  
 gp_less_previous_payments,  
  
 gp_balance_due ,  
  
 ivd_remark,  
  
 stop_weight,  
  
 stop_count,    
  
 stop_volume  
  
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
  
 gp_less_previous_payments,  
  
 gp_balance_due ,  
  
 ivd_remark,  
  
 stop_weight,  
  
 stop_count,    
  
 stop_volume  
   
into ##invtemp_tbl_temp  /* necessary becasue invoice_template69 picks up and returns from this table */
 from #invtemp_tbl 
  
/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */    
  
IF @@ERROR != 0 select @ret_value = @@ERROR     
  
return @ret_value    
  
GO
GRANT EXECUTE ON  [dbo].[invoice_template69_linkedserver] TO [public]
GO
