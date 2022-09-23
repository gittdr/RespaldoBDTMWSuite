SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create procedure [dbo].[invoice_template158](@invoice_nbr int,@copies  int)  
as  
/* PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND  
 1 - IF SUCCESFULLY EXECUTED  
 @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS  
  d
1/28/09 PTS 45730 copy of invoice_template55 modified for Moe's
3/3/9 DPETE Modify to remove zero charge tax lines
*/ 
declare @results table (
ivh_invoicenumber varchar(12) null,     
ivh_hdrnumber int null,   
ivh_billto varchar(8) null,   
ivh_billto_name varchar(100) null,  
ivh_billto_addr varchar(100) null,
ivh_billto_addr2 varchar(100) null,          
ivh_billto_nmctst varchar(40) null,  
ivh_terms varchar(6) null,      
ivh_totalcharge money null,     
ivh_shipper varchar(8) null,     
shipper_name varchar(100) null, 
shipper_addr varchar(100) null, 
shipper_addr2 varchar(100) null, 
shipper_nmctst varchar(40) null, 
ivh_consignee varchar(8) null,     
consignee_name varchar(100) null,
consignee_addr varchar(100) null,
consignee_addr2 varchar(100) null,
consignee_nmctst varchar(40) null, 
ivh_invoicestatus varchar(6) null,          
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
ivh_creditmemo char(1) null,     
ivh_applyto varchar(12) null,         
ivh_billdate datetime null,     
ivh_remark varchar(254) null,     
ivh_driver varchar(8) null,     
ivh_tractor varchar(8) null,     
ivh_trailer varchar(13) null,
ivh_user_id1 varchar(20) null,
ivh_user_id2 varchar(20) null ,    
ivh_ref_number varchar(30) null,     
ivh_driver2 varchar(8) null,     
mov_number int null,     
ivh_edi_flag varchar(30) null,     
ord_hdrnumber int null,       
stp_number int null,     
ivd_description varchar(60) null,     
cht_itemcode varchar(8) null,     
ivd_quantity float null,     
ivd_rate money null,     
ivd_charge money null,    
ivd_taxable1 char(1) null,   
ivd_taxable2 char(1) null,    
ivd_taxable3 char(1) null,   
ivd_taxable4 char(1) null,   
ivd_unit varchar(6) null,     
cur_code varchar(6) null,     
ivd_currencydate datetime NULL,     
ivd_glnum varchar(32) null,     
ivd_type varchar(6) null,     
ivd_rateunit varchar(6) null,       
ivd_sequence int null,     
ivd_refnum varchar(30) null,     
cmd_code varchar(8) null,     
cmp_id varchar(8) null,     
stop_name varchar(100) null,  
stop_addr varchar(100) null,  
stop_addr2 varchar(100) null,  
stop_nmctst varchar(30) null,  
ivd_distance float null,     
ivd_distunit varchar(6) null,     
ivd_wgt float null,     
ivd_wgtunit varchar(6) null,     
ivd_count decimal(9,2),     
ivd_countunit varchar(6) null,         
ivd_reftype varchar(6) null,     
ivd_volume float null,     
ivd_volunit varchar(6) null,     
ivh_freight_miles float null,  
tar_tarriffnumber varchar(12) null,  
tar_tariffitem varchar(12) null,  
copies int null,  
cht_basis varchar(6) null,  
cht_description varchar(30) null,  
cmd_name varchar(60) null,    
cmp_altid varchar(25) null ,  
ivh_showshipper varchar(8) null,  
ivh_showcons varchar(8) null,
ivh_definition varchar(6) null ,
fgt_refnum varchar(30) null, 
fgt_reftype varchar(6) null,
ivh_origincity int null,
ivh_destcity int null,
fgt_number int null,
ivh_billto_addr3 varchar(100) NULL,  
cmp_contact varchar(30) NULL ,
ivh_charge money null
)
  
declare @temp_name   varchar(30) ,  
 @temp_addr   varchar(30) ,  
 @temp_addr2  varchar(30),  
 @temp_nmstct varchar(30),  
 @temp_altid  varchar(25),  
 @counter    int,  
 @ret_value  int,  
 @temp_terms    varchar(20),  
 @varchar50 varchar(50),
 @varchar20 varchar(20),
 @varchar6 varchar(6),
 @ordhdrnumber int,
 @firstPUP int

declare @fgtrefnums table (
 ref_tablekey int null
 ,ref_type varchar(6) null
 ,ref_number varchar(30) null
 ,ref_sequence int null) 
 
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1 

select @ordhdrnumber = ord_hdrnumber from invoiceheader where ivh_hdrnumber =  @invoice_nbr

if @ordhdrnumber > 0 
 select @firstPUP = (select top 1 stp_number
 from stops 
 where ord_hdrnumber = @ordhdrnumber
 and stp_type = 'PUP'
 order by stp_arrivaldate)
else 
 select @firstPUP = 0



If @ordhdrnumber > 0
 insert into @fgtrefnums
 select ref_tablekey,ref_type,ref_number,ref_sequence
 from referencenumber 
 where ord_hdrnumber = @ordhdrnumber
 and ref_table = 'freightdetail'
  
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
 NOTE: "COPY" - ROW IS POPULATED WITH 1 TO INDICATE FIRST COPY*/ 

if @firstpup> 0 and 
  exists (select 1 from invoicedetail where ivh_hdrnumber = @invoice_nbr 
               and stp_number =  @firstpup)
  select @firstpup = 0


If @firstpup > 0
  INSERT into @results 
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
 shipper_name = 
     Case ivh_hideshipperaddr 
      when 'Y' then ''
      else   scmp.cmp_name 
      end,  
  shipper_addr = 
     Case ivh_hideshipperaddr 
      when 'Y' then ''
      else   isnull(scmp.cmp_address1,'') 
      end,    
  shipper_addr2 =   
     Case ivh_hideshipperaddr 
      when 'Y' then ''
      else   isnull(scmp.cmp_address2,'')    
      end,      
  shipper_nmctst = 
     Case ivh_hideshipperaddr 
      when 'Y' then ''
      else   substring(scmp.cty_nmstct,1,charindex('/',scmp.cty_nmstct+' /') - 1)+' '+isnull(scmp.cmp_zip,'')
      end,  
  invoiceheader.ivh_consignee,     
  ccmp.cmp_name consignee_name,  
  isnull(ccmp.cmp_address1,'') consignee_addr, 
  isnull(ccmp.cmp_address2,'') consignee_addr2, 
  consignee_nmctst = substring(ccmp.cty_nmstct,1,charindex('/',ccmp.cty_nmstct+' /') - 1)+' '+isnull(ccmp.cmp_zip,''),   
  invoiceheader.ivh_invoicestatus,     
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
  invoiceheader.ivh_creditmemo,     
  invoiceheader.ivh_applyto,         
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
  stops.stp_number,     
  freightdetail.fgt_description,     
  freightdetail.cht_itemcode,     
  freightdetail.fgt_quantity,     
  freightdetail.fgt_rate,     
  freightdetail.fgt_charge,  
  ivd_taxable1 =   'Y',
  ivd_taxable2 =   'Y',  
  ivd_taxable3  =  'Y', 
  ivd_taxable4 =   'Y',  
  freightdetail.fgt_unit,     
  cur_code = '',     
  ivd_currencydate = '19500101 00:00:00',     
  ivd_glnum = '',     
  ivd_type = 'PUP',     
  freightdetail.fgt_rateunit,     
  fgt_sequence = (-10 + freightdetail.fgt_sequence),  -- artificial ivd_sequence   
  freightdetail.fgt_refnum,     
  freightdetail.cmd_code,     
  stops.cmp_id,     
  stcmp.cmp_name stop_name,  
  isnull(stcmp.cmp_address1,'') stop_addr, 
  isnull(stcmp.cmp_address2,'') stop_addr2,
  stop_nmctst = substring(stcmp.cty_nmstct,1,charindex('/',stcmp.cty_nmstct+' /') - 1), 
  stops.stp_ord_mileage,     
  'MIL',     
  freightdetail.fgt_weight,     
  freightdetail.fgt_weightunit,     
  freightdetail.fgt_count,     
  freightdetail.fgt_countunit,       
  freightdetail.fgt_reftype,     
  freightdetail.fgt_volume,     
  freightdetail.fgt_volumeunit,     
  ivh_freight_miles = 0,  
  tar_tarriffnumber = isnull(freightdetail.tar_tariffnumber,'UNKNOWN'),  
  tar_tariffitem = isnull(freightdetail.tar_tariffitem,'UNKNOWN'),  
  1 copies,  
  chargetype.cht_basis,   
  chargetype.cht_description,  
  cmd_name = freightdetail.fgt_description,  
  @temp_altid cmp_altid,  
  ivh_showshipper,  
  ivh_showcons,
 ivh_definition ,
 ' ' fgt_refnum,
 'BL#' fgt_reftype,
 ivh_origincity,
 ivh_destcity,
 fgt_number = freightdetail.fgt_number,
 '' ivh_billto_addr3,
 '' cmp_contact ,
 ivh_charge 
FROM invoiceheader
join company scmp on ivh_showshipper = scmp.cmp_id
join company ccmp on ivh_showcons = ccmp.cmp_id,
stops
join company stcmp on stops.cmp_id = stcmp.cmp_id
join freightdetail on stops.stp_number = freightdetail.stp_number
left outer join chargetype on freightdetail.cht_itemcode  = chargetype.cht_itemcode
LEFT OUTER JOIN  commodity  ON  freightdetail.cmd_code  = commodity.cmd_code
WHERE @firstPUP > 0 and
invoiceheader.ivh_hdrnumber = @invoice_nbr and 
 stops.stp_number =   @firstPUP

/* Main select */
INSERT into @results
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
 shipper_name = 
     Case ivh_hideshipperaddr 
      when 'Y' then ''
      else   scmp.cmp_name 
      end,  
  shipper_addr = 
     Case ivh_hideshipperaddr 
      when 'Y' then ''
      else   isnull(scmp.cmp_address1 ,'')
      end,    
  shipper_addr2 = 
     Case ivh_hideshipperaddr 
      when 'Y' then ''
      else   isnull(scmp.cmp_address2 ,'')  
      end,      
  shipper_nmctst = 
     Case ivh_hideshipperaddr 
      when 'Y' then ''
      else   substring(scmp.cty_nmstct,1,charindex('/',scmp.cty_nmstct+' /') - 1)+' '+isnull(scmp.cmp_zip,'')
      end,  
  invoiceheader.ivh_consignee,     
  ccmp.cmp_name consignee_name,  
  isnull(ccmp.cmp_address1,'') consignee_addr,  
  isnull(ccmp.cmp_address2,'') consignee_addr2,  
  consignee_nmctst = substring(Ccmp.cty_nmstct,1,charindex('/',Ccmp.cty_nmstct+' /') - 1)+' '+isnull(ccmp.cmp_zip,''),
  invoiceheader.ivh_invoicestatus,     
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
  invoiceheader.ivh_creditmemo,     
  invoiceheader.ivh_applyto,         
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
  invoicedetail.ivd_sequence,     
  invoicedetail.ivd_refnum,     
  invoicedetail.cmd_code,     
  invoicedetail.cmp_id,     
  stcmp.cmp_name stop_name,  
  isnull(stcmp.cmp_address1,'') stop_addr,  
  isnull(stcmp.cmp_address2,'') stop_addr2,  
  stop_nmctst = substring(stcmp.cty_nmstct,1,charindex('/',stcmp.cty_nmstct+' /') - 1), 
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
  (Case ivh_showshipper   
  when 'UNKNOWN' then invoiceheader.ivh_shipper  
  else IsNull(ivh_showshipper,invoiceheader.ivh_shipper)   
 end) ivh_showshipper,  
 (Case ivh_showcons   
  when 'UNKNOWN' then invoiceheader.ivh_consignee  
  else IsNull(ivh_showcons,invoiceheader.ivh_consignee)   
 end) ivh_showcons,
 ivh_definition ,
 ' ' fgt_refnum,
 'BL#' fgt_reftype,
 ivh_origincity,
 ivh_destcity,
 fgt_number = isnull(invoicedetail.fgt_number,0),
 '' ,
 '',
 ivh_charge
FROM invoiceheader
join company scmp on ivh_showshipper = scmp.cmp_id
join company ccmp on ivh_showcons = ccmp.cmp_id		
join invoicedetail on invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
left outer join chargetype on invoicedetail.cht_itemcode  = chargetype.cht_itemcode
LEFT OUTER JOIN  commodity  ON  invoicedetail.cmd_code  = commodity.cmd_code
join company stcmp on invoicedetail.cmp_id = stcmp.cmp_id
WHERE invoiceheader.ivh_hdrnumber = @invoice_nbr


/* Moes has situation with tax charges with zero charge - eliminate */
delete from   @results where cht_basis = 'TAX' and ivd_charge = 0 

   
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
if (select count(*) from @results) = 0  
 begin  
 select @ret_value = 0    
 GOTO ERROR_END  
 end  

  
 If Not Exists (Select cmp_mailto_name From company c, @results t  
        Where c.cmp_id = t.ivh_billto  
   And Rtrim(IsNull(cmp_mailto_name,'')) > ''  
   And t.ivh_terms in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3,   
    Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)  
   And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End )   
  
  update @results  
  set ivh_billto_name = company.cmp_name,  
  ivh_billto_nmctst = substring(company.cty_nmstct,1, charindex('/', company.cty_nmstct+'/') - 1)+ ' ' + IsNull(company.cmp_zip,''), 
  cmp_altid = company.cmp_altid,  
  ivh_billto_addr = isnull(company.cmp_address1,''),  
  ivh_billto_addr2 = isnull(company.cmp_address2,''),  
  ivh_billto_addr3 = isnull(company.cmp_address3, ''), 
  cmp_contact = company.cmp_contact  
  from @results res, company  
  where company.cmp_id = res.ivh_billto  
 Else   
  update @results  
  set ivh_billto_name = company.cmp_mailto_name,  
  ivh_billto_addr =  isnull(company.cmp_mailto_address1 ,''),  
  ivh_billto_addr2 = isnull(company.cmp_mailto_address2,''),     
  ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct+'/')))+ ' ' + IsNull(company.cmp_mailto_zip,''),  
  cmp_altid = company.cmp_altid ,  
  cmp_contact = company.cmp_contact  
  from @results res, company  
  where company.cmp_id = res.ivh_billto  
 --end  

  
-- There is no shipper city, so if the shipper is UNKNOWN, use the origin city to get the nmstct  
if exists (select 1 from @results where  ivh_shipper = 'UNKNOWN'  ) 
  update @results  
  set shipper_nmctst = cty_nmstct 
  from @results res 
  join city on  res.ivh_origincity = cty_code
  where res.ivh_shipper = 'UNKNOWN'  
   
-- There is no consignee city, so if the consignee is UNKNOWN, use the dest city to get the nmstct 
if exists (select 1 from @results where  ivh_consignee = 'UNKNOWN'  )    
  update @results  
   set consignee_nmctst = cty_nmstct   
  from @results res
  join city on res.ivh_destcity = cty_code 
  where ivh_consignee = 'UNKNOWN'  
 
-- If stop has no company id
if exists (select 1 from @results  where stp_number > 0 and cmp_id = 'UNKNOWN')
  update @results  
   set  stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct+'/')))
  from  @results res
    join stops on res.stp_number = stops.stp_number
    join city  ON  stops.stp_city = city.cty_code 
  where  res.stp_number > 0 
  and res.cmp_id = 'UNKNOWN' 

delete from @results where ivd_type = 'LI' and ivd_charge = 0

-- Attach BL# ref number from freight
if @ordhdrnumber > 0
  update @results
  set fgt_refnum = (select top 1 ref_number from @fgtrefnums frns
       where frns.ref_tablekey = res.fgt_number
       and frns.ref_type = 'BL#'
       order by frns.ref_sequence)
  from @Results res
  where fgt_number > 0

      
/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */  
select @counter = 1  
while @counter <>  @copies  
 begin  
 select @counter = @counter + 1  
  insert into @results  
  SELECT   
ivh_invoicenumber ,     
ivh_hdrnumber,   
ivh_billto,   
ivh_billto_name,  
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
ivh_creditmemo,     
ivh_applyto,         
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
ivd_currencydate ,    
ivd_glnum,    
ivd_type,  
ivd_rateunit,     
ivd_sequence,     
ivd_refnum,    
cmd_code,    
cmp_id,     
stop_name,  
stop_addr,  
stop_addr2,  
stop_nmctst, 
ivd_distance,    
ivd_distunit ,   
ivd_wgt,     
ivd_wgtunit,    
ivd_count ,     
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
ivh_showshipper,  
ivh_showcons,
ivh_definition,
fgt_refnum,
fgt_reftype,
ivh_origincity,
ivh_destcity,
fgt_number,
ivh_billto_addr3, 
cmp_contact,
ivh_charge
 from @results  
 where copies = 1     
 end   
                                                                
ERROR_END:  
/* FINAL SELECT - FORMS RETURN SET */  
--select *  
--from @results  
  SELECT   
ivh_invoicenumber ,     
ivh_hdrnumber,   
ivh_billto,   
ivh_billto_name,  
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
ivh_creditmemo,     
ivh_applyto,         
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
ivd_currencydate ,    
ivd_glnum,    
ivd_type,  
ivd_rateunit,     
ivd_sequence,     
ivd_refnum,    
cmd_code,    
cmp_id,     
stop_name,  
stop_addr,  
stop_addr2,  
stop_nmctst, 
ivd_distance,    
ivd_distunit ,   
ivd_wgt,     
ivd_wgtunit,    
ivd_count ,     
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
ivh_showshipper,  
ivh_showcons,
ivh_definition,
fgt_refnum,
fgt_reftype,
ivh_origincity,
ivh_destcity,
fgt_number,
ivh_billto_addr3, 
cmp_contact
--ivh_charge
 from @results  
/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 select @ret_value = @@ERROR   
return @ret_value

GO
GRANT EXECUTE ON  [dbo].[invoice_template158] TO [public]
GO
