SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/*
  Created to allow reprinting of masterbills
BDH 4/25/08 PTS 42592.  Removed TSQL outer joins.
PMILL 12/11/2008 adapted from master bill 108
DPETE PTS 47378 if cmp_mailto name is balnk or empty string it brings back mailto info
*/
  



create PROC [dbo].[d_masterbill131_sp] 
		(@reprintflag varchar(10)
		,@mbnumber int
		,@billto varchar(8)
		,@revtype1 varchar(6)
		,@mbstatus varchar(6)
		,@shipstart datetime
		,@shipend datetime	
		,@billdate datetime
		,@revtype2	varchar(6)
		,@revtype3	varchar(6)
		,@revtype4	varchar(6)
		--44805 add move number, shipper and consignee
		,@shipper varchar(8)
		,@consignee varchar(8)
		,@mov_number int
		)
AS

SET NOCOUNT ON

DECLARE @int0  int
SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'
  
DECLARE @ref_number varchar(17)

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN

    SELECT invoiceheader.ivh_invoicenumber,  
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
	 invoiceheader.ord_hdrnumber,
	-- billto_name = CASE WHEN cmp1.cmp_mailto_name IS NULL THEN UPPER(cmp1.cmp_name) ELSE UPPER(cmp1.cmp_mailto_name) END,
     billto_name = CASE rtrim(isnull(cmp1.cmp_mailto_name,'')) WHEN '' THEN UPPER(cmp1.cmp_name) ELSE UPPER(cmp1.cmp_mailto_name) END,
	 billto_address = 
     CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
        WHEN '' then ISNULL(cmp1.cmp_address1,'')
        ELSE cmp1.cmp_mailto_address1
        END,
/*
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
*/

	 billto_address2 = 
     CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
        WHEN '' then ISNULL(cmp1.cmp_address2,'')
        ELSE cmp1.cmp_mailto_address2
        END,
/*
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
*/
	billto_address3 = 
     CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
        WHEN '' then ISNULL(cmp1.cmp_address3,'')
        ELSE ''
        END,
/*
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address3,'')
	    END,
*/	
	 billto_nmstct = 
     CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
        WHEN '' then ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct+'/'))- 1),'')
        ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CHARINDEX('/',cmp1.mailto_cty_nmstct+'/') -1),'')
        END,
/*
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,
				CASE
						WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
				END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,
				CASE
						WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) -1
				END),'')
	    END,
*/
	billto_zip = 
	    CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
        WHEN '' then ISNULL(cmp1.cmp_zip ,'')  
        ELSE ISNULL(cmp1.cmp_mailto_zip,'')
        END,
/*
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
*/
	 cty1.cty_nmstct   origin_nmstct,
	 cty1.cty_state		origin_state,
	 cty2.cty_nmstct   dest_nmstct,
	 cty2.cty_state		dest_state,
	 ivh_billdate      billdate,
	 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	  cmp1.cmp_altid  billto_altid ,
	  ivd.ivd_description,
	  cmp2.cmp_name shipper,
	  shipper_address = ISNULL(cmp2.cmp_address1,''),
	  shipper_address2 = ISNULL(cmp2.cmp_address2,''),
	  shipper_address3 = ISNULL(cmp2.cmp_address3,''),
      shipper_nmstct = ISNULL(SUBSTRING(cmp2.cty_nmstct,1,
				CASE
						WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
				END),'') ,
	  shipper_zip = cmp2.cmp_zip,
	  cmp3.cmp_name consignee,
	  consignee_address = ISNULL(cmp3.cmp_address1, ''),
	  consignee_address2 = ISNULL(cmp3.cmp_address2, ''),
	  consignee_address3 = ISNULL(cmp3.cmp_address3, ''),
	  consignee_nmstct = ISNULL(SUBSTRING(cmp3.cty_nmstct,1,
				CASE
						WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
				END),'') ,
	  consignee_zip = cmp3.cmp_zip,
	  ivh_tractor,
	  ivh_driver,
	  invoiceheader.mov_number,
	  chg.cht_itemcode,
	  chg.cht_description,
	  chg.cht_basis,
	  ivd_charge,
	  @ref_number vin_number,
	  @ref_number bol_number,
	  ivh_rateby,
	  ord_description

into #Temp
    FROM 
	invoiceheader LEFT OUTER JOIN orderheader on orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber, 
	company cmp1, 
	company cmp2,
	company cmp3,
	city cty1, 
	city cty2, 
	invoicedetail ivd LEFT OUTER JOIN chargetype chg on chg.cht_itemcode = ivd.cht_itemcode
   WHERE 
	( invoiceheader.ivh_mbnumber = @mbnumber ) 
	AND (cmp1.cmp_id = invoiceheader.ivh_billto) 
	AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
	AND (cmp3.cmp_id = invoiceheader.ivh_consignee)
	AND (cty1.cty_code = invoiceheader.ivh_origincity) 
	AND (cty2.cty_code = invoiceheader.ivh_destcity)
	AND (ivd.ivh_hdrnumber = invoiceheader.ivh_hdrnumber)
--44805	  AND (ivd.cht_itemcode = 'DEL') 

	--VIN#
	UPDATE #Temp	
	SET vin_number = left(ref_number,17)
	FROM #Temp t INNER JOIN referencenumber r ON
		r.ref_tablekey = t.ord_hdrnumber
	AND r.ref_table = 'orderheader'
	AND r.ref_type = 'VIN'
	
	--BOL ID  44798
	UPDATE #Temp
	SET bol_number = left(ref_number,17)
	FROM #Temp t INNER JOIN referencenumber r ON
		r.ref_tablekey = t.ord_hdrnumber
	AND r.ref_table = 'orderheader'
	AND r.ref_type = 'BLID'

Select * from #Temp	
where ivd_charge <>0			
order by ivh_invoicenumber, cht_basis DESC, cht_itemcode 		
 

  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN

    SELECT invoiceheader.ivh_invoicenumber,  
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
	 @mbnumber     ivh_mbnumber,
	    invoiceheader.ord_hdrnumber,
	-- billto_name = CASE WHEN cmp1.cmp_mailto_name IS NULL THEN UPPER(cmp1.cmp_name) ELSE UPPER(cmp1.cmp_mailto_name) END,
     billto_name = CASE rtrim(isnull(cmp1.cmp_mailto_name,'')) WHEN '' THEN UPPER(cmp1.cmp_name) ELSE UPPER(cmp1.cmp_mailto_name) END,
	 billto_address = 
     CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
        WHEN '' then ISNULL(cmp1.cmp_address1,'')
        ELSE cmp1.cmp_mailto_address1
        END,
/*
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
*/

	 billto_address2 = 
     CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
        WHEN '' then ISNULL(cmp1.cmp_address2,'')
        ELSE cmp1.cmp_mailto_address2
        END,
/*
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
*/
	billto_address3 = 
     CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
        WHEN '' then ISNULL(cmp1.cmp_address3,'')
        ELSE ''
        END,
/*
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address3,'')
	    END,
*/	
	 billto_nmstct = 
     CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
        WHEN '' then ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct+'/'))- 1),'')
        ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CHARINDEX('/',cmp1.mailto_cty_nmstct+'/') -1),'')
        END,
/*
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,
				CASE
						WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
				END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,
				CASE
						WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) -1
				END),'')
	    END,
*/
	billto_zip = 
	    CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
        WHEN '' then ISNULL(cmp1.cmp_zip ,'')  
        ELSE ISNULL(cmp1.cmp_mailto_zip,'')
        END,
/*
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
*/
	 cty1.cty_nmstct   origin_nmstct,
	 cty1.cty_state		origin_state,
	 cty2.cty_nmstct   dest_nmstct,
	 cty2.cty_state		dest_state,
	 @billdate	billdate,
	 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	 cmp1.cmp_altid  billto_altid,
	 ivd.ivd_description,
	  cmp2.cmp_name shipper,
	  shipper_address = ISNULL(cmp2.cmp_address1,''),
	  shipper_address2 = ISNULL(cmp2.cmp_address2,''),
	  shipper_address3 = ISNULL(cmp2.cmp_address3,''),
      shipper_nmstct = ISNULL(SUBSTRING(cmp2.cty_nmstct,1,
				CASE
						WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
				END),'') ,
	  shipper_zip = cmp2.cmp_zip,
	  cmp3.cmp_name consignee,
	  consignee_address = ISNULL(cmp3.cmp_address1, ''),
	  consignee_address2 = ISNULL(cmp3.cmp_address2, ''),
	  consignee_address3 = ISNULL(cmp3.cmp_address3, ''),
	  consignee_nmstct = ISNULL(SUBSTRING(cmp3.cty_nmstct,1,
				CASE
						WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
				END),'') ,
	  consignee_zip = cmp3.cmp_zip,
	  ivh_tractor,
	  ivh_driver,
	  invoiceheader.mov_number,
	  chg.cht_itemcode,
	  chg.cht_description,
	  chg.cht_basis,
	  ivd_charge,
	  @ref_number vin_number,
	  @ref_number bol_number,
	  ivh_rateby, 
	  ord_description

	into #temp2
    FROM 
	invoiceheader LEFT OUTER JOIN orderheader on orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber,
	company cmp1, 
	company cmp2,
	company cmp3,
	city cty1, 
	city cty2, 
	invoicedetail ivd LEFT OUTER JOIN chargetype chg on chg.cht_itemcode = ivd.cht_itemcode
   	WHERE ( invoiceheader.ivh_billto = @billto )  
     AND    ( invoiceheader.ivh_mbnumber is NULL  OR  
            invoiceheader.ivh_mbnumber = 0   ) 
     AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
     AND     (invoiceheader.ivh_mbstatus = 'RTP')  
     AND    (@revtype1 in (invoiceheader.ivh_revtype1,'UNK')) 
     AND    (cmp1.cmp_id = invoiceheader.ivh_billto)
	 AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
	 AND (cmp3.cmp_id = invoiceheader.ivh_consignee)
     AND    (cty1.cty_code = invoiceheader.ivh_origincity) 
     AND    (cty2.cty_code = invoiceheader.ivh_destcity)
	AND (ivd.ivh_hdrnumber = invoiceheader.ivh_hdrnumber)
--44805	  AND (ivd.cht_itemcode = 'DEL')

	 and	@revtype2 in (invoiceheader.ivh_revtype2, 'UNK')
	 and	@revtype3 in (invoiceheader.ivh_revtype3, 'UNK')
	 and	@revtype4 in (invoiceheader.ivh_revtype4, 'UNK')

	AND (ivh_shipper = @shipper)       --44805
	AND (ivh_consignee = @consignee)  --44805
	AND (invoiceheader.mov_number = @mov_number)  --44805


	--VIN#
	UPDATE #Temp2	
	SET vin_number = left(ref_number,17)
	FROM #Temp2 t INNER JOIN referencenumber r ON
		r.ref_tablekey = t.ord_hdrnumber
	AND r.ref_table = 'orderheader'
	AND r.ref_type = 'VIN'
	
	--BOL ID  44798
	UPDATE #Temp2
	SET bol_number = left(ref_number,17)
	FROM #Temp2 t INNER JOIN referencenumber r ON
		r.ref_tablekey = t.ord_hdrnumber
	AND r.ref_table = 'orderheader'
	AND r.ref_type = 'BLID'


	Select * from #Temp2	
	where ivd_charge <>0	
	order by ivh_invoicenumber, cht_basis DESC, cht_itemcode 		

END
GO
GRANT EXECUTE ON  [dbo].[d_masterbill131_sp] TO [public]
GO
