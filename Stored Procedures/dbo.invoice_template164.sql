SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
create procedure [dbo].[invoice_template164](@invoice_nbr   int,@copies  int)  
as  
/* PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND  
 1 - IF SUCCESFULLY EXECUTED  
 @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS  
  
* PTS 45506 copy of invoice_template11 used for parent format22 modified for new format
* PTS49240 30 character ref number has last character chopped of 
* PTS 50215 customer change their mind about the types of ref numbers to display. Claim the ivh_totalmiles are 
  not the same as the miles at the bottom of hte invoice screen which they want to see 
*PTS61804 customer wants ref numbers on the invoicedetail records of misc invoices to dislay, extended to all LI tpe charges
   wants REF LOAD and PO# ref numbers form order header (or invoiceheader)
   wants BL# ref numbers on stops only from delivery locations
*/  
  
declare @temp_name   varchar(100) ,  
 @temp_addr   varchar(100) ,  
 @temp_addr2  varchar(100),  
 @temp_nmstct varchar(40),  
 @temp_altid  varchar(12),  
 @counter    int,  
 @ret_value  int,  
 @ref_number varchar(80),  
 @billtoname varchar(100),  
 @billtoaddr varchar(100),  
 @billtoaddr2 varchar(100),  
 @billtoaddr3 varchar(100),  
 @billtonmctst varchar(40),  
 @shipname varchar(100),  
 @shipaddr varchar(100),  
 @shipaddr2 varchar(100),  
 @shipaddr3 varchar(100),  
 @shipnmctst varchar(40),  
 @consname varchar(100),  
 @consaddr varchar(100),  
 @consaddr2 varchar(100),  
 @consaddr3 varchar(100),  
 @consnmctst varchar(40),
 @rollintoLHAmt money ,
 @rateconversion float,
 @totalmiles int 
  
declare @return table (  
ivh_invoicenumber varchar(12) null ,     
ivh_hdrnumber int null,   
ivh_billto varchar(8) null,   
ivh_billto_name varchar(100) null ,  
ivh_billto_addr varchar(100) null ,  
ivh_billto_addr2 varchar(100) null ,  
ivh_billto_nmctst varchar(40) null,  
ivh_terms varchar(6) null,      
ivh_totalcharge money,     
ivh_shipper varchar(8) null,     
shipper_name varchar(100) null ,  
shipper_addr varchar(100) null ,  
shipper_addr2 varchar(100) null ,  
shipper_nmctst varchar(40) null,  
ivh_consignee varchar(8) null,     
consignee_name varchar(100) null ,  
consignee_addr varchar(100) null ,  
consignee_addr2 varchar(100) null ,  
consignee_nmctst varchar(40) null,  
ivh_invoicestatus VARCHAR(6) null,     
ivh_supplier varchar(8) null,     
ivh_shipdate datetime null,     
ivh_deliverydate datetime null,     
ivh_revtype1 varchar(6) null,     
ivh_revtype2  varchar(6) null,     
ivh_revtype3  varchar(6) null,     
ivh_revtype4  varchar(6) null,    
ivh_totalweight float null,     
ivh_totalpieces float null,     
ivh_totalmiles float null,  
ivh_currency  varchar(6) null,     
ivh_currencydate datetime null,     
ivh_totalvolume float null,     
ivh_creditmemo char(1) null,     
ivh_applyto varchar(12) null,     
ivh_billdate datetime null,     
ivh_remark varchar(254) null,     
ivh_driver varchar(8) null,     
ivh_tractor varchar(8) null,     
ivh_trailer varchar(13) null,     
ref_number varchar(80) null,     
ivh_driver2 varchar(8) null,     
mov_number int null,     
ord_hdrnumber int null,     
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
ivd_type varchar(6) null,    
ivd_rateunit varchar(6) null,     
ivd_sequence int null,     
ivd_refnum varchar(30) null,   
cmd_code varchar(8) null,    
cmp_id  varchar(8) null,    
stop_name varchar(100) null,   
stop_nmctst varchar(30) null,  
ivd_distance float null,     
ivd_distunit varchar(6) null,    
ivd_wgt float null ,  
ivd_wgtunit varchar(6) null,    
ivd_count decimal(9,2) null,   
ivd_countunit varchar(6) null,     
ivd_reftype varchar(6) null,     
ivd_volume float null,     
ivd_volunit varchar(6) null,     
ivh_freight_miles float null,  
tar_tarriffnumber varchar(12) null,  
tar_tariffitem varchar(12) null,  
copies int null,  
cht_basis  varchar(6) null,   
cht_description varchar(60) null,  
cmd_name varchar(60) null,  
cmp_altid varchar(25) null,   
ivh_hideshipperaddr char(1) null,  
ivh_hideconsignaddr char(1) null,  
ivh_showshipper varchar(8) null,   
ivh_showcons  varchar(8) null,   
ivh_charge money null,  
fgt_accountof varchar(8) null,   
accountof_name varchar(100) null,  
ivh_billto_addr3 varchar(100) null,  
shipper_addr3 varchar(100) null,  
consignee_addr3 varchar(100) null,  
fgt_number int null,
cht_rollintolh char(1) null
  
)  
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
/* Customer wants a comma sep list of ord ref numbers of type PO# or LD#  */  
select @ref_number = ''  
If exists (select 1 from invoiceheader where ivh_hdrnumber = @invoice_nbr and ord_hdrnumber > 0)  
  select @ref_number = @ref_number + ref_type+' '+ref_number+', '  
  from invoiceheader  
  join referencenumber on invoiceheader.ord_hdrnumber = ref_tablekey  
  where ivh_hdrnumber = @invoice_nbr   
  and ref_table = 'orderheader'  
  --and ref_type in ('PO#','LOAD#','REF#') 
  and ref_type in ('PO#','LOAD','REF')   
  order by ref_type desc, ref_sequence  
If exists (select 1 from invoiceheader where ivh_hdrnumber = @invoice_nbr and ord_hdrnumber = 0)  
  select @ref_number = @ref_number + ref_type+' '+ref_number+', '  
  from invoiceheader  
  join referencenumber on invoiceheader.ivh_hdrnumber = ref_tablekey  
  where ivh_hdrnumber = @invoice_nbr   
  and ref_table = 'invoiceheader'  
  and ref_type in ('PO#','LOAD','REF')  
  order by ref_type desc, ref_sequence  

--if len(@ref_number) > 2 select @ref_number = left(@ref_number,len(@ref_number) - 2)    
if len(@ref_number) > 2 select @ref_number = left(@ref_number,len(@ref_number) - 1)  

/* gets names and address for return set */  
If Not Exists (Select cmp_mailto_name   
   From invoiceheader t  
   join company c on t.ivh_billto = c.cmp_id  
   Where t.ivh_hdrnumber = @invoice_nbr  
   And Rtrim(IsNull(cmp_mailto_name,'')) > ''  
   And t.ivh_terms in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3,   
    Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)  
   And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End )   
  
  
   select @billtoname = company.cmp_name,  
 @billtoaddr = isnull(company.cmp_address1,''),  
 @billtoaddr2 = isnull(company.cmp_address2,''),   
 @billtoaddr3 = isnull(company.cmp_address3, ''),   
 @billtonmctst = substring(company.cty_nmstct,1,   
                (charindex('/', company.cty_nmstct+'/')))+ ' ' + isnull(company.cmp_zip,''),  
 @temp_altid = company.cmp_altid   
 from invoiceheader hdr  
    join  company on hdr.ivh_billto = company.cmp_id  
    where hdr.ivh_hdrnumber = @invoice_nbr  
Else   
 select @billtoname = company.cmp_mailto_name,  
 @billtoaddr = isnull(company.cmp_mailto_address1,''),  
 @billtoaddr2 = isnull(company.cmp_mailto_address2,''),   
 @billtoaddr3 = '',  
 @billtonmctst = substring(company.mailto_cty_nmstct,1,   
                (charindex('/', company.mailto_cty_nmstct+'/')))+ ' ' + isnull(company.cmp_mailto_zip,''),  
 @temp_altid = company.cmp_altid   
 from invoiceheader hdr  
    join  company on hdr.ivh_billto = company.cmp_id  
    where hdr.ivh_hdrnumber = @invoice_nbr  
  
  
select  @shipname = company.cmp_name,  
@shipaddr =   
  Case ivh_hideshipperaddr   
    when 'Y' then ''  
 else isnull(company.cmp_address1,'')  
    end,  
@shipaddr2 =   
  Case ivh_hideshipperaddr   
    when 'Y' then ''  
 else isnull(company.cmp_address2,'')  
 end,  
@shipaddr3 =   
  Case ivh_hideshipperaddr   
    when 'Y' then ''  
    else isnull(company.cmp_address3,'')  
 end,  
@shipnmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct+'/')))+ ' ' + isnull(company.cmp_zip,'')   
from invoiceheader hdr  
join  company on hdr.ivh_showshipper = company.cmp_id  
where hdr.ivh_hdrnumber = @invoice_nbr  
  
  
select  @consname = company.cmp_name,  
@consaddr =   
  Case ivh_hideshipperaddr   
    when 'Y'then ''  
    else isnull(company.cmp_address1,'')  
    end,  
@consaddr2 =   
  Case ivh_hideshipperaddr   
    when 'Y' then ''  
 else isnull(company.cmp_address2,'')  
 end,  
@consaddr3 =   
  Case ivh_hideshipperaddr   
    when 'Y' then ''  
 else isnull(company.cmp_address3,'')  
 end,  
@consnmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct+'/')))+ ' ' + isnull(company.cmp_zip,'')   
from invoiceheader hdr  
join  company on hdr.ivh_showcons  = company.cmp_id  
where hdr.ivh_hdrnumber = @invoice_nbr 

select @totalmiles = sum(isnull(ivd_distance,0))
from invoicedetail
where ivh_hdrnumber =  @invoice_nbr 
and ivd_distance > 0
and ivd_type in ( 'DRP','PUP')
  
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
 NOTE:'COPY' - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/  
  
/*  (customer specs changed, omit line for picked up commodities)  
first insert fake records for freight on pickup stops if invoice is for an order 
if exists (select 1 from invoiceheader where ivh_hdrnumber = @invoice_nbr and ord_hdrnumber > 0)  
insert into @return  
 SELECT    
     invoiceheader.ivh_invoicenumber,     
     invoiceheader.ivh_hdrnumber,   
  invoiceheader.ivh_billto,   
  @billtoname ivh_billto_name ,  
  @billtoaddr  ivh_billto_addr,  
  @billtoaddr2 ivh_billto_addr2,  
  @billtonmctst ivh_billto_nmctst,  
     invoiceheader.ivh_terms,      
     invoiceheader.ivh_totalcharge,     
  invoiceheader.ivh_shipper,     
  @shipname shipper_name,  
  @shipaddr shipper_addr,  
  @shipaddr2 shipper_addr2,  
  @shipnmctst shipper_nmctst,  
     invoiceheader.ivh_consignee,     
  @consname consignee_name,  
  @consaddr consignee_addr,  
  @consaddr2 consignee_addr2,  
  @consnmctst consignee_nmctst,  
--         invoiceheader.ivh_originpoint,     
--  @temp_name originpoint_name,  
--  @temp_addr origin_addr,  
--  @temp_addr2 origin_addr2,  
--  @temp_nmstct origin_nmctst,  
--         invoiceheader.ivh_destpoint,     
--  @temp_name destpoint_name,  
--  @temp_addr dest_addr,  
--  @temp_addr2 dest_addr2,  
--  @temp_nmstct dest_nmctst,  
     invoiceheader.ivh_invoicestatus,     
  --       invoiceheader.ivh_origincity,     
--         invoiceheader.ivh_destcity,     
--         invoiceheader.ivh_originstate,     
--         invoiceheader.ivh_deststate,  
--         invoiceheader.ivh_originregion1,     
--         invoiceheader.ivh_destregion1,     
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
 --        invoiceheader.ivh_taxamount1,     
 --        invoiceheader.ivh_taxamount2,     
 --        invoiceheader.ivh_taxamount3,     
 --        invoiceheader.ivh_taxamount4,     
 --        invoiceheader.ivh_transtype,     
     invoiceheader.ivh_creditmemo,     
     invoiceheader.ivh_applyto,     
 --        invoiceheader.ivh_printdate,     
     invoiceheader.ivh_billdate,     
 --        invoiceheader.ivh_lastprintdate,     
 --        invoiceheader.ivh_originregion2,     
 --        invoiceheader.ivh_originregion3,     
 --        invoiceheader.ivh_originregion4,     
 --        invoiceheader.ivh_destregion2,     
 --        invoiceheader.ivh_destregion3,     
 --        invoiceheader.ivh_destregion4,     
 --        invoiceheader.mfh_hdrnumber,     
     invoiceheader.ivh_remark,     
     invoiceheader.ivh_driver,     
     invoiceheader.ivh_tractor,     
     invoiceheader.ivh_trailer,     
 --        invoiceheader.ivh_user_id1,     
 --        invoiceheader.ivh_user_id2,     
     @ref_number ref_number,     
     invoiceheader.ivh_driver2,     
     invoiceheader.mov_number,     
 --        invoiceheader.ivh_edi_flag,     
     invoiceheader.ord_hdrnumber,     
 --        invoicedetail.ivd_number,     
     fgt.stp_number,     
     fgt_description,     
     fgt.cht_itemcode,     
     fgt_quantity,       
     fgt_rate,     
     fgt_charge,     
     'N' ivd_taxable1,    
     'N' ivd_taxable2,   
     'N'  ivd_taxable3,     
     'N' ivd_taxable4,     
     fgt_unit,     
--         invoiceheader.ivh_currency,     
 --        invoiceheader.ivh_currencydate,      
 --        invoicedetail.ivd_glnum,     
     'PUP'  ivd_type,     
     fgt_rateunit,     
 --        invoicedetail.ivd_billto,     
--  @temp_name ivd_billto_name,  
--  @temp_addr ivd_billto_addr,  
--  @temp_addr2 ivd_billto_addr2,  
--  @temp_nmstct ivd_billto_nmctst,  
  --       invoicedetail.ivd_itemquantity,     
 --        invoicedetail.ivd_subtotalptr,     
 --        invoicedetail.ivd_allocatedrev,     
     ((stp_sequence * 100) + fgt_sequence )ivd_sequence,     
     case ivd_type when "LI' then ivd_refnum else '' end,   -- fgt_refnum,     
     fgt.cmd_code,     
     stops.cmp_id,     
  @temp_name stop_name,  
--  @temp_addr stop_addr,  
--  @temp_addr2 stop_addr2,  
  @temp_nmstct stop_nmctst,  
     0,     
     'MIL',    
     fgt_weight,     
     fgt_weightunit,     
     fgt_count,     
     fgt_countunit,     
 --        invoicedetail.evt_number,     
     case ivd_type when "LI' then ivd_reftype else '' end,   -- fgt_reftype,     
     fgt_volume,     
     fgt_volumeunit,     
 --        invoicedetail.ivd_orig_cmpid,     
 --        invoicedetail.ivd_payrevenue,  
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
  ivh_showshipper =   
      (Case ivh_showshipper   
  when 'UNKNOWN' then invoiceheader.ivh_shipper  
  else IsNull(ivh_showshipper,invoiceheader.ivh_shipper)   
     end) ,  
  ivh_showcons =   
      (Case ivh_showcons   
  when 'UNKNOWN' then invoiceheader.ivh_consignee  
  else IsNull(ivh_showcons,invoiceheader.ivh_consignee)   
     end) ,  
  IsNull(fgt_charge,0.0) ivh_charge,  
     fgt_accountof,  
     isnull(company.cmp_name,'') ,  
     @billtoaddr3,  
     @shipaddr3,  
     @consaddr3,  
     fgt.fgt_number ,
     chargetype.cht_rollintolh   
    FROM invoiceheader  
    join stops on invoiceheader.ord_hdrnumber = stops.ord_hdrnumber and stp_type = 'PUP' and stops.ord_hdrnumber > 0  
    join freightdetail fgt on stops.stp_number = fgt.stp_number  
    left outer join chargetype on fgt.cht_itemcode = chargetype.cht_itemcode   
 LEFT OUTER JOIN  commodity  ON  fgt.cmd_code  = commodity.cmd_code   
    left outer join company  on fgt.fgt_accountof = company.cmp_id  
   WHERE invoiceheader.ivh_hdrnumber =  @invoice_nbr  
  
 */
  
/* next get the real rwecords from the invoice */  
  
  
  
insert into @return  
 SELECT    
     invoiceheader.ivh_invoicenumber,     
     invoiceheader.ivh_hdrnumber,   
  invoiceheader.ivh_billto,   
  @billtoname ivh_billto_name ,  
  @billtoaddr  ivh_billto_addr,  
  @billtoaddr2 ivh_billto_addr2,  
  @billtonmctst ivh_billto_nmctst,  
     invoiceheader.ivh_terms,      
     invoiceheader.ivh_totalcharge,     
  invoiceheader.ivh_shipper,     
  @shipname shipper_name,  
  @shipaddr shipper_addr,  
  @shipaddr2 shipper_addr2,  
  @shipnmctst shipper_nmctst,  
     invoiceheader.ivh_consignee,     
  @consname consignee_name,  
  @consaddr consignee_addr,  
  @consaddr2 consignee_addr2,  
  @consnmctst consignee_nmctst,  
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
  @totalmiles ivh_totalmiles, --invoiceheader.ivh_totalmiles,     
  invoiceheader.ivh_currency,     
  invoiceheader.ivh_currencydate,     
  invoiceheader.ivh_totalvolume,       
  invoiceheader.ivh_creditmemo,     
  invoiceheader.ivh_applyto,      
  invoiceheader.ivh_billdate,     
  invoiceheader.ivh_remark,     
  invoiceheader.ivh_driver,     
  invoiceheader.ivh_tractor,     
  invoiceheader.ivh_trailer,     
  @ref_number ref_number,     
  invoiceheader.ivh_driver2,     
  invoiceheader.mov_number,     
  invoiceheader.ord_hdrnumber,     
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
  invoicedetail.ivd_type,     
  invoicedetail.ivd_rateunit,     
  1000 + invoicedetail.ivd_sequence,     
   case ivd_type when 'LI' then isnull(ivd_refnum,'') else '' end,   --invoicedetail.ivd_refnum,     
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
  case ivd_type 
     when 'LI' then 
          case isnull(ivd_refnum,'')
          when '' then ''
          else  isnull(ivd_reftype,'')
          end 
     else '' 
     end,   --invoicedetail.ivd_reftype,     
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
 (Case ivh_showshipper   
  when 'UNKNOWN' then invoiceheader.ivh_shipper  
  else IsNull(ivh_showshipper,invoiceheader.ivh_shipper)   
 end) ivh_showshipper,  
 (Case ivh_showcons   
  when 'UNKNOWN' then invoiceheader.ivh_consignee  
  else IsNull(ivh_showcons,invoiceheader.ivh_consignee)   
 end) ivh_showcons,  
 IsNull(ivh_charge,0.0) ivh_charge,  
  fgt_accountof,  
  isnull(company.cmp_name,''),  
  @billtoaddr3,  
  @shipaddr3,  
  @consaddr3,  
  freightdetail.fgt_number,
  invoicedetail.cht_rollintolh
  FROM invoiceheader  
  join invoicedetail on invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber  
  left outer join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode  
  left outer join commodity on invoicedetail.cmd_code = commodity.cmd_code  
  left outer join freightdetail on invoicedetail.fgt_number = freightdetail.fgt_number and invoicedetail.fgt_number > 0  
  left outer join company  on fgt_accountof = company.cmp_id  
  WHERE  invoiceheader.ivh_hdrnumber =  @invoice_nbr  
  --and ivd_type <> 'PUP'  
  
   
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
if (select count(*) from @return) = 0  
 begin  
 select @ret_value = 0    
 GOTO ERROR_END  
 end 

/* Handle possible roll into lh for rate by total only*/

select @rollintoLHAmt = sum(ivd_charge)
from @return where cht_rollintolh = 1

select @rollintoLHAmt = isnull(@rollintoLHAmt,0)

If @rollintoLHAmt <> 0 and exists(select 1 from @return where (ivd_type = 'SUB' or cht_itemcode = 'MIN') and ivd_quantity <> 0) 
  BEGIN 
      If exists (select 1 from @return where cht_itemcode = 'MIN')
        select @rateconversion = unc_factor
        from @return ttbl
        join unitconversion on ttbl.ivd_unit = unc_from and ivd_rateunit = unc_to and unc_convflag = 'R'
        where ttbl.cht_itemcode = 'MIN'
      else 
        select @rateconversion = unc_factor
        from @return ttbl
        join unitconversion on ttbl.ivd_unit = unitconversion.unc_from and ivd_rateunit = unc_to and unc_convflag = 'R'
        where ttbl.ivd_type = 'SUB'

      select @rateconversion = isnull(@rateconversion,1) 


      update @return
      set ivd_charge = 
        case 
        when ivd_charge <> 0 then ivd_charge + @rollintoLHAmt
        else 0
        end,
      ivd_rate = 
        case ivd_quantity
        when 1 then round((ivd_charge + @rollintoLHAmt) / @rateconversion,4)
        else round((ivd_charge + @rollintoLHAmt) / (@rateconversion * ivd_quantity),4)
        end
      from @return tmp
      where ivd_type = 'SUB' or cht_itemcode = 'MIN'

    delete from @return where cht_rollintolh = 1

  END 
      
update @return  
set stop_name = company.cmp_name,  
stop_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +isnull(cmp_zip,'')   
from @return rslt  
join company on rslt.cmp_id = company.cmp_id  
where rslt.cmp_id <> 'UNKNOWN'  
  
  
if exists (select 1 from @return where stp_number > 0 and cmp_id = 'UNKNOWN')  
update @return  
set stop_name = '',  
stop_nmctst = substring(cty_nmstct,1, (charindex('/', cty_nmstct+'/')))+ ' ' + isnull(stp_zipcode,isnull(cty_zip,''))   
from @return rslt  
join stops on rslt.stp_number = stops.stp_number  
join city on stp_city = cty_code  
where rslt.cmp_id = 'UNKNOWN'  
and rslt.stp_number > 0  
  
      
/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */  
select @counter = 1  
while @counter <>  @copies  
begin  
 select @counter = @counter + 1  
 insert into @return  
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
  ivh_creditmemo,     
  ivh_applyto,     
  ivh_billdate,     
  ivh_remark,     
  ivh_driver,     
  ivh_tractor,     
  ivh_trailer,      
  ref_number,     
  ivh_driver2,     
  mov_number,     
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
  fgt_accountof,  
  accountof_name,  
  ivh_billto_addr3 ,  
  shipper_addr3 ,  
  consignee_addr3,  
  fgt_number ,
  cht_rollintolh
  from @return  
  where copies = 1     
end   
                                                                
ERROR_END:  
/* FINAL SELECT - FORMS RETURN SET */  
select     
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
  ivh_creditmemo,     
  ivh_applyto,     
  ivh_billdate,     
  ivh_remark,     
  ivh_driver,     
  ivh_tractor,     
  ivh_trailer,     
  ref_number,     
  ivh_driver2,     
  mov_number,     
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
  ivh_charge,  
  fgt_accountof,  
  accountof_name,  
  ivh_billto_addr3 ,  
  shipper_addr3 ,  
  consignee_addr3,  
  fgt_number
--,cht_rollintolh
from @return  
order by copies,ivd_sequence  
  
/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 select @ret_value = @@ERROR   
return @ret_value  
GO
GRANT EXECUTE ON  [dbo].[invoice_template164] TO [public]
GO
