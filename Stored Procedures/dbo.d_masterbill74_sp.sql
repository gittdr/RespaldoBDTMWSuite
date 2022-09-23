SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

  
CREATE  PROC [dbo].[d_masterbill74_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8),   
                        @revtype1 varchar(6), @revtype2 varchar(6),@revtype3 varchar(6), @revtype4 varchar(6),@mbstatus varchar(6),  
                        @shipstart datetime,@shipend datetime,@billdate datetime,   
                               @shipper varchar(8), @consignee varchar(8),  
     @delstart datetime, @delend datetime,@orderby varchar(8), @taxacc varchar(6),@fromorder varchar(12))  
AS  
/**
 * NAME:
 * d_masterbill74_sp
 * 
 * TYPE:
 * StoredProcedure
 * 
 * DESCRIPTION:
 * Provide a return set for masterbill format 74
 * 
 * RETURN:
 * none
 * 
 * RESULT SETS:
 * Refer to the final select statement for the return set. 
 *
 * PARAMETERS:
 * 01 @reprintflag varchar(10)  Set to Y if reprint of existing masterbill
 * 02 @mbnumber int,@billto varchar(8), 
 * 03 @billto varchar(8)  
 * 04 @revtype1 varchar(6)
 * 05 @revtype2 varchar(6)
 * 06 @revtype3 varchar(6)
 * 07 @revtype4 varchar(6)
 * 08 @mbstatus varchar(6)  
 * 09  @shipstart datetime
 * 10 @shipend datetime
 * 11 @billdate datetime,   
 * 12 @shipper varchar(8)
 * 13 @consignee varchar(8),  
 * 14 @delstart datetime
 * 15 @delend datetime
 * 16 @orderby varchar(8)
 * 17  @taxacc varchar(6)
 * 18 @fromorder varchar(12)
 * 
 * REFERENCES: 
 *  NONE
 *
 * REVISION HISTORY:
 * 12/2/05 Tony Leonardi - based on invoice_template2
 *	1/2/07 PTS 30174 DPETE check in for Tony consol to 34920
 **/
Select @shipstart = convert(char(12),@shipstart)+'00:00:00'  
Select @shipend   = convert(char(12),@shipend  )+'23:59:59'  
Select @delstart = convert(char(12),@delstart)+'00:00:00'  
Select @delend   = convert(char(12),@delend  )+'23:59:59'
Select @fromorder = IsNull(@fromorder,'')  
 
  
-- If printflag is set to REPRINT, retrieve an already printed mb by #  
  
If UPPER(@reprintflag) = 'REPRINT'   
  BEGIN  
 --  INSERT Into #masterbill_tempx  
    Select  IsNull(invoiceheader.ord_hdrnumber, -1),  
  invoiceheader.ivh_invoicenumber,    
  invoiceheader.ivh_hdrnumber,   
  invoiceheader.ivh_billto,  
  invoiceheader.ivh_shipper,  
  invoiceheader.ivh_consignee,     
  invoiceheader.ivh_deliverydate,     
  invoiceheader.ivh_mbnumber,  
  ivh_shipto_name = cmp2.cmp_name,  
  ivh_shipto_nmstct =   
     CASE  
  WHEN cmp2.cmp_mailto_name IS NULL THEN   
     ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp2.cty_nmstct) -1  
            END),'')  
  WHEN (cmp2.cmp_mailto_name <= ' ') THEN   
     ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp2.cty_nmstct) -1  
            END),'')  
  ELSE ISNULL(SUBSTRING(cmp2.mailto_cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp2.mailto_cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp2.mailto_cty_nmstct) -1  
            END),'')  
     END,  
  ivh_billto_name = cmp1.cmp_name,  
  ivh_billto_address =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')  
  ELSE ISNULL(cmp1.cmp_mailto_address1,'')  
     END,  
  ivh_billto_address2 =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')  
  ELSE ISNULL(cmp1.cmp_mailto_address2,'')  
     END,  
  ivh_billto_nmstct =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN   
     ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp1.cty_nmstct) -1  
            END),'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN   
     ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp1.cty_nmstct) -1  
            END),'')  
  ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) -1  
            END),'')  
     END,  
 ivh_billto_zip =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')    
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')  
  ELSE ISNULL(cmp1.cmp_mailto_zip,'')  
     END,  
  ivh_consignee_name = cmp3.cmp_name,  
  ivh_consignee_nmstct =   
     CASE  
  WHEN cmp3.cmp_mailto_name IS NULL THEN   
     ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp3.cty_nmstct) -1  
            END),'')  
  WHEN (cmp3.cmp_mailto_name <= ' ') THEN   
     ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp3.cty_nmstct) -1  
            END),'')  
  ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp3.mailto_cty_nmstct) -1  
            END),'')  
     END,  
  
  ivh_billdate      billdate,  
  bill_quantity = ivd_quantity,  
  IsNull(ivd.ivd_unit, ''), 
ivd_rate,
ivd_charge, 
ivd.cmd_code,
--   ivd_rate = Case cht.cht_primary When 'Y' Then (Select sum(IsNull(ivd_rate,0)) From invoicedetail d2,chargetype c2 
-- 	where d2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and IsNull(d2.ivd_charge,0) <> 0 and d2.cht_itemcode = c2.cht_itemcode 
-- 	and (c2.cht_primary = 'Y' or c2.cht_rollintolh = 1) ) else ivd_rate End,  
--   ivd_charge = Case cht.cht_primary When 'Y' Then (Select sum(IsNull(ivd_charge,0)) From invoicedetail d3,chargetype c3 
-- 	where d3.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and IsNull(d3.ivd_charge,0) <> 0 and d3.cht_itemcode = c3.cht_itemcode 
-- 	and (c3.cht_primary = 'Y' or c3.cht_rollintolh = 1) ) else ivd_charge End,  
--  cmd_name = ord_description,  
  IsNull(cht_description, ''),  
  ivd_sequence,  
  1,  
  po = IsNull(ivh_ref_number,''),  
 isnull(ivh_remark,'') ,  
 cht.cht_primary,  
  @taxacc tax_acc,  
  ivd.cht_itemcode,  
  ivd.cht_basisunit,
  IsNull(ord.ord_fromorder ,'') ,
   ref_number =  isnull((select min(ref_number) from referencenumber where referencenumber.ord_hdrnumber = invoiceheader.ord_hdrnumber and ref_type = 'PO#'and ref_sequence = 1),''),
   bl_number = isnull((select min(ref_number) from referencenumber where referencenumber.ord_hdrnumber = invoiceheader.ord_hdrnumber and ref_type = 'BL#'and ref_sequence = 1),''),
   po_number = isnull((select min(ref_number) from referencenumber where referencenumber.ord_hdrnumber = invoiceheader.ord_hdrnumber and ref_type = 'PO'and ref_sequence = 1),'')
   From  invoiceheader
   join invoicedetail ivd on invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber 
   join orderheader ord on invoiceheader.ord_hdrnumber = ord.ord_hdrnumber  
   join company cmp1 on invoiceheader.ivh_billto = cmp1.cmp_id
   join company cmp2 on invoiceheader.ivh_shipper = cmp2.cmp_id
   join company cmp3 on  invoiceheader.ivh_consignee =  cmp3.cmp_id  
   join chargetype cht on  ivd.cht_itemcode = cht.cht_itemcode    
   Where ( invoiceheader.ivh_mbnumber = @mbnumber )  
  AND ivd_charge <> 0  
  And (cht.cht_primary = 'Y' or IsNull(cht.cht_rollintolh,0) = 0)  
 
  
  
  END  
  
-- for master bills with 'RTP' status  
  
ELSE  
  BEGIN  
 --    INSERT Into  #masterbill_tempx  
     Select  IsNull(invoiceheader.ord_hdrnumber, -1),  
  invoiceheader.ivh_invoicenumber,    
  invoiceheader.ivh_hdrnumber,   
  invoiceheader.ivh_billto,  
  invoiceheader.ivh_shipper,  
  invoiceheader.ivh_consignee,     
  invoiceheader.ivh_deliverydate,     
  @mbnumber ,  
  ivh_shipto_name = cmp2.cmp_name,  
    ivh_shipto_nmstct =   
     CASE  
  WHEN cmp2.cmp_mailto_name IS NULL THEN   
     ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp2.cty_nmstct) -1  
            END),'')  
  WHEN (cmp2.cmp_mailto_name <= ' ') THEN   
     ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp2.cty_nmstct) -1  
            END),'')  
  ELSE ISNULL(SUBSTRING(cmp2.mailto_cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp2.mailto_cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp2.mailto_cty_nmstct) -1  
            END),'')  
     END,  
  ivh_billto_name = cmp1.cmp_name,  
  ivh_billto_address =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')  
  ELSE ISNULL(cmp1.cmp_mailto_address1,'')  
     END,  
  ivh_billto_address2 =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')  
  ELSE ISNULL(cmp1.cmp_mailto_address2,'')  
     END,  
  ivh_billto_nmstct =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN   
     ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN  
         0  
       ELSE CHARINDEX('/',cmp1.cty_nmstct) -1  
            END),'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN   
     ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp1.cty_nmstct) -1  
            END),'')  
  ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) -1  
            END),'')  
     END,  
 ivh_billto_zip =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')    
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')  
  ELSE ISNULL(cmp1.cmp_mailto_zip,'')  
     END,  
  ivh_consignee_name = cmp3.cmp_name,  
  ivh_consignee_nmstct =   
     CASE  
  WHEN cmp3.cmp_mailto_name IS NULL THEN   
     ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp3.cty_nmstct) -1  
            END),'')  
  WHEN (cmp3.cmp_mailto_name <= ' ') THEN   
     ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp3.cty_nmstct) -1  
            END),'')  
  ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,CASE  
       WHEN CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1 < 0 THEN  
          0  
       ELSE CHARINDEX('/',cmp3.mailto_cty_nmstct) -1  
            END),'')  
     END,  
  @billdate      billdate,  
  bill_quantity = ivd_quantity,  
  IsNull(ivd.ivd_unit, ''),  
  ivd_rate = Case cht.cht_primary When 'Y' Then (Select sum(IsNull(ivd_rate,0)) From invoicedetail d2,chargetype c2 
	where d2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and IsNull(d2.ivd_charge,0) <> 0 and d2.cht_itemcode = c2.cht_itemcode 
	and (c2.cht_primary = 'Y' or c2.cht_rollintolh = 1) ) else ivd_rate End,  
  ivd_charge = Case cht.cht_primary When 'Y' Then (Select sum(IsNull(ivd_charge,0)) From invoicedetail d5,chargetype c5 
	where d5.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and IsNull(d5.ivd_charge,0) <> 0 and d5.cht_itemcode = c5.cht_itemcode 
	and (c5.cht_primary = 'Y' or c5.cht_rollintolh = 1) ) else ivd_charge End,  
  cmd_name  = ord_description,  
  IsNull(cht_description, ''),  
  ivd_sequence,  
  1,  
  po = IsNull(ivh_ref_number,''),  
 isnull(ivh_remark,''),  
 cht.cht_primary ,  
  @taxacc tax_acc,  
  ivd.cht_itemcode,  
  ivd.cht_basisunit ,
  IsNull(ord.ord_fromorder,'') ,
   ref_number = isnull((select min(ref_number) from referencenumber where referencenumber.ord_hdrnumber = invoiceheader.ord_hdrnumber and ref_type = 'PO#'and ref_sequence = 1),''),
   bl_number = isnull((select min(ref_number) from referencenumber where referencenumber.ord_hdrnumber = invoiceheader.ord_hdrnumber and ref_type = 'BL#'and ref_sequence = 1),''),
   po_number = isnull((select min(ref_number) from referencenumber where referencenumber.ord_hdrnumber = invoiceheader.ord_hdrnumber and ref_type = 'PO'and ref_sequence = 1),'')
   From  invoiceheader
   join invoicedetail ivd on invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber 
   join orderheader ord on invoiceheader.ord_hdrnumber = ord.ord_hdrnumber  
   join company cmp1 on invoiceheader.ivh_billto = cmp1.cmp_id
   join company cmp2 on invoiceheader.ivh_shipper = cmp2.cmp_id
   join company cmp3 on  invoiceheader.ivh_consignee =  cmp3.cmp_id  
   join chargetype cht on  ivd.cht_itemcode = cht.cht_itemcode    
 Where  ( invoiceheader.ivh_billto = @billto )    
  AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend )   
  AND    ( invoiceheader.ivh_deliverydate between @delstart AND @delend )   
  AND     (invoiceheader.ivh_mbstatus = 'RTP')    
  AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))  
  AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK'))   
  AND (@revtype3 in (invoiceheader.ivh_revtype3,'UNK'))  
  AND (@revtype4 in (invoiceheader.ivh_revtype4,'UNK'))   
  AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))  
  AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))  
  AND ivd_charge <> 0  
  And (cht.cht_primary = 'Y' or IsNull(cht.cht_rollintolh,0) = 0)  
 
  END  
  



GO
GRANT EXECUTE ON  [dbo].[d_masterbill74_sp] TO [public]
GO
