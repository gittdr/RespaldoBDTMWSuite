SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE procedure [dbo].[order_summary08](@ps_ord_number varchar(20))  
as  

/*
 * 
 * NAME:order_summary08
 * dbo.
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the invoices 
 * based on the Billto selected in the interface.
 *
 * RETURNS:
 * 0 - IF NO DATA WAS FOUND  
 * 1 - IF SUCCESFULLY EXECUTED  
 * @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS  
 * 
 *  
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @ps_ord_number, varchar(20), input, null;
 *       order number of the order
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 - PTSnnnnn - AuthorName -Revision Description 
 * 2/2/99 - add cmp_altid from useasbillto company to return set  
 * 1/5/00 - PTS6469 -  dpete - if you have an UNKNOWN consignee or shipper (origin or dest) use the city name in the city table  
 * 06/29/2001 - PTS 10870 - Vern Jewett  vmj1  - not returning copy # correctly.  
 * 04/22/2002 -     -  Jyang  - add terms_name to return set  
 * 12/5/2 - PTS6314 - DPETE - use company settings to control terms and linehaul restricitons on mail to  
 * 3/26/03 - PTS 16739 - DPETE  - Add cmp_contact for billto company, shipper_geoloc, cons geoloc  to return set for format 41  
 * 04/06/2006 - PTS 24923 - Imari Bremer - Create new order summary format for Arrow
 **/
  
declare 
 @order_nbr int,@copies  int,
 @temp_name   varchar(30) ,  
 @temp_addr   varchar(30) ,  
 @temp_addr2  varchar(30),  
 @temp_nmstct varchar(30),  
 @temp_altid  varchar(25),  
 @temp1 varchar(1),
 @temp6 varchar(6),
 @temp8 varchar(8),
 @temp20 varchar(20),
 @counter    int,  
 @ret_value  int,  
 @temp_terms    varchar(20),  
 @varchar50 varchar(50),
 @refexclude varchar(60),
 @float     float,
--24796
 @tariffkey_startdate datetime,  
--24796
@ivd_seq int,
--27677
@ord_hdrnumber int
--27677

 create table #ref (seqno int identity not null,
					refno varchar(50) null)
  
select @order_nbr = ord_hdrnumber from orderheader where ord_number = @ps_ord_number
select @copies = 1
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
 NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/  

--create all the accessorial records
 SELECT  orderheader.ord_number ivh_invoicenumber,     
         orderheader.ord_hdrnumber ivh_hdrnumber,   
  orderheader.ord_billto ivh_billto,   
  @temp_name ivh_billto_name ,  
  @temp_addr  ivh_billto_addr,  
  @temp_addr2 ivh_billto_addr2,           
  @temp_nmstct ivh_billto_nmctst,  
         orderheader.ord_terms ivh_terms,      
         orderheader.ord_totalcharge ivh_totalcharge,     
  orderheader.ord_shipper ivh_shipper,     
  @temp_name shipper_name,  
  @temp_addr shipper_addr,  
  @temp_addr2 shipper_addr2,  
  @temp_nmstct shipper_nmctst,  
         orderheader.ord_consignee ivh_consignee,     
  @temp_name consignee_name,  
  @temp_addr consignee_addr,  
  @temp_addr2 consignee_addr2,  
  @temp_nmstct consignee_nmctst,  
         orderheader.ord_originpoint ivh_originpoint,     
  @temp_name originpoint_name,  
  @temp_addr origin_addr,  
  @temp_addr2 origin_addr2,  
  @temp_nmstct origin_nmctst,  
         orderheader.ord_destpoint ivh_destpoint,     
  @temp_name destpoint_name,  
  @temp_addr dest_addr,  
  @temp_addr2 dest_addr2,  
  @temp_nmstct dest_nmctst,  
         orderheader.ord_invoicestatus ivh_invoicestatus,     
         orderheader.ord_origincity ivh_origincity,     
         orderheader.ord_destcity ivh_destcity,     
         orderheader.ord_originstate ivh_originstate,     
         orderheader.ord_deststate ivh_deststate,  
         orderheader.ord_originregion1 ivh_originregion1,     
         orderheader.ord_destregion1 ivh_destregion1,     
         orderheader.ord_supplier ivh_supplier,     
         orderheader.ord_startdate ivh_shipdate,     
         orderheader.ord_completiondate ivh_deliverydate,     
         orderheader.ord_revtype1 ivh_revtype1,     
         orderheader.ord_revtype2 ivh_revtype2,     
         orderheader.ord_revtype3 ivh_revtype3,     
         orderheader.ord_revtype4 ivh_revtype4,     
         orderheader.ord_totalweight ivh_totalweight,     
         orderheader.ord_totalpieces  ivh_totalpieces,     
         orderheader.ord_totalmiles ivh_totalmiles,     
         orderheader.ord_currency ivh_currency,     
         orderheader.ord_currencydate ivh_currencydate,     
         orderheader.ord_totalvolume ivh_totalvolume,     
         0 ivh_taxamount1,--invoiceheader.ivh_taxamount1,     
         0 ivh_taxamount2,--invoiceheader.ivh_taxamount2,     
         0 ivh_taxamount3,--invoiceheader.ivh_taxamount3,     
         0 ivh_taxamount4,--invoiceheader.ivh_taxamount4,     
         @temp6 ivh_transtype,--invoiceheader.ivh_transtype,     
         @temp1 ivh_creditmemo, --invoiceheader.ivh_creditmemo,     
         @temp8 ivh_applyto,--invoiceheader.ivh_applyto,     
         getdate()ivh_printdate , --invoiceheader.ivh_printdate,     
         getdate()ivh_billdate,--invoiceheader.ivh_billdate,     
         getdate()ivh_lastprintdate,--invoiceheader.ivh_lastprintdate,     
         orderheader.ord_originregion2 ivh_originregion2,     
         orderheader.ord_originregion3 ivh_originregion3,     
         orderheader.ord_originregion4 ivh_originregion4,     
         orderheader.ord_destregion2 ivh_destregion2,     
         orderheader.ord_destregion3 ivh_destregion3,     
         orderheader.ord_destregion4 ivh_destregion4,     
         orderheader.mfh_hdrnumber ,     
         orderheader.ord_remark ivh_remark,     
         orderheader.ord_driver1 ivh_driver,     
         orderheader.ord_tractor ivh_tractor,     
		 orderheader.ord_trailer ivh_trailer,     
         orderheader.ord_bookedby ivh_user_id1,--invoiceheader.ivh_user_id1,     
         @temp20 ivh_user_id2,--invoiceheader.ivh_user_id2,     
         orderheader.ord_refnum ivh_ref_number,     
         orderheader.ord_driver2 ivh_driver2,     
         orderheader.mov_number ,     
         @temp1 ivh_edi_flag,--invoiceheader.ivh_edi_flag,     
         orderheader.ord_hdrnumber,     
         ivd.ivd_number,     
         ivd.stp_number, 
         ivd_description = IsNull(ivd.ivd_description, cht.cht_description), 
         --ivd.ivd_description,     
         ivd.cht_itemcode,     
         ivd.ivd_quantity,     
         ivd.ivd_rate,     
         ivd.ivd_charge,  
   --ivd.ivd_taxable1,     
         --ivd.ivd_taxable2,     
 -- ivd.ivd_taxable3,     
         --ivd.ivd_taxable4,   
   ivd_taxable1 =  IsNull(cht.cht_taxtable1,ivd.ivd_taxable1),   -- taxable flags not set on ivd for gst,pst,etc    
   ivd_taxable2 =IsNull(cht.cht_taxtable2,ivd.ivd_taxable2),  
   ivd_taxable3 =IsNull(cht.cht_taxtable3,ivd.ivd_taxable3),  
   ivd_taxable4 =IsNull(cht.cht_taxtable4,ivd.ivd_taxable4),  
         ivd.ivd_unit,     
         ivd.cur_code,     
         ivd.ivd_currencydate,     
         ivd.ivd_glnum,     
         ivd.ivd_type,     
         ivd.ivd_rateunit,     
         ivd.ivd_billto,     
  @temp_name ivd_billto_name,  
  @temp_addr ivd_billto_addr,  
  @temp_addr2 ivd_billto_addr2,  
  @temp_nmstct ivd_billto_nmctst,  
         ivd.ivd_itemquantity,     
         ivd.ivd_subtotalptr,     
         ivd.ivd_allocatedrev,     
         ivd.ivd_sequence,     
         ivd.ivd_refnum,     
         ivd.cmd_code,     
         ivd.cmp_id,     
  @temp_name stop_name,  
  @temp_addr stop_addr,  
  @temp_addr2 stop_addr2,  
  @temp_nmstct stop_nmctst, 
         ivd.ivd_distance,     
         ivd.ivd_distunit,     
         ivd.ivd_wgt,     
         ivd.ivd_wgtunit,     
         ivd.ivd_count,     
  ivd.ivd_countunit,     
         ivd.evt_number,     
         ivd.ivd_reftype,     
         ivd.ivd_volume,     
         ivd.ivd_volunit,     
         ivd.ivd_orig_cmpid,     
         ivd.ivd_payrevenue,            
  0 ivh_freight_miles,--invoiceheader.ivh_freight_miles,  
  orderheader.tar_tarriffnumber,  
  orderheader.tar_tariffitem,  
  1 copies,  
  isnull(cht.cht_basis,'') cht_basis,  
  isnull(cht.cht_description,'') cht_description,  
  cmd.cmd_name,  
 @temp_altid cmp_altid,  
 ord_hideshipperaddr ivh_hideshipperaddr,  
 ord_hideconsignaddr ivh_hideconsignaddr,  
 (Case ord_showshipper   
  when 'UNKNOWN' then orderheader.ord_shipper  
  else IsNull(ord_showshipper,orderheader.ord_shipper)   
 end) ivh_showshipper,  
 (Case ord_showcons   
  when 'UNKNOWN' then orderheader.ord_consignee  
  else IsNull(ord_showcons,orderheader.ord_consignee)   
 end) ivh_showcons,  
 @temp_terms terms_name,  
 IsNull(ord_charge,0) ivh_charge,  
 @temp_addr2    ivh_billto_addr3,
 orderheader.tar_number,
 @tariffkey_startdate tariffkey_startdate,
 @varchar50 cmp_contact,  
 @varchar50 shipper_geoloc,  
 @varchar50 cons_geoloc ,
 @varchar50 ref1,
 @varchar50 ref2,
 @varchar50 ref3,
 @varchar50 ref4,
 @varchar50 ref5,
 @temp_addr2 shipper_addr3,
 @temp_addr2 consignee_addr3,
 orderheader.ord_quantity,
 orderheader.ord_rate,
 orderheader.ord_charge,
 cht.cht_description ord_cht_description,
 orderheader.ord_status,
 @float fgt_length,
 @float fgt_height,
 @float fgt_width
 into #invtemp_tbl  
 FROM orderheader JOIN invoicedetail AS ivd ON (orderheader.ord_hdrnumber = ivd.ord_hdrnumber) 
  RIGHT OUTER JOIN chargetype AS cht ON cht.cht_itemcode = ivd.cht_itemcode 
  LEFT OUTER JOIN commodity AS cmd ON cmd.cmd_code = ivd.cmd_code 
WHERE  orderheader.ord_hdrnumber = @order_nbr  
      --(invoicedetail.ord_hdrnumber = orderheader.ord_hdrnumber ) and  
      --(chargetype.cht_itemcode =* invoicedetail.cht_itemcode) and 
      --(invoicedetail.cmd_code *= commodity.cmd_code) and        
      --pts24923 ILB 02/10/2005
      --(chargetype.cht_itemcode =* orderheader.cht_itemcode) and  
      --pts24923 ILB 02/10/2005

--Create linehauls records records
 insert into #invtemp_tbl
 SELECT  orderheader.ord_number ivh_invoicenumber,     
         orderheader.ord_hdrnumber ivh_hdrnumber,   
  orderheader.ord_billto ivh_billto,   
  @temp_name ivh_billto_name ,  
  @temp_addr  ivh_billto_addr,  
  @temp_addr2 ivh_billto_addr2,           
  @temp_nmstct ivh_billto_nmctst,  
         orderheader.ord_terms ivh_terms,      
         orderheader.ord_totalcharge ivh_totalcharge,     
  orderheader.ord_shipper ivh_shipper,     
  @temp_name shipper_name,  
  @temp_addr shipper_addr,  
  @temp_addr2 shipper_addr2,  
  @temp_nmstct shipper_nmctst,  
         orderheader.ord_consignee ivh_consignee,     
  @temp_name consignee_name,  
  @temp_addr consignee_addr,  
  @temp_addr2 consignee_addr2,  
  @temp_nmstct consignee_nmctst,  
         orderheader.ord_originpoint ivh_originpoint,     
  @temp_name originpoint_name,  
  @temp_addr origin_addr,  
  @temp_addr2 origin_addr2,  
  @temp_nmstct origin_nmctst,  
         orderheader.ord_destpoint ivh_destpoint,     
  @temp_name destpoint_name,  
  @temp_addr dest_addr,  
  @temp_addr2 dest_addr2,  
  @temp_nmstct dest_nmctst,  
         orderheader.ord_invoicestatus ivh_invoicestatus,     
         orderheader.ord_origincity ivh_origincity,     
         orderheader.ord_destcity ivh_destcity,     
         orderheader.ord_originstate ivh_originstate,     
         orderheader.ord_deststate ivh_deststate,  
         orderheader.ord_originregion1 ivh_originregion1,     
         orderheader.ord_destregion1 ivh_destregion1,     
         orderheader.ord_supplier ivh_supplier,     
         orderheader.ord_startdate ivh_shipdate,     
         orderheader.ord_completiondate ivh_deliverydate,     
         orderheader.ord_revtype1 ivh_revtype1,     
         orderheader.ord_revtype2 ivh_revtype2,     
         orderheader.ord_revtype3 ivh_revtype3,     
         orderheader.ord_revtype4 ivh_revtype4,     
         orderheader.ord_totalweight ivh_totalweight,     
         orderheader.ord_totalpieces  ivh_totalpieces,     
         orderheader.ord_totalmiles ivh_totalmiles,     
         orderheader.ord_currency ivh_currency,     
         orderheader.ord_currencydate ivh_currencydate,     
         orderheader.ord_totalvolume ivh_totalvolume,     
         0 ivh_taxamount1,--invoiceheader.ivh_taxamount1,     
         0 ivh_taxamount2,--invoiceheader.ivh_taxamount2,     
         0 ivh_taxamount3,--invoiceheader.ivh_taxamount3,     
         0 ivh_taxamount4,--invoiceheader.ivh_taxamount4,     
         @temp6 ivh_transtype,--invoiceheader.ivh_transtype,     
         @temp1 ivh_creditmemo, --invoiceheader.ivh_creditmemo,     
         @temp8 ivh_applyto,--invoiceheader.ivh_applyto,     
         getdate()ivh_printdate , --invoiceheader.ivh_printdate,     
         getdate()ivh_billdate,--invoiceheader.ivh_billdate,     
         getdate()ivh_lastprintdate,--invoiceheader.ivh_lastprintdate,     
         orderheader.ord_originregion2 ivh_originregion2,     
         orderheader.ord_originregion3 ivh_originregion3,     
         orderheader.ord_originregion4 ivh_originregion4,     
         orderheader.ord_destregion2 ivh_destregion2,     
         orderheader.ord_destregion3 ivh_destregion3,     
         orderheader.ord_destregion4 ivh_destregion4,     
         orderheader.mfh_hdrnumber ,     
         orderheader.ord_remark ivh_remark,     
         orderheader.ord_driver1 ivh_driver,     
         orderheader.ord_tractor ivh_tractor,     
		 orderheader.ord_trailer ivh_trailer,     
         orderheader.ord_bookedby ivh_user_id1,--invoiceheader.ivh_user_id1,     
         @temp20 ivh_user_id2,--invoiceheader.ivh_user_id2,     
         orderheader.ord_refnum ivh_ref_number,     
         orderheader.ord_driver2 ivh_driver2,     
         orderheader.mov_number ,     
         @temp1 ivh_edi_flag,--invoiceheader.ivh_edi_flag,     
         orderheader.ord_hdrnumber,     
         stops.stp_sequence,     
         stops.stp_number, 
         stp_description , 
         null, --invoicedetail.cht_itemcode,     
	 null,-- invoicedetail.ivd_quantity,     
         null , --invoicedetail.ivd_rate,     
         null , -- invoicedetail.ivd_charge,  
	 null, --   ivd_taxable1 =  IsNull(chargetype.cht_taxtable1,invoicedetail.ivd_taxable1),   -- taxable flags not set on ivd for gst,pst,etc    
    	 null , -- ivd_taxable2 =IsNull(chargetype.cht_taxtable2,invoicedetail.ivd_taxable2),  
   	 null , --ivd_taxable3 =IsNull(chargetype.cht_taxtable3,invoicedetail.ivd_taxable3),  
         null, -- ivd_taxable4 =IsNull(chargetype.cht_taxtable4,invoicedetail.ivd_taxable4),  
         null, --invoicedetail.ivd_unit,     
         null, -- invoicedetail.cur_code,     
         null, --invoicedetail.ivd_currencydate,     
         null, --invoicedetail.ivd_glnum,     
         null, --invoicedetail.ivd_type,     
         null, --invoicedetail.ivd_rateunit,     
         orderheader.ord_billto,     
  @temp_name ivd_billto_name,  
  @temp_addr ivd_billto_addr,  
  @temp_addr2 ivd_billto_addr2,  
  @temp_nmstct ivd_billto_nmctst,  
      null,--   invoicedetail.ivd_itemquantity,     
      null,--         invoicedetail.ivd_subtotalptr,     
      null,--         invoicedetail.ivd_allocatedrev,     
      stp_sequence,--         invoicedetail.ivd_sequence,     
      null,--         invoicedetail.ivd_refnum,     
      stops.cmd_code,--         invoicedetail.cmd_code,     
      stops.cmp_id ,--         invoicedetail.cmp_id,     
  @temp_name stop_name,  
  @temp_addr stop_addr,  
  @temp_addr2 stop_addr2,  
  @temp_nmstct stop_nmctst,  
         stops.stp_lgh_mileage ivd_distance,     
         'MIL'ivd_distunit,     
         stops.stp_weight ivd_wgt,     
         stops.stp_weightunit ivd_wgtunit,     
         stops.stp_count ivd_count,     
  	 stops.stp_countunit ivd_countunit,     
         null,--invoicedetail.evt_number,     
         stops.stp_reftype ivd_reftype,     
         stops.stp_volume ivd_volume,     
         stops.stp_volumeunit ivd_volunit,     
      	 null,--         invoicedetail.ivd_orig_cmpid,     
         null,--invoicedetail.ivd_payrevenue,  
  0 ivh_freight_miles,--invoiceheader.ivh_freight_miles,  
  orderheader.tar_tarriffnumber,  
  orderheader.tar_tariffitem,  
  1 copies,  
  '', --chargetype.cht_basis,  
      '',--  chargetype.cht_description,  
  stops.cmd_code , --commodity.cmd_name,  
 @temp_altid cmp_altid,  
 ord_hideshipperaddr ivh_hideshipperaddr,  
 ord_hideconsignaddr ivh_hideconsignaddr,  
 (Case ord_showshipper   
  when 'UNKNOWN' then orderheader.ord_shipper  
  else IsNull(ord_showshipper,orderheader.ord_shipper)   
 end) ivh_showshipper,  
 (Case ord_showcons   
  when 'UNKNOWN' then orderheader.ord_consignee  
  else IsNull(ord_showcons,orderheader.ord_consignee)   
 end) ivh_showcons,  
 @temp_terms terms_name,  
 IsNull(ord_charge,0) ivh_charge,  
 @temp_addr2    ivh_billto_addr3,
 orderheader.tar_number,
 @tariffkey_startdate tariffkey_startdate,
 @varchar50 cmp_contact,  
 @varchar50 shipper_geoloc,  
 @varchar50 cons_geoloc ,
 @varchar50 ref1,
 @varchar50 ref2,
 @varchar50 ref3,
 @varchar50 ref4,
 @varchar50 ref5,
 @temp_addr2 shipper_addr3,
 @temp_addr2 consignee_addr3,
 orderheader.ord_quantity,
 orderheader.ord_rate,
 orderheader.ord_charge,
 chargetype.cht_description ord_cht_description,
 orderheader.ord_status,
 @float fgt_length,
 @float fgt_height,
 @float fgt_width
 from orderheader ,stops, chargetype
where orderheader.ord_hdrnumber = @order_nbr and
      orderheader.ord_hdrnumber = stops.ord_hdrnumber and
      orderheader.cht_itemcode = chargetype.cht_itemcode and
      stops.stp_type ='DRP'

If Not Exists (Select cmp_mailto_name From company c, #invtemp_tbl t  
        Where c.cmp_id = t.ivh_billto  
   And Rtrim(IsNull(cmp_mailto_name,'')) > ''  
   And t.ivh_terms in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3,   
    Case IsNull(cmp_mailtoTermsMatchFlag,'Y') When 'Y' Then '^^' ELse t.ivh_terms End)  
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
/*     
if @useasbillto = 'ORD'  
 begin  
 update #invtemp_tbl  
  set ivh_billto_name = company.cmp_name,  
    ivh_billto_addr = company.cmp_address1,  
    ivh_billto_addr2 = company.cmp_address2,    
    ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip ,  
   #invtemp_tbl.cmp_altid = company.cmp_altid   
  from #invtemp_tbl, company, invoiceheader  
  where #invtemp_tbl.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and  
    company.cmp_id = invoiceheader.ivh_order_by  
 end     
if @useasbillto = 'SHP'  
 begin  
 update #invtemp_tbl  
  
  set ivh_billto_name = company.cmp_name,  
    ivh_billto_addr = company.cmp_address1,  
    ivh_billto_addr2 = company.cmp_address2,    
    ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip ,  
   #invtemp_tbl.cmp_altid = company.cmp_altid   
  from #invtemp_tbl, company  
  where company.cmp_id = #invtemp_tbl.ivh_shipper  
 end     
*/     
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
 shipper_addr3 = company.cmp_address3,
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
 consignee_addr3 = company.cmp_address3,
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
   set stop_nmctst = substring(cty.cty_nmstct,1, (charindex('/', cty.cty_nmstct)))+ ' ' +IsNull(cty.cty_zip,'')   
  from #invtemp_tbl, stops --,city  
        right outer join city as cty on cty.cty_code = stops.stp_city
 where #invtemp_tbl.stp_number IS NOT NULL  
   and stops.stp_number =  #invtemp_tbl.stp_number  
 --and city.cty_code =* stops.stp_city  
  
update #invtemp_tbl  
set terms_name = la.name  
from labelfile la  
where la.labeldefinition = 'creditterms' and  
     la.abbr = #invtemp_tbl.ivh_terms  

--24796
update #invtemp_tbl
   set #invtemp_tbl.tariffkey_startdate = tar.trk_startdate
  from #invtemp_tbl  , tariffkey tar
 where #invtemp_tbl.tar_number = tar.tar_number
--24796

update #invtemp_tbl set ivh_driver = null where ivh_driver = 'UNKNOWN'
update #invtemp_tbl set ivh_tractor = null where ivh_tractor = 'UNKNOWN'
update #invtemp_tbl set ivh_trailer = null where ivh_trailer = 'UNKNOWN'

select @refexclude = gi_string1 from generalinfo where gi_name = 'INV_MB_REFEXCLUDE'
If datalength(@refexclude) > 0 
	insert into #ref 
	select ref_type+':'+ref_number from referencenumber where ref_table = 'orderheader' and 
	ref_tablekey = @order_nbr and ref_type <> @refexclude
	--ref_tablekey = @order_nbr and ref_number <> @refexclude

else
	insert into #ref 
	select ref_type+':'+ref_number from referencenumber where ref_table = 'orderheader' and 
	ref_tablekey = @order_nbr 
	--ref_tablekey = @order_nbr and ref_number <> @refexclude

update #invtemp_tbl set ref1 = refno from #ref where seqno = 1
update #invtemp_tbl set ref2 = refno from #ref where seqno = 2
update #invtemp_tbl set ref3 = refno from #ref where seqno = 3
update #invtemp_tbl set ref4 = refno from #ref where seqno = 4
update #invtemp_tbl set ref5 = refno from #ref where seqno = 5

--ILB
select @ivd_seq = max(ivd_sequence)
from #invtemp_tbl
where cht_itemcode is null

update #invtemp_tbl 
   set ord_charge = 0,
       ord_rate   = 0,
       ord_quantity = 0,
       ord_cht_description = ''
 where ivd_sequence <  @ivd_seq

--02/11/2005 ILB per client Elaine Tucker
update #invtemp_tbl
   set ivd_wgt       = stp_weight,     
       ivd_wgtunit   = stp_weightunit,     
       ivd_count     = stp_count,     
       ivd_countunit = stp_countunit,
       ivd_volume    = stp_volume,     
       ivd_volunit   = stp_volumeunit,
       fgt_length = freightdetail.fgt_length,
       fgt_height = freightdetail.fgt_height,
       fgt_width  = freightdetail.fgt_width
  from stops, #invtemp_tbl, freightdetail
 where stops.ord_hdrnumber = @order_nbr and
       stops.stp_number = #invtemp_tbl.stp_number and
       stops.stp_number = freightdetail.stp_number       
--02/11/2005 ILB

--PTS# 27677 ILB 04/07/2005
SELECT @ord_hdrnumber = MIN(ord_hdrnumber) 
  FROM #invtemp_tbl 
 WHERE ord_hdrnumber > 0 
	
IF @ord_hdrnumber IS NOT NULL
 BEGIN
   IF exists (SELECT * 
                FROM orderheader 
                WHERE ord_hdrnumber = @ord_hdrnumber AND 
                     (ord_length > 0 or ord_width > 0 or ord_height > 0))
	BEGIN
  	       UPDATE #invtemp_tbl 
                  SET fgt_length = ord_length , 
                      fgt_width  = ord_width , 
                      fgt_height = ord_height
		 FROM orderheader 
                WHERE orderheader.ord_hdrnumber = @ord_hdrnumber AND 
                      #invtemp_tbl.ord_hdrnumber = @ord_hdrnumber
	END
 END
--END PTS# 27677 ILB 04/07/2005
      
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
  isnull(cht_basis,'') cht_basis,  
  isnull(cht_description, '')cht_description ,
  cmd_name,  
  cmp_altid,  
 ivh_hideshipperaddr,  
 ivh_hideconsignaddr,  
 ivh_showshipper,  
 ivh_showcons,  
 terms_name,  
 IsNull(ivh_charge,0) ivh_charge,  
 ivh_billto_addr3,
--24796 
 tar_number, 
 tariffkey_startdate,
--24796
 cmp_contact,  
 shipper_geoloc,  
 cons_geoloc  ,
 ref1,
 ref2,
 ref3,
 ref4,
 ref5,
 shipper_addr3,
 consignee_addr3,
 ord_quantity,     
 ord_rate,     
 ord_charge,
 ord_cht_description,
 ord_status,
 isnull(fgt_length,0) fgt_length,
 isnull(fgt_height,0)fgt_height,
 isnull(fgt_width,0)fgt_width
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
  copies,  
  isnull(cht_basis,'') cht_basis,  
  isnull(cht_description, '')cht_description ,
  cmd_name,  
  cmp_altid,  
  ivh_showshipper,  
  ivh_showcons,  
  terms_name,  
  ivh_billto_addr3, 
 tar_number,
 tariffkey_startdate,
 ref1,
 ref2,
 ref3,
 ref4,
 ref5,
 shipper_addr3,
 consignee_addr3,
 ord_quantity,     
 ord_rate,     
 ord_charge,
 ord_cht_description, 
 ord_status,
 isnull(fgt_length,0) fgt_length,
 isnull(fgt_height,0)fgt_height,
 isnull(fgt_width,0)fgt_width
 from #invtemp_tbl  
 order by ivd_sequence, cht_itemcode
/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 select @ret_value = @@ERROR   
return @ret_value  

GO
GRANT EXECUTE ON  [dbo].[order_summary08] TO [public]
GO
