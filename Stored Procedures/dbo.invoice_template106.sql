SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  create procedure [dbo].[invoice_template106](@invoice_nbr  int,@copies  int)  
as  
/* PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND  
 1 - IF SUCCESFULLY EXECUTED  
 @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS  
  
2/2/99 add cmp_altid from useasbillto company to return set  
1/5/00 dpete PTS6469 if you have an UNKNOWN consignee or shipper (origin or dest) use the city name in the city table  
06/29/2001 Vern Jewett  vmj1 PTS 10870: not returning copy # correctly.  
04/22/2002  Jyang add terms_name to return set  
12/5/2 16314 DPETE use company settings to control terms and linehaul restricitons on mail to  
DPETE 16739 3/26/03 Add cmp_contact for billto company, shipper_geoloc, cons geoloc  to return set for format 41  
BDH 41547 5/23/08.  Returning refnum_list.  A comma sep list of ref_types and ref_numbers.
SGB 44808 10/22/08 Change to only pull 'Orderheader' ref numbers also handle NULL reftypes
*/  
  
declare 
 --@temp_name   varchar(30) ,  
 --@temp_addr   varchar(30) ,  
 --@temp_addr2  varchar(30),  
 @temp_nmstct varchar(30),  
 @temp_name   varchar(100) ,
 @temp_addr   varchar(100) ,  
 @temp_addr2  varchar(100),     
 @temp_altid  varchar(25),  
 @counter    int,  
 @ret_value  int,  
 @temp_terms    varchar(20),  
 @varchar50 varchar(50),
 @varchar10 varchar(10),
 @varchar100 varchar(100),
 @varchar254 varchar(254),
 @varchar25 varchar(25),
 @varchar12 varchar(12),
 @ord_hdrnumber  int,
 @stp_number int,
 @evt_tractor varchar(8),
 @evt_driver varchar(8),
 @MinOrd int,
 @MinRef varchar(30),
 @MinStp int,
 @MinSeq int,
 @billed_miles float,
 @freight_miles float,
 @rate_unit varchar(6), 
 @refnum_list varchar(254)

-- BDH 41547
create table #refnum_list(
	refnum_id int identity,
	ref_type varchar(6),
	ref_number varchar(30))
	
declare @ref_type_new varchar(6),
	@ref_number_new varchar(30),
	@ref_type_old varchar(6),
	@ref_number_old varchar(30),
	@refnum_id int

set @refnum_list = ''
select @ord_hdrnumber = ord_hdrnumber from invoiceheader where ivh_hdrnumber = @invoice_nbr

insert INTO #refnum_list 
	select ref_type, ref_number  
	from referencenumber
	where ord_hdrnumber = @ord_hdrnumber
	and ref_table = 'orderheader'  										-- PTS 44808 only include orderheader reference numbers
	and isnull(ref_type, 'UNK') <> 'UNK'						-- PTS 44808 do not retrieve NULL reference types
	order by ref_type, ref_number

select @refnum_id = isnull(min(refnum_id), 0) from #refnum_list
while @refnum_id > 0
begin
	select @ref_type_new = ref_type, @ref_number_new = ref_number from #refnum_list where refnum_id = @refnum_id
	if isnull(@ref_type_old, '') <> isnull(@ref_type_new, '') or isnull(@ref_number_old, '') <> isnull(@ref_number_new, '')
	begin
		set @refnum_list = @refnum_list + @ref_type_new + ': ' +  @ref_number_new + ', ' 
	end	

	set @ref_type_old = @ref_type_new 
	set @ref_number_old = @ref_number_new
	select @refnum_id = isnull(min(refnum_id), 0) from #refnum_list where refnum_id > @refnum_id	
end

if right(@refnum_list, 2) = ', '
begin
	set @refnum_list = STUFF ( @refnum_list , len(@refnum_list)  , 2 ,'.' )
end 
-- 41547 end
  
  
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
         invoicedetail.stp_number,     
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
 --@freight_miles OD_Miles,
 @temp_terms terms_name,  
 IsNull(ivh_charge,0) ivh_charge,  
        @temp_addr2    ivh_billto_addr3,  
    @varchar50 cmp_contact,  
 @varchar50 shipper_geoloc,  
 @varchar50 cons_geoloc,
 @varchar50 salesman,
 @varchar50 Payment_terms, 
 @varchar50 shipping_method,
 @varchar50 PO_number,
 @varchar100 REMIT_TO_name,
 @varchar100 REMIT_TO_ADDRESS1,
 @varchar100 REMIT_TO_ADDRESS2,
 @varchar25 REMIT_TO_nmstct,
 @varchar10 REMIT_TO_zip,
 @varchar254 logo_location,
 @varchar12 ord_booked_revtype1,
 @refnum_list refnum_list -- BDH 41547

   --pts40188 outer join conversion
   into #invtemp_tbl  
    FROM  chargetype  RIGHT OUTER JOIN  invoicedetail  ON  (chargetype.cht_itemcode  = invoicedetail.cht_itemcode  and chargetype.cht_basis in ('ACC','SHP')) 
				LEFT OUTER JOIN  commodity  ON  invoicedetail.cmd_code  = commodity.cmd_code ,
	      invoiceheader  
   WHERE ( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and  
		 invoiceheader.ivh_hdrnumber = @invoice_nbr  
--    FROM invoiceheader, invoicedetail, chargetype, commodity  
--   WHERE ( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and  
--  (chargetype.cht_itemcode =* invoicedetail.cht_itemcode) and  
--  (invoicedetail.cmd_code *= commodity.cmd_code) and  
-- invoiceheader.ivh_hdrnumber = @invoice_nbr  and
-- chargetype.cht_basis in ('ACC','SHP')


/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
if (select count(*) from #invtemp_tbl) = 0  
 begin  
 select @ret_value = 0    
 GOTO ERROR_END  
 end  
/* RETRIEVE COMPANY DATA */                         

  
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
     set #invtemp_tbl.salesman = company.cmp_bookingterminal,
         #invtemp_tbl.Payment_terms = ISNULL((select name
                                         from labelfile
                                        where labeldefinition = 'CreditTerms' and
                                              abbr = company.cmp_terms), 'UNK')
    from #invtemp_tbl, company  
   where company.cmp_id = #invtemp_tbl.ivh_billto

 update #invtemp_tbl  
     set #invtemp_tbl.PO_number = invoiceheader.ivh_ref_number
    from #invtemp_tbl, invoiceheader 
   where #invtemp_tbl.ord_hdrnumber = invoiceheader.ord_hdrnumber 

 
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
from  #invtemp_tbl, 
	  stops LEFT OUTER JOIN city ON stops.stp_city = city.cty_code  --pts40188 outer join conversion
where  #invtemp_tbl.stp_number IS NOT NULL  
 and stops.stp_number =  #invtemp_tbl.stp_number  
  
update #invtemp_tbl  
set terms_name = la.name  
from labelfile la  
where la.labeldefinition = 'creditterms' and  
     la.abbr = #invtemp_tbl.ivh_terms  

--PTS# 24251 ILB 09/30/2004
select distinct @ord_hdrnumber = ord_hdrnumber
from #invtemp_tbl

select @stp_number = stp_number
from stops
where ord_hdrnumber = @ord_hdrnumber and
      stp_mfh_sequence = (select max(stp_mfh_sequence)
                            from stops
                           where ord_hdrnumber = @ord_hdrnumber)

select @evt_tractor = evt_tractor,
       @evt_driver  = evt_driver1
from event
where stp_number = @stp_number

Update #invtemp_tbl
   set ivh_tractor = @evt_tractor,
       ivh_driver = @evt_driver
 where ord_hdrnumber = @ord_hdrnumber

--PTS# 24251 ILB 09/30/2004 
--remove the rows which are not charge type = 'ACC or SHP'
DELETE FROM #invtemp_tbl
WHERE cht_basis is null or
      cht_itemcode = 'DEL'
--END PTS# 24251 ILB 09/30/2004

--PTS# 25825 ILB 02/25/2005
SET @billed_miles = 0
SET @freight_miles = 0
select @billed_miles = (select sum(ivh_totalmiles)
                          from #invtemp_tbl
                         where ivd_type = 'SUB' and 
			      cht_basis = 'SHP')

select @freight_miles = (select sum(ivh_freight_miles)
                          from #invtemp_tbl
                         where ivd_type = 'SUB' and 
			      cht_basis = 'SHP') 

select @rate_unit = (select max (ivd_rateunit)
		       from #invtemp_tbl
                      where ivd_type = 'SUB' and 
			    cht_basis = 'SHP')
IF @rate_unit = 'FLT'
   BEGIN
	Update #invtemp_tbl
           set ivh_totalmiles = 1
   END

Update #invtemp_tbl
   set ivd_refnum = ''
 where UPPER(ivd_reftype) <> 'REF' and
       cht_basis = 'ACC'

Update #invtemp_tbl
   set ord_booked_revtype1 = orderheader.ord_booked_revtype1
 from orderheader, invoiceheader
 where invoiceheader.ivh_hdrnumber = #invtemp_tbl.ivh_hdrnumber
and    invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber


Update #invtemp_tbl
set REMIT_TO_name = legal_entity.le_name,
REMIT_TO_ADDRESS1 = legal_entity.le_address1,
 REMIT_TO_ADDRESS2 = legal_entity.le_address2,
 REMIT_TO_nmstct = legal_entity.le_cty_nmstct ,
 REMIT_TO_zip = legal_entity.le_zip,
 logo_location= legal_entity.le_misc1 
from legal_entity, branch
where branch.brn_id = #invtemp_tbl.ord_booked_revtype1
and branch.brn_legalentity = le_id
      
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
 --OD_Miles, 
 terms_name,  
 IsNull(ivh_charge,0) ivh_charge,  
        ivh_billto_addr3,  
 cmp_contact,  
 shipper_geoloc,  
 cons_geoloc,
 salesman,
 Payment_terms, 
 shipping_method,
 PO_number,
 REMIT_TO_ADDRESS1,
 REMIT_TO_ADDRESS2,
 REMIT_TO_nmstct,
 REMIT_TO_zip,
 logo_location,
 ord_booked_revtype1,
 REMIT_TO_name,
 refnum_list -- 41547  
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
  --OD_Miles,  
  terms_name,  
         ivh_billto_addr3,  
 cmp_contact,  
 shipper_geoloc,  
 cons_geoloc,
 salesman,
 Payment_terms, 
 shipping_method,
 PO_number,
 REMIT_TO_ADDRESS1,
 REMIT_TO_ADDRESS2,
 REMIT_TO_nmstct,
 REMIT_TO_zip,
 logo_location,
 ord_booked_revtype1,
 rEMIT_TO_name,
 refnum_list -- 41547  

 from #invtemp_tbl  
/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 select @ret_value = @@ERROR   
return @ret_value  
  

GO
GRANT EXECUTE ON  [dbo].[invoice_template106] TO [public]
GO
