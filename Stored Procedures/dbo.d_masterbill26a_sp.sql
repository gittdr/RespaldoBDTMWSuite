SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill26a_sp] (@reprintflag varchar(10),@mbnumber int, @billto varchar(8),@shipper varchar(8),@consignee varchar(8),   
         @orderedby varchar(8),@shipstart datetime, @shipend datetime,@deldatestart datetime, @deldateend datetime,   
                        @revtype1 varchar(6), @revtype2 varchar(6), @revtype3 varchar(6), @revtype4 varchar(6), @mbstatus varchar(6),  
                        @paperworkstatus varchar(6),@billdate datetime,@copy int)  
--(@reprintflag varchar(10),@mbnumber int,@billto varchar(8),   
-- @revtype1 varchar(6), @mbstatus varchar(6),  
-- @shipstart datetime,@shipend datetime,@billdate datetime,@copy int)  
   
AS  
/**
 * DESCRIPTION:
 * Created to allow reprinting of masterbills 
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
-- Jyang pts14148 copy the store proc from d_masterbill10_sp 
--DPETE PTS 17437  
 * 10/30/2007.01 ? PTS40029 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @int0  int  
SELECT @int0 = 0  
  
--SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'  
--SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'  
  
  
CREATE TABLE #masterbill_temp  
 (ord_number varchar(12) NULL,  
 ord_hdrnumber int,  
 ivh_invoicenumber varchar(12) NULL ,    
 ivh_hdrnumber int NULL,   
 ivh_billto varchar(8) NULL,     
        ivh_totalcharge money NULL,     
        ivh_originpoint varchar(8) NULL,    
        ivh_destpoint varchar(8) NULL,     
        ivh_origincity int NULL,     
        ivh_destcity int NULL,     
        ivh_shipdate datetime NULL,     
        ivh_deliverydate datetime NULL,     
        ivh_revtype1 varchar(6) NULL,  
 ivh_mbnumber int NULL,  
 shipper_name varchar(30) NULL,  
 shipper_addr varchar(40) NULL,  
 shipper_addr2 varchar(40) NULL,  
 shipper_nmstct varchar(25) NULL,  
 shipper_zip varchar(10) NULL,  
 ivh_billto_name varchar(30) NULL,  
 ivh_billto_address varchar(40) NULL,  
 ivh_billto_address2 varchar(40) NULL,  
 ivh_billto_nmstct varchar(25) NULL,  
 ivh_billto_zip varchar(10) NULL,  
 dest_nmstct varchar(25) NULL,  
 dest_state char(2) NULL,  
 billdate datetime NULL,  
 shipticket varchar(30) NULL,  
 cmp_mailto_name varchar(30) NULL,  
 ivd_wgt float NULL,  
 ivd_wgtunit char(6) NULL,  
 ivd_count float NULL,  
 ivd_countunit char(6) NULL,  
 ivd_volume float NULL,  
 ivd_volunit char(6) NULL,  
 ivd_quantity float NULL,  
 ivd_unit varchar(6) NULL,  
 ivd_rate money NULL,  
 ivd_rateunit varchar(6) NULL,  
 ivd_charge money NULL,  
 ivd_volume2 float NULL,  
 stp_nmstct varchar(25) NULL,  
 stp_city int NULL,  
 cmd_name varchar(60) NULL,  
 tar_tarriff_number varchar(12) NULL,  
 cmp_altid varchar(25) NULL,  
 copy int NULL,  
 cht_primary char(1) NULL,  
 cht_description varchar(60) NULL,  
 ivd_sequence int NULL,   
        ivd_refnum varchar(30) NULL,  
-- PTS 17132 -- BL  
-- tar_description varchar (50) NULL)  
-- PTS 17294 -- BL  
 ivd_description varchar (60) NULL,
tar_number int null,
cht_itemcode	char(6) NULL)  
  
    
  
-- if printflag is set to REPRINT, retrieve an already printed mb by #  
if UPPER(@reprintflag) = 'REPRINT'   
  BEGIN  
  
    INSERT INTO #masterbill_temp  
  
    SELECT oh.ord_number,  
  invoiceheader.ord_hdrnumber,  
 invoiceheader.ivh_invoicenumber,    
 invoiceheader.ivh_hdrnumber,   
        invoiceheader.ivh_billto,     
        invoiceheader.ivh_totalcharge,     
        invoiceheader.ivh_originpoint,    
        invoiceheader.ivh_destpoint,     
        invoiceheader.ivh_origincity,     
        invoiceheader.ivh_destcity,     
        invoiceheader.ivh_shipdate,     
        invoiceheader.ivh_deliverydate,     
        invoiceheader.ivh_revtype1,  
 invoiceheader.ivh_mbnumber,  
 shipper_name = cmp3.cmp_name,  
-- dpete for LOR pts4785 provide for maitlto override of billto  
 shipper_address =   
    CASE  
  WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address1,'')  
  WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address1,'')  
  ELSE ISNULL(cmp3.cmp_mailto_address1,'')  
     END,  
 shipper_address2 =   
     CASE  
  WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address2,'')  
  WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address2,'')  
  ELSE ISNULL(cmp3.cmp_mailto_address2,'')  
     END,  
 shipper_nmstct =   
     CASE  
  WHEN cmp3.cmp_id = 'UNKNOWN' THEN  
       'UNKNOWN'  
  WHEN cmp3.cmp_mailto_name IS NULL THEN   
     ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')  
  WHEN (cmp3.cmp_mailto_name <= ' ') THEN   
     ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')  
  ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,(CHARINDEX('/',cmp3.mailto_cty_nmstct)) - 1),'')  
     END,  
 shipper_zip =   
     CASE  
  WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')    
  WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')  
  ELSE ISNULL(cmp3.cmp_mailto_zip,'')  
     END,  
 billto_name = cmp1.cmp_name,  
-- dpete for LOR pts4785 provide for maitlto override of billto  
 billto_address =   
    CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')  
  ELSE ISNULL(cmp1.cmp_mailto_address1,'')  
     END,  
 billto_address2 =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')  
  ELSE ISNULL(cmp1.cmp_mailto_address2,'')  
     END,  
 billto_nmstct =   
     CASE  
  WHEN cmp1.cmp_id = 'UNKNOWN' THEN  
       'UNKNOWN'  
  WHEN cmp1.cmp_mailto_name IS NULL THEN   
     ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN   
     ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')  
  ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')  
     END,  
 billto_zip =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')    
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')  
  ELSE ISNULL(cmp1.cmp_mailto_zip,'')  
     END,  
 '',    -- not used on format   cty2.cty_nmstct   dest_nmstct,  
 '',    -- no used on format     cty2.cty_state  dest_state,  
 ivh_billdate      billdate,  
 '',  
 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,  
 IsNull(ivd.ivd_wgt, 0),  
 IsNull(ivd.ivd_wgtunit, ''),  
 IsNull(ivd.ivd_count, 0),  
 IsNull(ivd.ivd_countunit, ''),  
 IsNull(ivd.ivd_volume, 0),  
 IsNull(ivd.ivd_volunit, ''),  
 IsNull(ivd.ivd_quantity, 0),  
 IsNull(ivd.ivd_unit, ''),  
 IsNull(ivd.ivd_rate, 0),  
 IsNull(ivd.ivd_rateunit, ''),  
 IsNull(ivd.ivd_charge, 0),  
 IsNull(ivd.ivd_volume, 0),  
 '',  
 0,     -- was stp_city not used, remove stops from join  
 '',    -- was cmd.cmd_name  not used, remove join to commodity cmd dpete,  
 invoiceheader.tar_tarriffnumber,  
 cmp1.cmp_altid,  
 @copy,  
 cht.cht_primary,  
 cht.cht_description,  
 ivd.ivd_sequence,   
        ivd.ivd_refnum,   
-- PTS 17132 -- BL  
-- tar.tar_description   
-- PTS 17294 -- BL  
 ivd.ivd_description  ,
ivd.tar_number tar_number,
ivd.cht_itemcode cht_itemcode
    FROM invoiceheader  LEFT OUTER JOIN  orderheader oh  ON  invoiceheader.ord_hdrnumber  = oh.ord_hdrnumber , 
	company cmp1,  -- never used city cty1, city cty2,   
    invoicedetail ivd,    company cmp3, chargetype cht  
	-- PTS 17294 -- BL  
	-- (comment out 'PTS 17132' lines)  
	-- PTS 17132 -- BL  
	-- tariffheader tar  
   WHERE ( invoiceheader.ivh_mbnumber = @mbnumber )   
	 AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)  
	 --AND (ivd.stp_number *= stops.stp_number)  
	 --AND (ivd.cmd_code *= cmd.cmd_code)  
	 AND (ivd.cht_itemcode = cht.cht_itemcode)  
	 AND (cmp1.cmp_id = invoiceheader.ivh_billto)   
	 AND (cmp3.cmp_id = invoiceheader.ivh_shipper)  
	 -- never used AND (cty1.cty_code = invoiceheader.ivh_origincity)   
	 -- never used AND (cty2.cty_code = invoiceheader.ivh_destcity)  
	 -- handled when mb created ..  AND (ivd.ivd_volume > 0 OR ivd_quantity > 0)  
	 AND ivd_charge <> 0  
	-- PTS 17294 -- BL  
	-- (comment out 'PTS 17132' and 'PTS 17285' lines)  
	-- PTS 17132 -- BL  
	-- AND ivd.tar_number = tar.tar_number   
	-- PTS 17285 -- BL  
	--    (make the join an OUTER join)  
	-- AND ivd.tar_number *= tar.tar_number   
   
  END  
  
-- for master bills with 'RTP' status  
  
IF UPPER(@reprintflag) <> 'REPRINT'   
  BEGIN  
  
     INSERT INTO #masterbill_temp  
  
    SELECT oh.ord_number,  
 invoiceheader.ord_hdrnumber,  
 invoiceheader.ivh_invoicenumber,    
 invoiceheader.ivh_hdrnumber,   
        invoiceheader.ivh_billto,     
        invoiceheader.ivh_totalcharge,     
        invoiceheader.ivh_originpoint,    
        invoiceheader.ivh_destpoint,     
        invoiceheader.ivh_origincity,     
        invoiceheader.ivh_destcity,     
        invoiceheader.ivh_shipdate,     
        invoiceheader.ivh_deliverydate,     
        invoiceheader.ivh_revtype1,  
-- JET - 1/28/00 - PTS #7169, this was not returning a mb number  
-- invoiceheader.ivh_mbnumber,  
        @mbnumber ivh_mbnumber,   
 shipper_name = cmp3.cmp_name,  
-- dpete for LOR pts4785 provide for maitlto override of billto  
 shipper_address =   
    CASE  
  WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address1,'')  
  WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address1,'')  
  ELSE ISNULL(cmp3.cmp_mailto_address1,'')  
     END,  
 shipper_address2 =   
     CASE  
  WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address2,'')  
  WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address2,'')  
  ELSE ISNULL(cmp3.cmp_mailto_address2,'')  
     END,  
 shipper_nmstct =   
     CASE  
  WHEN cmp3.cmp_id = 'UNKNOWN' THEN  
       'UNKNOWN'  
  WHEN cmp3.cmp_mailto_name IS NULL THEN   
     ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')  
  WHEN (cmp3.cmp_mailto_name <= ' ') THEN   
     ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')  
  ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,(CHARINDEX('/',cmp3.mailto_cty_nmstct)) - 1),'')  
     END,  
 shipper_zip =   
     CASE  
  WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')    
  WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')  
  ELSE ISNULL(cmp3.cmp_mailto_zip,'')  
     END,  
 billto_name = cmp1.cmp_name,  
-- dpete for LOR pts4785 provide for maitlto override of billto  
 billto_address =   
    CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')  
  ELSE ISNULL(cmp1.cmp_mailto_address1,'')  
     END,  
 billto_address2 =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')  
  ELSE ISNULL(cmp1.cmp_mailto_address2,'')  
     END,  
 billto_nmstct =   
     CASE  
  WHEN cmp1.cmp_id = 'UNKNOWN' THEN  
       'UNKNOWN'  
  WHEN cmp1.cmp_mailto_name IS NULL THEN   
     ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN   
     ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')  
  ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')  
     END,  
 billto_zip =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')    
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')  
  ELSE ISNULL(cmp1.cmp_mailto_zip,'')  
     END,  
 '',  -- not used on format   cty2.cty_nmstct   dest_nmstct,  
 '', -- not used on format   cty2.cty_state  dest_state,  
 ivh_billdate      billdate,  
 '',  
 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,  
 IsNull(ivd.ivd_wgt, 0),  
 IsNull(ivd.ivd_wgtunit, ''),  
 IsNull(ivd.ivd_count, 0),  
 IsNull(ivd.ivd_countunit, ''),  
 IsNull(ivd.ivd_volume, 0),  
 IsNull(ivd.ivd_volunit, ''),  
 IsNull(ivd.ivd_quantity, 0),  
 IsNull(ivd.ivd_unit, ''),  
 IsNull(ivd.ivd_rate, 0),  
 IsNull(ivd.ivd_rateunit, ''),  
 IsNull(ivd.ivd_charge, 0),  
 IsNull(ivd.ivd_volume, 0),  
 '',  
 0,   -- stp_city,  not needed for format, remove join to stops  
 '',   -- cmd.cmd_name, not used for format, remove commodity cmd from join   
 invoiceheader.tar_tarriffnumber,  
 IsNull(cmp1.cmp_altid, ''),  
 @copy,  
 cht.cht_primary,  
 cht.cht_description,  
 ivd.ivd_sequence,   
        ivd.ivd_refnum,   
-- PTS 17132 -- BL  
-- tar.tar_description   
-- PTS 17294 -- BL  
 ivd.ivd_description ,
ivd.tar_number tar_number,
ivd.cht_itemcode cht_itemcode   
    FROM invoiceheader  LEFT OUTER JOIN  orderheader oh  ON  invoiceheader.ord_hdrnumber  = oh.ord_hdrnumber   LEFT OUTER JOIN  company cmp3  ON  cmp3.cmp_id  = invoiceheader.ivh_shipper, 
  company cmp1,   -- never used city cty1, city cty2,  
  invoicedetail ivd, 
  chargetype cht   -- commodity cmd, stops  
-- PTS 17294 -- BL  
-- (comment out 'PTS 17132' lines)  
-- PTS 17132 -- BL  
-- tariffheader tar  
   WHERE ( invoiceheader.ivh_billto = @billto )    
     AND    (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)  
     --AND (ivd.stp_number *= stops.stp_number)  
     --AND (ivd.cmd_code *= cmd.cmd_code)  
     AND (ivd.cht_itemcode = cht.cht_itemcode)  
     AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend )   
     AND    (invoiceheader.ivh_mbstatus = 'RTP')   
     AND    (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))   
     AND    (cmp1.cmp_id = invoiceheader.ivh_billto)  
-- never used     AND    (cty1.cty_code = invoiceheader.ivh_origincity)   
-- never used     AND    (cty2.cty_code = invoiceheader.ivh_destcity)  
-- this just seems wrong and dangerous      AND    (ISNULL(ivd.ivd_volume,0) > 0 OR ISNULL(ivd_quantity,0) > 0)  
	 AND ivd_charge <> 0  
	 AND  ( @Consignee in ( 'UNKNOWN' , invoiceheader.ivh_consignee ) )   
	 AND  ( @OrderedBy in ( 'UNKNOWN' , invoiceheader.ivh_order_by ) )    
	 AND  ( invoiceheader.ivh_deliverydate between @DelDatestart and @DelDateend )   
	 AND  ( @Revtype2 in ( 'UNK' , invoiceheader.ivh_revtype2 ) )   
	 AND  ( @Revtype3 in ( 'UNK' , invoiceheader.ivh_revtype3 ) )    
	 AND  ( @Revtype4 in ( 'UNK' , invoiceheader.ivh_revtype4 ) )   
	 AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus ))  
-- PTS 17294 -- BL  
-- (comment out 'PTS 17132' and 'PTS 17285' lines)  
-- PTS 17132 -- BL  
-- AND ivd.tar_number = tar.tar_number   
-- PTS 17285 -- BL  
--    (make the join an OUTER join)  
-- AND ivd.tar_number *= tar.tar_number   
  END  
  
/*UPDATE #masterbill_temp set shipticket = (SELECT  IsNull(MIN(ref_number), '')  
      FROM  referencenumber ref  
      WHERE  ref.ref_table = 'orderheader' AND  
       ref.ref_tablekey = #masterbill_temp.ord_hdrnumber AND  
       ref.ref_type = 'SHIPTK')*/  
UPDATE   #masterbill_temp   
SET  #masterbill_temp.stp_nmstct = city.cty_nmstct  
FROM  #masterbill_temp, city   
WHERE  #masterbill_temp.stp_city = city.cty_code  

--JLB PTS 23462  First Fleet wants charge typee description to print on Minimum lines instead of the ivd_description
--which is the chargetype description of the line the minimum applies to.
/*
--Provide override for pre rated line item charge problem in VisDIsp (does not apply desc)
Update   #masterbill_temp
Set ivd_description = tar.ivd_description
From tariffheader tar
Where #masterbill_temp.ivd_description = 'UNKNOWN'
And IsNull(#masterbill_temp.tar_number,0) > 0
And tar.tar_number = #masterbill_temp.tar_number
And Rtrim(IsNull(tar.ivd_description,'')) > ''
*/
Update   #masterbill_temp
   Set ivd_description = tar.ivd_description
  From tariffheader tar
 Where (#masterbill_temp.ivd_description = 'UNKNOWN' AND
        IsNull(#masterbill_temp.tar_number,0) > 0 AND
        tar.tar_number = #masterbill_temp.tar_number AND
        Rtrim(IsNull(tar.ivd_description,'')) > ''
       )
    OR (#masterbill_temp.cht_itemcode in ('MIN','MINACC') AND
        IsNull(#masterbill_temp.tar_number,0) > 0 AND
        tar.tar_number = #masterbill_temp.tar_number AND
        Rtrim(IsNull(tar.ivd_description,'')) > ''
       )
--end 23462
  
SELECT * from #masterbill_temp  
ORDER by ivh_invoicenumber,  ivd_sequence  
DROP TABLE #masterbill_temp  
  
GO
GRANT EXECUTE ON  [dbo].[d_masterbill26a_sp] TO [public]
GO
