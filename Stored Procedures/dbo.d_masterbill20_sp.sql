SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
   
    
CREATE PROC [dbo].[d_masterbill20_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8),     
                        @revtype1 varchar(6), @revtype2 varchar(6),@revtype3 varchar(6), @revtype4 varchar(6),@mbstatus varchar(6),    
                        @shipstart datetime,@shipend datetime,@billdate datetime,     
                               @shipper varchar(8), @consignee varchar(8),@ivh_currency varchar(6),    
          @po varchar(20),@product varchar(8),     
     @delstart datetime, @delend datetime,@orderby varchar(8),@copy tinyint,@subcompany varchar(8),  
     @productionyear smallint, @productionmonth tinyint )    
AS  
/**
 * DESCRIPTION:
 *    This format is used by a company that rates by total, only ships by volume to one location.      
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
pts13237 Provide separate formats (19 and 20) each with its own sequence Deliver/pickup and pickup/deliver.    
     allow for 4 tax types. Used for masterbills 19 and 20.    
pts 13822 use tar_tariffitem as the PO#    
PTS14000 DPETE handle being passed NULL for a currency code - default to US (turned in change with PTS 13822)    
dpete 14248 truncate labelfile name for currency to 6 positions, expand copany name, address and zip to current sizes.    
dpete PTS 14878 master bill not printing on document when not a reprint    
07/25/2002 Vern Jewett (label=vmj1) PTS 14924: lengthen ivd_description from 30 to 60    
          chars.    
DPETE 16739 Many enhancements (Use ALL as the wild card on selection) 
GIBSON DEVELOPER 39498 Modified 10/3/07 to add ord_subcompany to return set   
 * 10/26/2007.01 ? PTS40029 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/
  
Select @ivh_currency = isnull(@ivh_currency,'US$')   
If @ivh_currency = ''  Select @ivh_currency = 'US$'  
Declare @int0  int,@row int    
Declare @gstnum varchar(60)    
Declare @tax_amount money,@tax_amount1 money,@tax_amount2 money,@tax_amount3 money,@tax_amount4 money    
Declare @taxname varchar(30),@taxname1 varchar(30),@taxname2 varchar(30),@taxname3 varchar(30),@taxname4 varchar(30)    
Declare @maxseq tinyint    
Select @int0 = 0    
Select @row = 0    
    
Select @po = Rtrim(Ltrim(Isnull(@po,'')))    
Select @shipstart = convert(char(12),@shipstart)+'00:00:00'    
Select @shipend   = convert(char(12),@shipend  )+'23:59:59'    
Select @delstart = convert(char(12),@delstart)+'00:00:00'    
Select @delend   = convert(char(12),@delend  )+'23:59:59'    
Select @subcompany = IsNull(@subcompany,'')    
    
Select @gstnum = gi_string1    
From generalinfo    
Where gi_name = 'GSTNUMBER'    
    
CREATE TABLE #masterbill_tempx (  ord_hdrnumber int,    
  ivh_invoicenumber varchar(12),      
  ivh_hdrnumber int NULL,     
  ivh_billto varchar(8) NULL,    
  ivh_shipper varchar(8) NULL,    
  ivh_consignee varchar(8) NULL,    
  ivh_deliverydate datetime NULL,       
  ivh_revtype1 varchar(6) NULL,    
  ivh_mbnumber int NULL,    
  ivh_shipper_name varchar(100) NULL ,    
  ivh_shipper_nmstct varchar(25) NULL ,    
  ivh_shipper_zip varchar(10) NULL,    
  ivh_billto_name varchar(100)  NULL,    
  ivh_billto_address varchar(50) NULL,    
  ivh_billto_address2 varchar(50) NULL,    
  ivh_billto_nmstct varchar(25) NULL ,    
  ivh_billto_zip varchar(9) NULL,    
  ivh_consignee_name varchar(100)  NULL,    
  ivh_consignee_nmstct varchar(25)  NULL,    
  ivh_consignee_zip varchar(10) NULL,    
  billdate datetime NULL,    
  cmp_mailto_name varchar(100)  NULL,    
  bill_quantity float  NULL,    
  ivd_weight float NULL,    
  ivd_weightunit char(6) NULL,    
  ivd_count float NULL,    
  ivd_countunit char(6) NULL,    
  ivd_volume float NULL,    
  ivd_volunit char(6) NULL,    
  ivd_unit char(6) NULL,    
  ivd_rate money NULL,    
  ivd_rateunit char(6) NULL,    
  ivd_charge money NULL,    
  cht_description varchar(30) NULL,    
  cht_primary char(1) NULL,    
  cmd_name varchar(60)  NULL,    
  --vmj1+    
  ivd_description varchar(60) NULL,    
--  ivd_description varchar(30) NULL,    
  --vmj1-    
  ivd_type char(6) NULL,    
  ivd_sequence int NULL,    
  copy tinyint NULL,    
  billto_geoloc varchar(50)null,    
  consig_geoloc varchar(50) null,    
  shipper_geoloc varchar(50) null,    
  cht_basis  varchar(6) null,    
  taxamount1 money null,    
  taxname1 varchar(30) null,    
  taxamount2 money null,    
  taxname2  varchar(30) null,    
  taxamount3 money null,    
  taxname3  varchar(30) null,    
  taxamount4 money null,    
  taxname4  varchar(30) null,    
  gstnumber varchar(60) null,    
  billto_contact varchar(30) null,         
  actual_vol float null,    
  cht_itemcode varchar(6) null,    
  ivh_currency varchar(6) null,    
  cmp_mbgroup  varchar(20) null,    
  po_number    varchar(20) null,    
  ivh_remark   varchar(254) null,    
  ordrefnumbers varchar(200) null,    
--  Added SR 16739     
  ivh_revtype3 varchar(6) Null,    
  production_date datetime null,    
  cmp_subcompany varchar(8) null)    
    
    
    
-- If printflag is set to REPRINT, retrieve an already printed mb by #    
    
If UPPER(@reprintflag) = 'REPRINT'     
  BEGIN    
    INSERT Into #masterbill_tempx    
    Select  IsNull(invoiceheader.ord_hdrnumber, -1),    
  invoiceheader.ivh_invoicenumber,      
  invoiceheader.ivh_hdrnumber,     
  invoiceheader.ivh_billto,    
  invoiceheader.ivh_shipper,    
  invoiceheader.ivh_consignee,       
  invoiceheader.ivh_deliverydate,       
  invoiceheader.ivh_revtype1,    
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
 ivh_shipto_zip =     
    CASE    
  WHEN cmp2.cmp_mailto_name IS NULL  THEN ISNULL(cmp2.cmp_zip ,'')      
  WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_zip,'')    
  ELSE ISNULL(cmp2.cmp_mailto_zip,'')    
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
 ivh_consignee_zip =     
     CASE    
  WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')      
  WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')    
  ELSE ISNULL(cmp3.cmp_mailto_zip,'')    
     END,    
  ivh_billdate      billdate,    
  ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,    
  ivd.ivd_quantity 'bill_quantity',    
  IsNull(ivd.ivd_wgt, 0),    
  IsNull(ivd.ivd_wgtunit, ''),    
  IsNull(ivd.ivd_count, 0),    
  IsNull(ivd.ivd_countunit, ''),    
  IsNull(ivd.ivd_volume, 0),    
  IsNull(ivd.ivd_volunit, ''),    
  IsNull(ivd.ivd_unit, ''),    
  IsNull(ivd.ivd_rate, 0),    
  IsNull(ivd.ivd_rateunit, ''),    
  isnull(ivd.ivd_charge,0),    
  cht.cht_description,    
  cht.cht_primary,    
  cmd_name = Upper(IsNull(ord_description,'')),    
  IsNull(ivd_description, ''),    
  ivd.ivd_type,    
  ivd_sequence,    
  @copy,    
  RTRIM(IsNull(cmp1.cmp_geoloc,'')),    
  RTRIM(IsNull(cmp3.cmp_geoloc,'')),    
  RTRIM(IsNull(cmp2.cmp_geoloc,'')),    
                cht_basis,    
  0,null,0,null,0,null,0,null,    
  @gstnum,    
  IsNull(cmp1.cmp_contact,''),    
  IsNull((Select Sum(ivd_volume) From invoicedetail d2 Where d2.ivd_type = 'DRP'
    And d2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber),0) ,                 
  ivd.cht_itemcode,    
  Substring(Isnull(lab.name,''),1,6) ivh_currency,    
  cmp1.cmp_mbgroup,    
  isnull(invoiceheader.tar_tariffitem,''),    
  isnull(ivh_remark,'') ,    
  ordrefnumbers = ' ',    
  ivh_revtype3 = Case IsNull(ivh_revtype3,'UNK') When 'UNK' Then '' Else ivh_revtype3 End,    
  production_date = Dateadd(hour,-7,ivh_deliverydate), -- runs 7AM on first to 6:59AM of next first   
  ord_subcompany = IsNull(ord.ord_subcompany,'') 
  --pts40029 outer join conversion   
    From  invoicedetail ivd  LEFT OUTER JOIN  commodity cmd  ON  ivd.cmd_code  = cmd.cmd_code ,
	 company cmp2  RIGHT OUTER JOIN  invoiceheader  ON  cmp2.cmp_id  = invoiceheader.ivh_shipper   
					LEFT OUTER JOIN  company cmp3  ON  cmp3.cmp_id  = invoiceheader.ivh_consignee   
					LEFT OUTER JOIN  orderheader ord  ON  ord.ord_hdrnumber  = invoiceheader.ord_hdrnumber ,
	 company cmp1,
	 chargetype cht,
	 labelfile lab 
   Where ( invoiceheader.ivh_mbnumber = @mbnumber )    
  AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)    
  AND (cmp1.cmp_id = invoiceheader.ivh_billto)     
  AND (ivd.cht_itemcode = cht.cht_itemcode)    
  AND (lab.abbr = @ivh_currency and lab.labeldefinition = 'currencies')    
    
  END    
    
-- for master bills with 'RTP' status    
    
If UPPER(@reprintflag) <> 'REPRINT'     
  BEGIN    
     INSERT Into  #masterbill_tempx    
     Select  IsNull(invoiceheader.ord_hdrnumber, -1),    
  invoiceheader.ivh_invoicenumber,      
  invoiceheader.ivh_hdrnumber,     
  invoiceheader.ivh_billto,    
  invoiceheader.ivh_shipper,    
  invoiceheader.ivh_consignee,       
  invoiceheader.ivh_deliverydate,       
  invoiceheader.ivh_revtype1,    
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
 ivh_shipto_zip =     
    CASE    
  WHEN cmp2.cmp_mailto_name IS NULL  THEN ISNULL(cmp2.cmp_zip ,'')      
  WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_zip,'')    
  ELSE ISNULL(cmp2.cmp_mailto_zip,'')    
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
 ivh_consignee_zip =     
     CASE    
  WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')      
  WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')    
  ELSE ISNULL(cmp3.cmp_mailto_zip,'')    
     END,    
  @billdate      billdate,    
  ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,    
  ivd.ivd_quantity 'bill_quantity',    
  IsNull(ivd.ivd_wgt, 0),    
  IsNull(ivd.ivd_wgtunit, ''),    
  IsNull(ivd.ivd_count, 0),    
  IsNull(ivd.ivd_countunit, ''),    
  IsNull(ivd.ivd_volume, 0),    
  IsNull(ivd.ivd_volunit, ''),    
  IsNull(ivd.ivd_unit, ''),    
  IsNull(ivd.ivd_rate, 0),    
  IsNull(ivd.ivd_rateunit, ''),    
  isnull(ivd.ivd_charge,0),    
  cht.cht_description,    
  cht.cht_primary,    
  cmd_name  = Upper(IsNUll(ord_description,'')),    
  IsNull(ivd_description, ''),    
  ivd.ivd_type,    
  ivd_sequence,    
  @copy,    
  RTRIM(IsNull(cmp1.cmp_geoloc,'')),    
  RTRIM(IsNull(cmp3.cmp_geoloc,'')),    
  RTRIM(IsNull(cmp2.cmp_geoloc,'')),    
                cht_basis,    
  0,null,0,null,0,null,0,null,    
  @gstnum,    
  IsNull(cmp1.cmp_contact,''),    
  IsNull((Select Sum(ivd_volume) From invoicedetail d2 Where d2.ivd_type = 'DRP'
    And d2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber),0) ,        
  ivd.cht_itemcode,    
  Substring(Isnull(lab.name,''),1,6) ivh_currency,    
  cmp1.cmp_mbgroup,    
  isnull(invoiceheader.tar_tariffitem,''),    
  isnull(ivh_remark,'') ,    
  ordrefnumbers = ' ',    
  ivh_revtype3 = Case IsNull(ivh_revtype3,'UNK') When 'UNK' Then '' Else ivh_revtype3 End,    
-- month runs from 7 am on the 1st thru 6:59 AM on the first of the subsequent month    
   production_date = Dateadd(hour,-7,ivh_deliverydate), -- runs 7AM on first to 6:59AM of next first   
  ord_subcompany = IsNull(ord.ord_subcompany,'') 

  --pts40029 outer join conversion 
  FROM invoicedetail ivd  LEFT OUTER JOIN  commodity cmd  ON  ivd.cmd_code  = cmd.cmd_code ,
	 company cmp2  RIGHT OUTER JOIN  invoiceheader  ON  cmp2.cmp_id  = invoiceheader.ivh_shipper   
				LEFT OUTER JOIN  company cmp3  ON  cmp3.cmp_id  = invoiceheader.ivh_consignee ,
	 company cmp1,
	 chargetype cht,
	 orderheader ord,
	 labelfile lab  
 Where  ( invoiceheader.ivh_billto = @billto )      
  AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)    
  AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend )     
  AND    ( invoiceheader.ivh_deliverydate between @delstart AND @delend )     
  AND     (invoiceheader.ivh_mbstatus = 'RTP')    
  AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))      
  AND @revtype1 = invoiceheader.ivh_revtype1   -- From invoice for break, not selection criteria    
  AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK'))     
  AND (@revtype3 in (invoiceheader.ivh_revtype3,'UNK'))    
  AND (@revtype4 in (invoiceheader.ivh_revtype4,'UNK'))     
  AND    (cmp1.cmp_id = invoiceheader.ivh_billto)    
  AND    (ivd.cht_itemcode = cht.cht_itemcode)    
  AND (lab.abbr = @ivh_currency and lab.labeldefinition = 'currencies')    
  AND (@shipper IN(invoiceheader.ivh_shipper,'ALL'))    
  AND (@consignee IN (invoiceheader.ivh_consignee,'ALL'))    
  AND  (IsNull(invoiceheader.ivh_currency,'US$') = @ivh_currency)    
  AND  @po = rtrim(ltrim(isnull(invoiceheader.tar_tariffitem, '')))    
  /* PTS 15749 - DJM- Discovered that MasterBill would miss Miscellaneous    
  invoices. Needs outer join to Orderheader table to avoid problem. */    
  AND (ord.ord_hdrnumber = invoiceheader.ord_hdrnumber)    
  AND  @product in (ord.cmd_code,'ALL')    
  And  @subcompany = ord.ord_subcompany  
  And  @productionmonth = Datepart(month,Dateadd(hour,-7,ivh_deliverydate))   
  And  @productionyear =  datepart(year,Dateadd(hour,-7,ivh_deliverydate))   
    
   
  END    
    
    
    
 Create table #tax_temp (tax_amount money null,cht_description varchar(50) null)    
    
 Insert Into #tax_temp    
  Select        sum(isnull(ivd_charge,0)) tax_amount,IsNull(cht_description,'cht_itemcode') cht_description    
  From          #masterbill_tempx    
  Where         cht_basis = 'tax'or cht_itemcode = 'QST'    
  group by      cht_description,cht_itemcode    
  order by      cht_description     
    
 If (Select Count(*) From #tax_temp ) > 0    
 Begin    
    Declare  tax_cursor CURSOR for    
    Select tax_amount,cht_description From #tax_temp    
    OPEN     tax_cursor    
    
    FETCH NEXT From tax_cursor    
    Into @tax_amount, @taxname    
  Select @row  = 0    
    
    WHILE @@FETCH_STATUS = 0    
     BEGIN    
     Select @row = @row + 1    
     If @row = 1 Select @tax_amount1 = @tax_amount, @taxname1 = @taxname    
   If @row = 2 Select @tax_amount2 = @tax_amount, @taxname2 = @taxname    
   If @row = 3 Select @tax_amount3 = @tax_amount, @taxname3 = @taxname    
   If @row = 4 Select @tax_amount4 = @tax_amount, @taxname4 = @taxname    
    
   FETCH NEXT From tax_cursor    
     Into @tax_amount, @taxname    
     END    
    CLOSE tax_cursor    
    DEALLOCATE tax_cursor    
 End     
    
   Update #masterbill_tempx    
   Set     taxamount1 = iSnULL(@tax_amount1,0),    
         taxname1 = @taxname1,    
     taxamount2 = IsNull(@tax_amount2,0),    
         taxname2 = @taxname2,    
     taxamount3 = IsNull(@tax_amount3,0),    
         taxname3 = @taxname3,    
    taxamount4 = IsNull(@tax_amount4,0),    
         taxname4 = @taxname4    
     
  DELETE From #masterbill_tempx    
  Where  cht_basis = 'TAX' or cht_itemcode = 'QST'    
    
    
Create table #referencenumber (ref_type varchar(6) null, ref_number varchar(30) null,ref_tablekey int,ref_sequence int null)    
    
    
Insert Into #referencenumber     
Select Distinct ref_type, ref_number,ref_tablekey, ref_sequence From referencenumber ,#masterbill_tempx    
Where ref_table = 'orderheader' and     
ref_tablekey = #masterbill_tempx.ord_hdrnumber    
Order by ref_tablekey,ref_sequence    
    
Select @maxseq = Max(ref_sequence) From #referencenumber     
Select @maxseq = IsNull(@maxSeq,0)    
If @maxseq > 0     
Update #masterbill_tempx Set ordrefnumbers = RTRIM(IsNull(ref_type,'')+ ':'+IsNull( ref_number,''))    
 From #referencenumber Where ref_tablekey = #masterbill_tempx.ord_hdrnumber and ref_sequence = 1    
    
    
If @maxseq > 1    
Update #masterbill_tempx Set ordrefnumbers = ordrefnumbers +', '+RTRIM(IsNull(ref_type,'')+ ':'+IsNull( ref_number,''))    
 From #referencenumber Where ref_tablekey = #masterbill_tempx.ord_hdrnumber and ref_sequence = 2    
    
If @maxseq > 2    
Update #masterbill_tempx Set ordrefnumbers = ordrefnumbers +', '+RTRIM(IsNull(ref_type,'')+ ':'+IsNull( ref_number,''))    
 From #referencenumber Where ref_tablekey = #masterbill_tempx.ord_hdrnumber and ref_sequence = 3    
    
If @maxseq > 3    
Update #masterbill_tempx Set ordrefnumbers = ordrefnumbers +', '+RTRIM(IsNull(ref_type,'')+ ':'+IsNull( ref_number,''))    
 From #referencenumber Where  ref_tablekey = #masterbill_tempx.ord_hdrnumber and ref_sequence = 4    
    
If @maxseq > 4    
Update #masterbill_tempx Set ordrefnumbers = ordrefnumbers +', '+RTRIM(IsNull(ref_type,'')+ ':'+IsNull( ref_number,''))    
 From #referencenumber Where ref_tablekey =     
#masterbill_tempx.ord_hdrnumber and ref_sequence = 5    
    
If @maxseq > 5    
Update #masterbill_tempx Set ordrefnumbers = ordrefnumbers +', '+RTRIM(IsNull(ref_type,'')+ ':'+IsNull( ref_number,''))    
 From #referencenumber Where  ref_tablekey =     
#masterbill_tempx.ord_hdrnumber and ref_sequence = 6    
    
If @maxseq > 6    
Update #masterbill_tempx Set ordrefnumbers = ordrefnumbers +', '+RTRIM(IsNull(ref_type,'')+ ':'+IsNull( ref_number,''))    
 From #referencenumber Where  ref_tablekey =     
#masterbill_tempx.ord_hdrnumber and ref_sequence = 7    
    
If @maxseq > 7    
Update #masterbill_tempx Set ordrefnumbers = ordrefnumbers +', '+RTRIM(IsNull(ref_type,'')+ ':'+IsNull( ref_number,''))    
 From #referencenumber Where  ref_tablekey =     
#masterbill_tempx.ord_hdrnumber and ref_sequence = 8    
    
    
If @maxseq > 8    
Update #masterbill_tempx Set ordrefnumbers = ordrefnumbers +', '+RTRIM(IsNull(ref_type,'')+ ':'+IsNull( ref_number,''))    
 From #referencenumber Where  ref_tablekey =     
#masterbill_tempx.ord_hdrnumber and ref_sequence = 9    
    
If @maxseq > 9    
Update #masterbill_tempx Set ordrefnumbers = ordrefnumbers +', '+RTRIM(IsNull(ref_type,'')+ ':'+IsNull( ref_number,''))    
 From #referencenumber Where  ref_tablekey =     
#masterbill_tempx.ord_hdrnumber and ref_sequence = 10    
    
--PTS# 18910 ILB 06/26/2003
--Update the rows which have a ivd_type = 'LI' and set the actual_vol = NULL
--this will correct the issue of actual volume being calculated incorrectly
Update #masterbill_tempx
   set actual_vol = null
  where ivd_type = 'LI'
--PTS# 18910 ILB 06/26/2003


--Gibson Energy 09/21/07
--Get the appropriate GST number for the company associated with the orders
 update #masterbill_tempx
    set gstnumber = l.label_extrastring1
   from labelfile l,
        orderheader o,
        invoiceheader i
  where i.ivh_hdrnumber = #masterbill_tempx.ivh_hdrnumber
    and o.ord_hdrnumber = i.ord_hdrnumber
    and l.labeldefinition = 'company'
    and l.abbr = o.ord_subcompany


 Select *     
 From  #masterbill_tempx    
 Where         ivd_charge <> 0     
 --ORDER BY ivh_shipdate,ord_hdrnumber    
    
 Drop Table #masterbill_tempx    
 Drop Table #referencenumber    
 Drop Table #tax_temp 
GO
GRANT EXECUTE ON  [dbo].[d_masterbill20_sp] TO [public]
GO
