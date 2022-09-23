SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
   
    
CREATE PROC [dbo].[d_masterbill136_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8),     
 @revtype1 varchar(6), @revtype2 varchar(6),@revtype3 varchar(6), @revtype4 varchar(6),@mbstatus varchar(6),    
 @shipstart datetime,@shipend datetime,@billdate datetime,     
 @shipper varchar(8), @consignee varchar(8),
 @delstart datetime, @delend datetime,@orderby varchar(8),@Firstrefnumber varchar(40), @copy tinyint)
 
    
AS  
/**
 * DESCRIPTION:
 *    This format is used by a company that rates by total, and uses roll into line haul.  
 *    The format breaks on the first referencenumber on the order header    
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 05/26/09 PTS 47593
 *
 **/

      
    
declare @masterbill_temp TABLE  (  
  ord_hdrnumber int,    
  ivh_invoicenumber varchar(12),      
  ivh_hdrnumber int NULL,     
  ivh_billto varchar(8) NULL,    
  ivh_shipper varchar(8) NULL,    
  ivh_consignee varchar(8) NULL,
  ivh_shipdate datetime NULL ,   
  ivh_deliverydate datetime NULL,
  projectref varchar(30) NULL,
  poref varchar(30) NULL,
  refref varchar(30) NULL,        
  ivh_mbnumber int NULL,    
  shipper_name varchar(100) NULL ,  
  shipper_address varchar(100) NULL,  
  shipper_nmstct varchar(25) NULL ,    
  shipper_zip varchar(10) NULL,    
  billto_name varchar(100)  NULL,    
  billto_address varchar(50) NULL,    
  billto_address2 varchar(50) NULL,    
  billto_nmstct varchar(25) NULL ,    
  billto_zip varchar(9) NULL,    
  consignee_name varchar(100)  NULL,
  consignee_address varchar(100) NULL,    
  consignee_nmstct varchar(25)  NULL,    
  consignee_zip varchar(10) NULL,    
  billdate datetime NULL,    
  ord_number varchar(12) NULL,
  unitref varchar(30) NULL,
  description varchar(200) NULL,
  ivd_charge money null,
  ivh_remark varchar(255) NULL,
  ivd_sequence int NULL,
  ivd_type varchar(6) NULL,
  copy int NULL)


declare @anorder int,@po varchar(30),@ref varchar(30)

Select @shipstart = convert(char(12),@shipstart)+'00:00:00'    
Select @shipend   = convert(char(12),@shipend  )+'23:59:59'    
Select @delstart = convert(char(12),@delstart)+'00:00:00'    
Select @delend   = convert(char(12),@delend  )+'23:59:59'    

/* the customer teels us the PO# and REF refnumbers are the same for all orders on a master bill */

If @reprintflag = 'REPRINT'  
    select @anorder = min(ord_hdrnumber)
    from invoiceheader
    where ivh_mbnumber = @mbnumber 
    and ord_hdrnumber > 0
else
    select @anorder = min(ord_hdrnumber)
    from invoiceheader
    where ivh_billto = @billto
    and ivh_mbstatus = 'RTP'
    and ivh_ref_number = @Firstrefnumber
    and ord_hdrnumber > 0

select @anorder = isnull(@anorder,0)

If @anorder > 0 
  BEGIN
    select @po = (select top 1 ref_number
    from referencenumber 
    where ref_table = 'Orderheader'
    and ref_tablekey =   @anorder
    and ref_type = 'PO#')

    select @ref = (select top 1 ref_number
    from referencenumber 
    where ref_table = 'Orderheader'
    and ref_tablekey =   @anorder
    and ref_type = 'REF' )
  END
else
  select @po= '', @ref = ''

   
-- If printflag is set to REPRINT, retrieve an already printed mb by #    
    
If UPPER(@reprintflag) = 'REPRINT'       
  INSERT Into @masterbill_temp    
  Select  invoiceheader.ord_hdrnumber,    
  invoiceheader.ivh_invoicenumber,      
  invoiceheader.ivh_hdrnumber,     
  invoiceheader.ivh_billto,    
  invoiceheader.ivh_shipper,    
  invoiceheader.ivh_consignee,
  invoiceheader.ivh_shipdate,       
  invoiceheader.ivh_deliverydate,       
  projectref = invoiceheader.ivh_ref_number,
  poref = @po,
  refref = @ref,    
  invoiceheader.ivh_mbnumber,    
  ivh_shipto_name = cmp2.cmp_name, 
  shipper_address = cmp2.cmp_address1,   
  shipper_nmstct = left(cmp2.cty_nmstct ,charindex('/',cmp2.cty_nmstct+'/') - 1)   ,
  shipper_zip =  ISNULL(cmp2.cmp_zip ,''),         
  billto_name = case rtrim(isnull(cmp1.cmp_mailto_name,''))
     when '' then cmp1.cmp_name
     else cmp1.cmp_mailto_name
     end, 
  billto_address =     
     CASE   rtrim(isnull(cmp1.cmp_mailto_name,''))  
  WHEN '' THEN ISNULL(cmp1.cmp_address1,'')    
  ELSE ISNULL(cmp1.cmp_mailto_address1,'')    
     END,    
  billto_address2 =     
     CASE  rtrim(isnull(cmp1.cmp_mailto_name,''))  
     WHEN ''  THEN ISNULL(cmp1.cmp_address2,'')    
     ELSE ISNULL(cmp1.cmp_mailto_address2,'')    
     END,    
  billto_nmstct =     
     CASE  rtrim(isnull(cmp1.cmp_mailto_name,''))   
     WHEN ''  THEN  left(cmp1.cty_nmstct ,charindex('/',cmp1.cty_nmstct+'/') - 1) 
     ELSE left(cmp1.mailto_cty_nmstct ,charindex('/',cmp1.mailto_cty_nmstct+'/') - 1) 
     END,
  billto_zip =     
     CASE  rtrim(isnull(cmp1.cmp_mailto_name,''))    
      WHEN '' THEN ISNULL(cmp1.cmp_zip,'')    
      ELSE ISNULL(cmp1.cmp_mailto_zip,'')    
     END,    
  consignee_name = cmp3.cmp_name, 
  consignee_address = cmp3.cmp_address1,  
  consignee_nmstct = left(cmp3.cty_nmstct ,charindex('/',cmp3.cty_nmstct+'/') - 1)   ,   
  consignee_zip = ISNULL(cmp3.cmp_zip ,''),      
  billdate = ivh_billdate      , 
  ord_number = case invoiceheader.ord_hdrnumber when 0 then ivh_invoicenumber else ord_number end,
  unitref = Case ivd_type
     when 'SUB' then (
         select top 1 ref_number
         from stops
         join freightdetail on stops.stp_number = freightdetail.stp_number
         join referencenumber on freightdetail.fgt_number = ref_tablekey  and ref_table = 'freightdetail'
         where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber
         and stops.ord_hdrnumber > 0
         and stp_type = 'DRP'
         and fgt_sequence = 1
         and ref_type = 'UNIT#'
         order by stp_sequence
         ) 
     else ''
     end,
  description = case ivd_type
    when 'SUB' then dbo.cmdseplist_fn(invoiceheader.ord_hdrnumber)
    else  Case isnull(ivd_description ,'UNKNOWN')
           when 'UNKNOWN' then '    '+ cht_description
           when '' then '    ' + cht_description
           else '   '+ivd_description
           end
    end,
  ivd_charge = case ivd_type
    when 'SUB' then (select sum(ivd_charge) from invoicedetail ivd2 
       where ivd2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and (cht_rollintolh = 1 or ivd_type = 'SUB'))
    else ivd_charge
    end ,
  ivh_remark,
  ivd_sequence ,
  ivd_type ,
  1

  From  invoiceheader
  join invoicedetail on invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
  join  company cmp1 on   invoiceheader.ivh_billto = cmp1.cmp_id 
  join  company cmp2 on   invoiceheader.ivh_shipper = cmp2.cmp_id
  join  company cmp3 on   invoiceheader.ivh_consignee = cmp3.cmp_id
  left outer join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
  Where ( invoiceheader.ivh_mbnumber = @mbnumber ) 
  and ivd_charge <> 0 
  and invoicedetail.cht_rollintolh = 0 
  
 
    
If UPPER(@reprintflag) <> 'REPRINT'     
  INSERT Into @masterbill_temp    
  Select  invoiceheader.ord_hdrnumber,    
  invoiceheader.ivh_invoicenumber,      
  invoiceheader.ivh_hdrnumber,     
  invoiceheader.ivh_billto,    
  invoiceheader.ivh_shipper,    
  invoiceheader.ivh_consignee,
  invoiceheader.ivh_shipdate,       
  invoiceheader.ivh_deliverydate,       
  projectref = invoiceheader.ivh_ref_number,
  poref = @po,
  refref = @ref,    
  ivh_mbnumber  = @mbnumber,    
  ivh_shipto_name = cmp2.cmp_name, 
  shipper_address = cmp2.cmp_address1,   
  shipper_nmstct = left(cmp2.cty_nmstct ,charindex('/',cmp2.cty_nmstct+'/') - 1)   ,
  shipper_zip =  ISNULL(cmp2.cmp_zip ,''),         
  billto_name = case rtrim(isnull(cmp1.cmp_mailto_name,''))
     when '' then cmp1.cmp_name
     else cmp1.cmp_mailto_name
     end, 
  billto_address =     
     CASE   rtrim(isnull(cmp1.cmp_mailto_name,''))  
  WHEN '' THEN ISNULL(cmp1.cmp_address1,'')    
  ELSE ISNULL(cmp1.cmp_mailto_address1,'')    
     END,    
  billto_address2 =     
     CASE   rtrim(isnull(cmp1.cmp_mailto_name,''))  
     WHEN ''  THEN ISNULL(cmp1.cmp_address2,'')    
     ELSE ISNULL(cmp1.cmp_mailto_address2,'')    
     END,    
  billto_nmstct =     
     CASE  rtrim(isnull(cmp1.cmp_mailto_name,''))   
     WHEN ''  THEN  left(cmp1.cty_nmstct ,charindex('/',cmp1.cty_nmstct+'/') - 1) 
     ELSE left(cmp1.mailto_cty_nmstct ,charindex('/',cmp1.mailto_cty_nmstct+'/') - 1) 
     END,    
  billto_zip =     
     CASE  rtrim(isnull(cmp1.cmp_mailto_name,''))    
      WHEN '' THEN ISNULL(cmp1.cmp_zip,'')    
      ELSE ISNULL(cmp1.cmp_mailto_zip,'')    
     END,    
  consignee_name = cmp3.cmp_name, 
  consignee_address = cmp3.cmp_address1,  
  consignee_nmstct = left(cmp3.cty_nmstct ,charindex('/',cmp3.cty_nmstct+'/') - 1)   ,   
  consignee_zip = ISNULL(cmp3.cmp_zip ,''),      
  billdate = @billdate      , 
  ord_number = case invoiceheader.ord_hdrnumber when 0 then ivh_invoicenumber else ord_number end,
  unitref = Case ivd_type
     when 'SUB' then (
         select top 1 ref_number
         from stops
         join freightdetail on stops.stp_number = freightdetail.stp_number
         join referencenumber on freightdetail.fgt_number = ref_tablekey  and ref_table = 'freightdetail'
         where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber
         and stops.ord_hdrnumber > 0
         and stp_type = 'DRP'
         and fgt_sequence = 1
         and ref_type = 'UNIT#'
         order by stp_sequence
         ) 
     else ''
     end,
  description = case ivd_type
    when 'SUB' then dbo.cmdseplist_fn(invoiceheader.ord_hdrnumber)
    else  Case isnull(ivd_description ,'UNKNOWN')
           when 'UNKNOWN' then cht_description
           when '' then cht_description
           else ivd_description
           end
    end,
  ivh_charge = case ivd_type
    when 'SUB' then (select sum(ivd_charge) from invoicedetail ivd2 
       where ivd2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and ( cht_rollintolh = 1 or ivd_type = 'SUB'))
    else ivd_charge
    end ,
  ivh_remark ,
  ivd_sequence ,
  ivd_type,
  1
  From  invoiceheader
  join invoicedetail on invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
  join  company cmp1 on   invoiceheader.ivh_billto  = cmp1.cmp_id 
  join  company cmp2 on   invoiceheader.ivh_shipper = cmp2.cmp_id
  join  company cmp3 on   invoiceheader.ivh_consignee = cmp3.cmp_id
  left outer join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
  Where  ( invoiceheader.ivh_billto = @billto ) 
  AND    (invoiceheader.ivh_mbstatus = 'RTP')
  AND    isnull(ivh_ref_number ,'') = @firstrefnumber 
  and    ivd_charge <> 0 
  and    invoicedetail.cht_rollintolh = 0          
  AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend )     
  AND    ( invoiceheader.ivh_deliverydate between @delstart AND @delend )     
  AND    (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))      
  AND    (@revtype2 in (invoiceheader.ivh_revtype2,'UNK'))     
  AND    (@revtype3 in (invoiceheader.ivh_revtype3,'UNK'))    
  AND    (@revtype4 in (invoiceheader.ivh_revtype4,'UNK'))    
  AND    (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))    
  AND    (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))         


    
    


 Select 
  ord_hdrnumber,   
  ivh_invoicenumber ,     
  ivh_hdrnumber,     
  ivh_billto,    
  ivh_shipper,    
  ivh_consignee,
  ivh_shipdate,    
  ivh_deliverydate,
  projectref,
  poref ,
  refref,        
  ivh_mbnumber,    
  shipper_name,  
  shipper_address,  
  shipper_nmstct,    
  shipper_zip ,    
  billto_name ,    
  billto_address ,    
  billto_address2,    
  billto_nmstct, 
  billto_zip, 
  consignee_name,
  consignee_address, 
  consignee_nmstct,  
  consignee_zip,    
  billdate ,    
  ord_number ,
  unitref,
  description ,
  ivd_charge,
  ivh_remark,
  ivd_sequence,
  ivd_type,
  copy
 From  @masterbill_temp    

 --ORDER BY ivh_shipdate,ord_hdrnumber    
    

GO
GRANT EXECUTE ON  [dbo].[d_masterbill136_sp] TO [public]
GO
