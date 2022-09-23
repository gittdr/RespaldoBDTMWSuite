SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- 03/18/02 JYANG store proc for pegasus interface    
-- 04/17/02 DPETE proc will not execute   
-- 5/31/02 DPETE 14513 remove delete from the  pegasus_invoicelist table at request of VanHelden  
-- DPETE PTS 15096 Add cmp_misc 4 field to hold required supporting docs for Express Leasing  
--DPETE 15622 Cowan needs master bill number returned. Requested by Pegasus  
--15606 master bill sometimes comes back as null on misc invoices.  
--DPETE 15872 Return mb_number form pegasus_invoicelist , timing problem invoiceheader not yet updated when this proc is called.  
--DPETE 14485 Provide a wayaround cmp_ctynnmstct values with no /. Getting invalid length on substrign function    
--DPETE PTS 16234 remove CR/LF from remarks field, Pegasus cannot handle  
--DPETE PTS 17361 (Allison Fentriss 2/25 request) to make dates mm/dd/ccyy.  
--DPETE PTS18173 search for BL from stops then order or vise versa  
-- DPETE PTS 25769 order by the new idenetiy col so that records are returned
--    in the sequence in which they appear on the document if gi ImageSupportDocSeq = MB
--DPETE 32507 customer getting 'subquery returns more than one row error on line 46
create procedure [dbo].[image_invoicedata001_sp](@pegcontrol int)    
as    
/* PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND    
 1 - IF SUCCESFULLY EXECUTED    
 @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS    
*/    
declare @billto varchar(8),    
 @temp_fax   varchar(20),    
 @temp_email varchar(50) ,  
 @seq varchar(20),
 @docsequence varchar(50)

/* determine the sequence in which records are to be returned */

Select @docsequence = UPPER(gi_string1) From generalinfo Where gi_name = 'ImageSupportDocSeq'
Select @docsequence = IsNull(@docsequence,'INV') 

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */    
Select @seq = gi_string1 From generalinfo Where gi_name = 'ImagingBLSearchSeq'  
Select @seq = (Case @seq When 'ORD/STOP' then @seq When 'STOP/ORD' Then @seq Else 'ORD/STOP' End)  
  
    
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET     
 NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/   
  
Create table #Invref (ivh_hdrnumber int Null, ord_hdrnumber int null,ref_number varchar(30) null)   
  
Insert into #Invref   
Select  inv.ivh_hdrnumber,inv.ord_hdrnumber,''  
FROM pegasus_invoicelist peg , invoiceheader inv  
WHERE peg.peg_controlnumber = @pegcontrol   
And inv.ivh_hdrnumber = peg.ivh_hdrnumber  

If @seq = 'ORD/STOP'  
 BEGIN  
  Update #invref  
  Set ref_number = (  
  Select min(ref_number) From referencenumber Where ref_table = 'orderheader'   
  and ref_tablekey = #invref.ord_hdrnumber 
  and ref_type in  ('BL#','BOL')  
  and ref_sequence = (Select Min(ref_sequence) From referencenumber Where   
      ref_table = 'orderheader'   
     and ref_tablekey = #invref.ord_hdrnumber and ref_type in ('BL#','BOL')))
  Where ord_hdrnumber > 0  
  
  Update #invref  
  Set ref_number =  (  
  Select MIN(ref_number) From referencenumber Where ref_table = 'stops'   
  and ref_tablekey in (select stp_number from stops where stops.ord_hdrnumber =  #invref.ord_hdrnumber)  
  and ref_type in  ('BL#','BOL') 
  and ref_sequence = (Select Min(ref_sequence) From referencenumber Where   
      ref_table = 'stops'   
     and ref_tablekey in (select stp_number from stops where stops.ord_hdrnumber =  #invref.ord_hdrnumber
     and ref_type in  ('BL#','BOL') ) )
   )
  Where IsNull(ref_number,'') = ''   
  and ord_hdrnumber > 0  
 END  
Else  
 BEGIN  
   Update #invref  
  Set ref_number =  (  
  Select MIN(ref_number) From referencenumber Where ref_table = 'stops'   
  and ref_tablekey in (select stp_number from stops where stops.ord_hdrnumber =  #invref.ord_hdrnumber)  
  and ref_type in  ('BL#','BOL') 
  and ref_sequence = (Select Min(ref_sequence) From referencenumber Where   
      ref_table = 'stops'   
     and ref_tablekey in (select stp_number from stops where stops.ord_hdrnumber =  #invref.ord_hdrnumber
     and ref_type in  ('BL#','BOL') ) )
   )
  Where  ord_hdrnumber > 0  
  
 Update #invref  
  Set ref_number = (  
  Select min(ref_number) From referencenumber Where ref_table = 'orderheader'   
  and ref_tablekey = #invref.ord_hdrnumber 
  and ref_type in  ('BL#','BOL')  
  and ref_sequence = (Select Min(ref_sequence) From referencenumber Where   
      ref_table = 'orderheader'   
     and ref_tablekey = #invref.ord_hdrnumber and ref_type in ('BL#','BOL')))
  Where IsNull(ref_number,'') = ''   
  and ord_hdrnumber > 0 
  
 END  
    
 SELECT  ord_number = IsNull(invoiceheader.ord_number,''),    
 ivh_invoicenumber=IsNull(invoiceheader.ivh_invoicenumber,'') ,      
   ivh_hdrnumber=IsNull(invoiceheader.ivh_hdrnumber, 0),    
  ivh_billto = IsNull(invoiceheader.ivh_billto,'UNKNOWN'),     
  billto_name = IsNull(cmpb.cmp_name,'') ,    
  billto_addr = IsNull(cmpb.cmp_address1,''),    
  billto_addr2 = IsNull(cmpb.cmp_address2,''),    
  billto_citystatezip  = Case charindex('/',cmpb.cty_nmstct) WHen 0 Then cmpb.cty_nmstct Else IsNull(Substring(cmpb.cty_nmstct,1,charindex('/',cmpb.cty_nmstct) - 1),'')+'  '+IsNull(cmpb.cmp_zip,'') End,    
    ivh_terms=IsNull(invoiceheader.ivh_terms,''),        
    ivh_totalcharge = IsNull(invoiceheader.ivh_totalcharge,  0),     
  ivh_shipper = IsNull(invoiceheader.ivh_shipper,'UNKNOWN'),       
  shipper_name = IsNull(cmps.cmp_name,'') ,    
  shipper_addr = IsNull(cmps.cmp_address1,''),    
  shipper_addr2 = IsNull(cmps.cmp_address2,''),    
  shipper_citystatezip = Case charindex('/',cmps.cty_nmstct) WHen 0 Then cmps.cty_nmstct Else IsNull(Substring(cmps.cty_nmstct,1,charindex('/',cmps.cty_nmstct) - 1),'')+'  '+IsNull(cmps.cmp_zip,'') End,    
   ivh_consignee = IsNull( invoiceheader.ivh_consignee, 'UNKNOWN'),      
  consignee_name = IsNull(cmpc.cmp_name,'') ,    
  consignee_addr = IsNull(cmpc.cmp_address1,''),    
  consignee_addr2 = IsNull(cmpc.cmp_address2,''),   
  consignee_citystatezip = Case charindex('/',cmpc.cty_nmstct) WHen 0 Then cmpc.cty_nmstct Else IsNull(Substring(cmpc.cty_nmstct,1,charindex('/',cmpc.cty_nmstct) - 1),'')+'  '+IsNull(cmpc.cmp_zip,'') End,    
         ivh_invoicestatus = IsNull(invoiceheader.ivh_invoicestatus,'UNK'),       
       ivh_shipdate = Convert(char(10),IsNull( invoiceheader.ivh_shipdate, '1-1-1950'),101) ,     
        ivh_deliverydate = Convert(char(10),IsNull( invoiceheader.ivh_deliverydate,'1-1-1950'), 101),         
         ivh_revtype1=IsNull(invoiceheader.ivh_revtype1,''),       
         ivh_revtype2=IsNull(invoiceheader.ivh_revtype2,''),       
         ivh_revtype3=IsNull(invoiceheader.ivh_revtype3,''),       
         ivh_revtype4=IsNull(invoiceheader.ivh_revtype4,''),       
         ivh_totalweight=IsNull(invoiceheader.ivh_totalweight, 0),      
         ivh_totalpieces=IsNull(invoiceheader.ivh_totalpieces,0),       
         ivh_totalmiles=IsNull(invoiceheader.ivh_totalmiles,0),       
         ivh_currency=IsNull(invoiceheader.ivh_currency,''),       
         ivh_currencydate=Convert(char(10),IsNull(invoiceheader.ivh_currencydate,'1-1-1950'),101),       
         ivh_totalvolume=IsNull(invoiceheader.ivh_totalvolume,0),       
         ivh_taxamount1=IsNull(invoiceheader.ivh_taxamount1,0),       
         ivh_taxamount2=IsNull(invoiceheader.ivh_taxamount2,0),       
         ivh_taxamount3=IsNull(invoiceheader.ivh_taxamount3,0),       
         ivh_taxamount4=IsNull(invoiceheader.ivh_taxamount4, 0),      
         ivh_transtype = IsNull(invoiceheader.ivh_transtype, ''),      
         ivh_creditmemo = IsNull(invoiceheader.ivh_creditmemo,'N'),       
         ivh_applyto=IsNull(invoiceheader.ivh_applyto,''),       
         ivh_printdate=Convert(char(10),IsNull(invoiceheader.ivh_printdate, '1-1-1950') ,101),     
         ivh_billdate=convert(char(10),IsNull(invoiceheader.ivh_billdate, '1-1-1950') , 101),        
         ivh_lastprintdate=Convert(char(10),IsNull(invoiceheader.ivh_lastprintdate,  '1-1-1950') , 101),    
     ivh_originregion1=IsNull(invoiceheader.ivh_originregion1, ''),       
         ivh_originregion2=IsNull(invoiceheader.ivh_originregion2,''),       
         ivh_originregion3=IsNull(invoiceheader.ivh_originregion3, ''),      
         ivh_originregion4=IsNull(invoiceheader.ivh_originregion4, ''),   
     ivh_destregion1=IsNull(invoiceheader.ivh_destregion1,''),          
         ivh_destregion2=IsNull(invoiceheader.ivh_destregion2,''),       
          ivh_destregion3=IsNull(invoiceheader.ivh_destregion3,''),    
    ivh_destregion4=IsNull(invoiceheader.ivh_destregion4,''),      
         ivh_remark = IsNull(replace(replace(ivh_remark,Char(13),''),char(10),' '),''),       
         ivh_driver=IsNull(invoiceheader.ivh_driver,   'UNKNOWN'),    
         ivh_tractor=IsNull(invoiceheader.ivh_tractor,   'UNKNOWN'),        
         ivh_trailer=IsNull(invoiceheader.ivh_trailer,   'UNKNOWN'),      
   ivh_carrier=IsNull(invoiceheader.ivh_carrier,'UNKNOWN'),         
         --ivh_ref_number = IsNull(invoiceheader.ivh_ref_number,''),    
   ivh_ref_number = IsNull(#invref.ref_number,''),  
         ivh_driver2=IsNull(invoiceheader.ivh_driver2,'UNKNOWN'),        
         cmp_edi210 = IsNull(cmpb.cmp_edi210,0),       
         ord_hdrnumber=IsNull(invoiceheader.ord_hdrnumber, 0),      
         stp_number = IsNull(invoicedetail.stp_number, 0),      
         ivd_description=IsNull(invoicedetail.ivd_description,''),       
         cht_itemcode=IsNull(invoicedetail.cht_itemcode,''),       
         ivd_quantity= Isnull(invoicedetail.ivd_quantity, 0),      
         ivd_rate=IsnUll(invoicedetail.ivd_rate, 0),      
         ivd_charge=IsNull(invoicedetail.ivd_charge, 0),      
         ivd_taxable2 = IsNull(invoicedetail.ivd_taxable1,'N'),       
         ivd_taxable2=IsNull(invoicedetail.ivd_taxable2,'N'),       
     ivd_taxable3=IsNull(invoicedetail.ivd_taxable3,'N'),       
         ivd_taxable4=IsNull(invoicedetail.ivd_taxable4, 'N'),      
         ivd_unit=IsNull(invoicedetail.ivd_unit, 'UNK'),      
         ivd_glnum = IsNull(invoicedetail.ivd_glnum,''),       
         ivd_type=IsNull(invoicedetail.ivd_type, ''),      
         ivd_rateunit=IsNull(invoicedetail.ivd_rateunit,  ''),     
         ivd_sequence=IsNull(invoicedetail.ivd_sequence, 0) ,     
         ivd_refnum = IsNull(invoicedetail.ivd_refnum,''),       
         cmd_code=IsNull(invoicedetail.cmd_code, 'UNKNOWN'),      
         cmp_id = IsNull(invoicedetail.cmp_id,''),       
         ivd_wgt=IsNull(invoicedetail.ivd_wgt, 0),      
         ivd_wgtunit=IsNull(invoicedetail.ivd_wgtunit, ''),      
         ivd_count=IsNull(invoicedetail.ivd_count,0),       
     ivd_countunit=IsNull(invoicedetail.ivd_countunit,0) ,      
         ivd_reftype = IsNull(invoicedetail.ivd_reftype, ''),      
         ivd_volume=IsNull(invoicedetail.ivd_volume, 0),      
         ivd_volunit=IsNull(invoicedetail.ivd_volunit, '') ,     
  ivh_freightmiles = IsNull(invoiceheader.ivh_freight_miles, 0),   
  tar_tariffnumber = Case ivh_rateby When 'T' Then IsNull(invoiceheader.tar_tarriffnumber,'') Else IsNull(invoicedetail.tar_tariffnumber,'') End,    
  tar_tariffitem  = Case ivh_rateby When 'D' Then IsNull(invoiceheader.tar_tariffitem,'') Else IsNull(invoicedetail.tar_tariffitem,'') End,    
  cmp_altid = IsNull(cmpb.cmp_altid,''),    
  cmp_faxphone = Case IsNull(Rtrim(cmpb.cmp_faxphone),'') when '' Then IsNull((Select min(email_address)     
     From companyemail  Where  cmp_id      = invoiceheader.ivh_billto AND mail_default = 'Y' and    
  type = 'F'),'')  else  IsNull(Rtrim(cmpb.cmp_faxphone),'') end,    
  IsNull((select  min(email_address) From companyemail   
     Where  cmp_id= invoiceheader.ivh_billto  AND  mail_default = 'Y' and  type = 'E'),'')  cmp_email,  
  requireddocs = IsNull(cmpb.cmp_misc4,''),  
  ivh_mbnumber=IsNull(peg.mb_number,0)  
FROM pegasus_invoicelist peg, invoiceheader, invoicedetail, company cmpb, company cmps, company cmpc ,#invref   
WHERE peg.peg_controlnumber = @pegcontrol and    
 peg.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and    
 invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber  and    
 cmpb.cmp_id = ivh_billto and    
 cmps.cmp_id = ivh_shipper and    
 cmpc.cmp_id = ivh_consignee and  
 #invref.ivh_hdrnumber =   peg.ivh_hdrnumber  
-- order by ivh_invoicenumber,ivd_sequence 
 order by Case @DocSequence When 'MB' Then peg_identity else 1 End,ivh_invoicenumber,ivd_sequence 
  
  
GRANT  EXECUTE  ON image_invoicedata001_sp  TO public


GO
GRANT EXECUTE ON  [dbo].[image_invoicedata001_sp] TO [public]
GO
