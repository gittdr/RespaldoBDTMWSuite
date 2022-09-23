SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


create PROC [dbo].[d_masterbill86_sp] (@p_reprintflag varchar(10),@p_mbnumber int,@p_billto varchar(8),     
                        @p_revtype1 varchar(6), @p_revtype2 varchar(6),@p_revtype3 varchar(6), @p_revtype4 varchar(6),@p_mbstatus varchar(6),    
                        @p_shipstart datetime,@p_shipend datetime,@p_billdate datetime,     
                               @p_shipper varchar(8), @p_consignee varchar(8),    
     @p_delstart datetime, @p_delend datetime,@p_orderby varchar(8))    
AS    
/**  
 *   
 * NAME:  
 * dbo.d_masterbill86_sp     For Baird  
 *  
 * TYPE:  
 * [StoredProcedure]  
 *  
 * DESCRIPTION:  
 * This procedure returns datafor printing masterbill format 86  
 *  
 * RETURNS:  
 * Nothing  
 *  
 * RESULT SETS:   
 * none.  
 *  
 * PARAMETERS:  
 * 001 - @p_reprintflag varchar(10) = 'REPRINT' if master bill is reprinted from exisitng ivh_mbnumber  
 * 002 - @p_mbnumber int  
 * 003 - @p_billto varchar(8) bu=ill to company on all invoices  
 * 004 - @p_revtype1 varchar(6) select invoices for this value or all if UNK  
 * 005 - @p_revtype2 varchar(6) select invoices for this value or all if UNK  
 * 006 - @p_revtype3 varchar(6) select invoices for this value or all if UNK  
 * 007 - @p_revtype4 varchar(6) select invoices for this value or all if UNK  
 * 008 - @p_mbstatus varchar(6) select ivh_mbsataus based on this vaue  
 * 009 - @p_shipstart datetime select ivh_shipdate if grater than this value   
 * 010 - @p_shipend datetime select ivh_shipdate if less than this value   
 * 011 - @p_shipper varchar(8) select invoice based on this value if not UNKNOWN  
 * 012 - @p_consignee varchar(8) select invoice based on this value if not UNKNOWN  
 * 013 - @p_delstart datetime select ivh_deloverydate if grater than this value   
 * 014 - @p_delend datetime select ivh_deliverydate if less than this value   
 * 015 - @p_orderby varchar(8) select invoice based ont his value if not UNKNOWN  
 *  
 * REFERENCES:   
  
 *   
 * REVISION HISTORY:  
 * 06/20/2006.01 ? PTS33035 - D Petersen ? Created from proc for masterbill format 29  
 *  
 **/  
   
Select @p_shipstart = convert(char(12),@p_shipstart)+'00:00:00'    
Select @p_shipend   = convert(char(12),@p_shipend  )+'23:59:59'    
Select @p_delstart = convert(char(12),@p_delstart)+'00:00:00'    
Select @p_delend   = convert(char(12),@p_delend  )+'23:59:59'  
   
   
    
-- If printflag is set to REPRINT, retrieve an already printed mb by #    
    
If UPPER(@p_reprintflag) = 'REPRINT'     
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
  ivh_shipto_name = scmp.cmp_name,    
  ivh_shipto_nmstct =
     ISNULL(SUBSTRING(scmp.cty_nmstct,1,CASE    
       WHEN CHARINDEX('/',scmp.cty_nmstct)- 1 < 0 THEN    
          0    
       ELSE CHARINDEX('/',scmp.cty_nmstct) -1    
            END),'')    ,    
  ivh_billto_name = 
     CASE rtrim(isnull(bcmp.cmp_mailto_name,''))
     WHEN '' THEN bcmp.cmp_name
     ELSE bcmp.cmp_mailto_name
     END,    
  ivh_billto_address =     
     CASE  rtrim(isnull( bcmp.cmp_mailto_name,''))
     WHEN '' THEN ISNULL(bcmp.cmp_address1,'')    
     ELSE ISNULL(bcmp.cmp_mailto_address1,'')    
     END,    
  ivh_billto_address2 =     
     CASE  rtrim(isnull( bcmp.cmp_mailto_name,''))  
     WHEN '' THEN ISNULL(bcmp.cmp_address2,'')    
     ELSE ISNULL(bcmp.cmp_mailto_address2,'')    
     END,    
  ivh_billto_nmstct =     
     CASE rtrim(isnull( bcmp.cmp_mailto_name,''))    
  WHEN '' THEN     
     ISNULL(SUBSTRING(bcmp.cty_nmstct,1,CASE    
       WHEN CHARINDEX('/',bcmp.cty_nmstct)- 1 < 0 THEN    
          0    
       ELSE CHARINDEX('/',bcmp.cty_nmstct) -1    
            END),'')    
  ELSE ISNULL(SUBSTRING(bcmp.mailto_cty_nmstct,1,CASE    
       WHEN CHARINDEX('/',bcmp.mailto_cty_nmstct)- 1 < 0 THEN    
          0    
       ELSE CHARINDEX('/',bcmp.mailto_cty_nmstct) -1    
            END),'')    
     END,    
 ivh_billto_zip =     
     CASE rtrim(isnull( bcmp.cmp_mailto_name,''))     
  WHEN '' THEN ISNULL(bcmp.cmp_zip,'')    
  ELSE ISNULL(bcmp.cmp_mailto_zip,'')    
     END,    
  ivh_consignee_name = ccmp.cmp_name,    
  ivh_consignee_nmstct =     
     ISNULL(SUBSTRING(ccmp.cty_nmstct,1,CASE    
       WHEN CHARINDEX('/',ccmp.cty_nmstct)- 1 < 0 THEN    
          0    
       ELSE CHARINDEX('/',ccmp.cty_nmstct) -1    
            END),''),    
    
  ivh_billdate      billdate,    
  bill_quantity = ivd_quantity,    
  IsNull(ivd.ivd_unit, ''),    
  ivd_rate ,    
  ivd_charge ,    
  cmd_name = ord_description,    
  case isnull(ivd_description,'UNKNOWN') when 'UNKNOWN' then  IsNull(cht_description, '')else ivd_description end,   
  ivd_sequence,    
  1,    
   commodity = isnull(ord.ord_description,'UNKNOWN')  
  ,ivh_tractor = case ivh_tractor when 'UNKNOWN' then 'NONE' else ivh_tractor end  
  ,ivh_driver = case ivh_driver when 'UNKNOWN' then 'NONE' else ivh_driver end  
  ,cht.cht_primary 
  ,ivd.cht_itemcode 
  , bol = isnull((select top 1 ref_number from referencenumber 
           where ref_table = (case invoiceheader.ord_hdrnumber when 0 then 'invoiceheader' else 'orderheader' end)
           and ref_tablekey = (case invoiceheader.ord_hdrnumber when 0 then invoiceheader.ivh_hdrnumber else invoiceheader.ord_hdrnumber end)
           and ref_type = 'BL#' order by ivd_sequence),'')
   ,pojob = isnull((select top 1 ref_number from referencenumber 
           where ref_table = (case invoiceheader.ord_hdrnumber when 0 then 'invoiceheader' else 'orderheader' end)
           and ref_tablekey = (case invoiceheader.ord_hdrnumber when 0 then invoiceheader.ivh_hdrnumber else invoiceheader.ord_hdrnumber end)
           and ref_type = 'POJOB' order by ivd_sequence),'')
    From  invoiceheader  
    join company bcmp on  bcmp.cmp_id = invoiceheader.ivh_billto   
    join company scmp on  scmp.cmp_id = invoiceheader.ivh_shipper    
    join company ccmp on  ccmp.cmp_id = invoiceheader.ivh_consignee   
    join invoicedetail ivd on  invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber  
    join chargetype cht on   ivd.cht_itemcode = cht.cht_itemcode  
    left outer join orderheader ord  on invoiceheader.ord_hdrnumber = ord.ord_hdrnumber  
   Where ( invoiceheader.ivh_mbnumber = @p_mbnumber )     
  AND ivd_charge <> 0    
  
    
    
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
  @p_mbnumber ,    
  ivh_shipto_name = scmp.cmp_name,    
   ivh_shipto_nmstct =
     ISNULL(SUBSTRING(scmp.cty_nmstct,1,CASE    
       WHEN CHARINDEX('/',scmp.cty_nmstct)- 1 < 0 THEN    
          0    
       ELSE CHARINDEX('/',scmp.cty_nmstct) -1    
            END),'')    ,    
   ivh_billto_name = 
     CASE rtrim(isnull(bcmp.cmp_mailto_name,''))
     WHEN '' THEN bcmp.cmp_name
     ELSE bcmp.cmp_mailto_name
     END,      
  ivh_billto_address =     
     CASE  rtrim(isnull( bcmp.cmp_mailto_name,''))
     WHEN '' THEN ISNULL(bcmp.cmp_address1,'')    
     ELSE ISNULL(bcmp.cmp_mailto_address1,'')    
     END,    
  ivh_billto_address2 =     
     CASE  rtrim(isnull( bcmp.cmp_mailto_name,''))  
     WHEN '' THEN ISNULL(bcmp.cmp_address2,'')    
     ELSE ISNULL(bcmp.cmp_mailto_address2,'')    
     END,    
  ivh_billto_nmstct =     
     CASE rtrim(isnull( bcmp.cmp_mailto_name,''))    
  WHEN '' THEN     
     ISNULL(SUBSTRING(bcmp.cty_nmstct,1,CASE    
       WHEN CHARINDEX('/',bcmp.cty_nmstct)- 1 < 0 THEN    
          0    
       ELSE CHARINDEX('/',bcmp.cty_nmstct) -1    
            END),'')    
  ELSE ISNULL(SUBSTRING(bcmp.mailto_cty_nmstct,1,CASE    
       WHEN CHARINDEX('/',bcmp.mailto_cty_nmstct)- 1 < 0 THEN    
          0    
       ELSE CHARINDEX('/',bcmp.mailto_cty_nmstct) -1    
            END),'')    
     END,    
 ivh_billto_zip =     
     CASE rtrim(isnull( bcmp.cmp_mailto_name,''))     
  WHEN '' THEN ISNULL(bcmp.cmp_zip,'')    
  ELSE ISNULL(bcmp.cmp_mailto_zip,'')    
     END,    
  ivh_consignee_name = ccmp.cmp_name,    
  ivh_consignee_nmstct =     
     ISNULL(SUBSTRING(ccmp.cty_nmstct,1,CASE    
       WHEN CHARINDEX('/',ccmp.cty_nmstct)- 1 < 0 THEN    
          0    
       ELSE CHARINDEX('/',ccmp.cty_nmstct) -1    
            END),''),    
  @p_billdate      billdate,    
  bill_quantity = ivd_quantity,    
  IsNull(ivd.ivd_unit, ''),    
  ivd_rate,    
  ivd_charge ,    
  cmd_name  = ord_description,    
  case isnull(ivd_description,'UNKNOWN') when 'UNKNOWN' then  IsNull(cht_description, '')else ivd_description end,    
  ivd_sequence,    
  1,    
   commodity = isnull(ord.ord_description,'UNKNOWN')  
  ,ivh_tractor = case ivh_tractor when 'UNKNOWN' then 'NONE' else ivh_tractor end  
  ,ivh_driver = case ivh_driver when 'UNKNOWN' then 'NONE' else ivh_driver end  
  ,cht.cht_primary 
  ,ivd.cht_itemcode 
  , bol = isnull((select top 1 ref_number from referencenumber 
           where ref_table = (case invoiceheader.ord_hdrnumber when 0 then 'invoiceheader' else 'orderheader' end)
           and ref_tablekey = (case invoiceheader.ord_hdrnumber when 0 then invoiceheader.ivh_hdrnumber else invoiceheader.ord_hdrnumber end)
           and ref_type = 'BL#' order by ivd_sequence),'')
   ,pojob = isnull((select top 1 ref_number from referencenumber 
           where ref_table = (case invoiceheader.ord_hdrnumber when 0 then 'invoiceheader' else 'orderheader' end)
           and ref_tablekey = (case invoiceheader.ord_hdrnumber when 0 then invoiceheader.ivh_hdrnumber else invoiceheader.ord_hdrnumber end)
           and ref_type = 'POJOB' order by ivd_sequence),'')
    From  invoiceheader  
    join company bcmp on  bcmp.cmp_id = invoiceheader.ivh_billto   
    join company scmp on  scmp.cmp_id = invoiceheader.ivh_shipper    
    join company ccmp on  ccmp.cmp_id = invoiceheader.ivh_consignee   
    join invoicedetail ivd on  invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber  
    join chargetype cht on   ivd.cht_itemcode = cht.cht_itemcode  
    left outer join orderheader ord  on invoiceheader.ord_hdrnumber = ord.ord_hdrnumber  
 Where  ( invoiceheader.ivh_billto = @p_billto )       
  AND    ( invoiceheader.ivh_shipdate between @p_shipstart AND @p_shipend )     
  AND    ( invoiceheader.ivh_deliverydate between @p_delstart AND @p_delend )     
  AND     (invoiceheader.ivh_mbstatus = 'RTP')      
  AND (@p_revtype1 in (invoiceheader.ivh_revtype1,'UNK'))    
  AND (@p_revtype2 in (invoiceheader.ivh_revtype2,'UNK'))     
  AND (@p_revtype3 in (invoiceheader.ivh_revtype3,'UNK'))    
  AND (@p_revtype4 in (invoiceheader.ivh_revtype4,'UNK'))     
  AND (@p_shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))    
  AND (@p_consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))     
  AND ivd_charge <> 0    
  END    
    
GO
GRANT EXECUTE ON  [dbo].[d_masterbill86_sp] TO [public]
GO
