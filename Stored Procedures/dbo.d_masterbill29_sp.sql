SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill29_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8),   
                        @revtype1 varchar(6), @revtype2 varchar(6),@revtype3 varchar(6), @revtype4 varchar(6),@mbstatus varchar(6),  
                        @shipstart datetime,@shipend datetime,@billdate datetime,   
                               @shipper varchar(8), @consignee varchar(8),  
     @delstart datetime, @delend datetime,@orderby varchar(8), @taxacc varchar(6),@fromorder varchar(12))  
AS  
/**
 * DESCRIPTION:
 * Ricelli 
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
	 Pts 14856 Created by dpete 8/13/02, add restriction on ivd_charge <> 0 on 8/19  
	 PTS 15533 this format now depends on exactly how Ricelli enters orders. It will give strange resulsts to others.   
		 Ricelli wants to roll up any detail charges tagged rollinto lh into  
		 linehaul by rate and charge then it wants to hold the revenue based charges  for the end.  
		 They also want to add the ord_refnum to the restriction list for printing invoices 
	 DPETE PTS 16354 add break on to ord_fromorder 
 * 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
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
  ivd_rate = Case cht.cht_primary When 'Y' Then (Select sum(IsNull(ivd_rate,0)) From invoicedetail d2,chargetype c2 
	where d2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and IsNull(d2.ivd_charge,0) <> 0 and d2.cht_itemcode = c2.cht_itemcode 
	and (c2.cht_primary = 'Y' or c2.cht_rollintolh = 1) ) else ivd_rate End,  
  ivd_charge = Case cht.cht_primary When 'Y' Then (Select sum(IsNull(ivd_charge,0)) From invoicedetail d3,chargetype c3 
	where d3.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and IsNull(d3.ivd_charge,0) <> 0 and d3.cht_itemcode = c3.cht_itemcode 
	and (c3.cht_primary = 'Y' or c3.cht_rollintolh = 1) ) else ivd_charge End,  
  cmd_name = ord_description,  
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
  ref.ref_number
    From  invoiceheader,   
  company cmp1,   
  company cmp2,  
  company cmp3,  
  invoicedetail ivd,   
  chargetype cht,  
  orderheader ord  LEFT OUTER JOIN referencenumber ref ON (ref.ord_hdrnumber = ord.ord_hdrnumber and ref.ref_type = 'PO#'and ref.ref_sequence = 1)
   Where ( invoiceheader.ivh_mbnumber = @mbnumber )  
  AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)  
  AND (cmp1.cmp_id = invoiceheader.ivh_billto)   
  AND (cmp2.cmp_id = invoiceheader.ivh_shipper)  
  AND (cmp3.cmp_id = invoiceheader.ivh_consignee)   
  AND (ivd.cht_itemcode = cht.cht_itemcode)  
  AND (ord.ord_hdrnumber = invoiceheader.ord_hdrnumber)  
  AND ivd_charge <> 0  
  And (cht.cht_primary = 'Y' or IsNull(cht.cht_rollintolh,0) = 0)  
  --and (ref.ord_hdrnumber =* ord.ord_hdrnumber and ref.ref_type = 'PO#'and ref.ref_sequence = 1)
  
  
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
  ref.ref_number
    From  invoiceheader,   
  company cmp1,   
  company cmp2,  
  company cmp3,  
  invoicedetail ivd,   
  chargetype cht,  
  orderheader ord LEFT OUTER JOIN referencenumber ref ON (ref.ord_hdrnumber = ord.ord_hdrnumber and ref.ref_type = 'PO#' and ref.ref_sequence = 1)
 Where  ( invoiceheader.ivh_billto = @billto )    
  AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)  
  AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend )   
  AND    ( invoiceheader.ivh_deliverydate between @delstart AND @delend )   
  AND     (invoiceheader.ivh_mbstatus = 'RTP')    
  AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))  
  AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK'))   
  AND (@revtype3 in (invoiceheader.ivh_revtype3,'UNK'))  
  AND (@revtype4 in (invoiceheader.ivh_revtype4,'UNK'))   
  AND    (cmp1.cmp_id = invoiceheader.ivh_billto)  
  AND (cmp2.cmp_id = invoiceheader.ivh_shipper)  
   AND (cmp3.cmp_id = invoiceheader.ivh_consignee)  
  AND    (ivd.cht_itemcode = cht.cht_itemcode)  
  AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))  
  AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))  
  AND (ord.ord_hdrnumber = invoiceheader.ord_hdrnumber)
  And IsNull(ord_fromorder,'') = @fromorder  
  AND ivd_charge <> 0  
 -- And @refnum in ('',Isnull(ivh_ref_number,''))  
  And (cht.cht_primary = 'Y' or IsNull(cht.cht_rollintolh,0) = 0)  
 -- and (ref.ord_hdrnumber =* ord.ord_hdrnumber and ref.ref_type = 'PO#' and ref.ref_sequence = 1)
  END  
  
GO
GRANT EXECUTE ON  [dbo].[d_masterbill29_sp] TO [public]
GO
