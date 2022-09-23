SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/*
  pts37969 DPETE 6/18/07 Based on MB48 which is based on MB24. 
*/

CREATE PROC [dbo].[d_masterbill99_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                       @revtype1 varchar(6), @mbstatus varchar(6),@shipstart datetime,
                               @shipend datetime,@billdate datetime )
AS

DECLARE @int0  int
SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'
  


-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN

    SELECT invoiceheader.ivh_invoicenumber,  
	   invoiceheader.ivh_hdrnumber, 
           invoiceheader.ivh_billto,   
           isnull((select round(sum (isnull(ivd_charge,0.0)),2) 
             from invoicedetail id 
             where id.ivh_hdrnumber = invoiceheader.ivh_hdrnumber),0.0) ivh_totalcharge,   
           invoiceheader.ivh_originpoint,  
           invoiceheader.ivh_destpoint,   
           invoiceheader.ivh_origincity,   
           invoiceheader.ivh_destcity,   
           invoiceheader.ivh_shipdate,   
           invoiceheader.ivh_deliverydate,   
           invoiceheader.ivh_revtype1,
	   invoiceheader.ivh_mbnumber,
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
		WHEN cmp1.cmp_mailto_name IS NULL THEN
           case  CHARINDEX('/',cmp1.cty_nmstct) 
              when 0 then cmp1.cty_nmstct
		      else ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
              end
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
           case  CHARINDEX('/',cmp1.cty_nmstct) 
              when 0 then cmp1.cty_nmstct
		      else ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
              end
		ELSE 
           case  CHARINDEX('/',cmp1.mailto_cty_nmstct) 
              when 0 then cmp1.mailto_cty_nmstct
		      else ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct))- 1),'')
              end
	    END,
	   billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
	   cty1.cty_nmstct   origin_nmstct,
	   cty1.cty_state		origin_state,
	   cty2.cty_nmstct   dest_nmstct,
	   cty2.cty_state		dest_state,
	   ivh_billdate      billdate,
	
	   ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	   cmp1.cmp_altid  billto_altid ,	   
	   cmp2.cmp_name   shipper_name,
	   cmp3.cmp_name   consignee_name,
       isnull((select sum (isnull(ivd_charge,0.0) )
             from invoicedetail id 
             where id.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and cht_itemcode = 'GST'),0.0) GSTCharge 
       ,ivh_currency
       ,invoiceheader.ord_hdrnumber ord_hdrnumber
    FROM 
	invoiceheader, 
	company cmp1, 
	city cty1, 
	city cty2, 
	company cmp2,
	company cmp3
   WHERE 
	(invoiceheader.ivh_mbnumber = @mbnumber ) 
	AND(cmp1.cmp_id = invoiceheader.ivh_billto) 
	AND(cty1.cty_code = invoiceheader.ivh_origincity) 
	AND(cty2.cty_code = invoiceheader.ivh_destcity)
	AND(cmp2.cmp_id = invoiceheader.ivh_showshipper) 
	AND(cmp3.cmp_id = invoiceheader.ivh_showcons) 
		

 

  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN

     SELECT invoiceheader.ivh_invoicenumber,  
	    invoiceheader.ivh_hdrnumber, 
            invoiceheader.ivh_billto,   
            isnull((select round(sum (isnull(ivd_charge,0.0)),2) 
             from invoicedetail id 
             where id.ivh_hdrnumber = invoiceheader.ivh_hdrnumber),0.0) ivh_totalcharge,   
            invoiceheader.ivh_originpoint,  
            invoiceheader.ivh_destpoint,   
            invoiceheader.ivh_origincity,   
            invoiceheader.ivh_destcity,   
            invoiceheader.ivh_shipdate,   
            invoiceheader.ivh_deliverydate,   
            invoiceheader.ivh_revtype1,
	    @mbnumber     ivh_mbnumber,
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
		WHEN cmp1.cmp_mailto_name IS NULL THEN
           case  CHARINDEX('/',cmp1.cty_nmstct) 
              when 0 then cmp1.cty_nmstct
		      else ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
              end
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
           case  CHARINDEX('/',cmp1.cty_nmstct) 
              when 0 then cmp1.cty_nmstct
		      else ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
              end
		ELSE 
           case  CHARINDEX('/',cmp1.mailto_cty_nmstct) 
              when 0 then cmp1.mailto_cty_nmstct
		      else ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct))- 1),'')
              end
	    END,
	    billto_zip = 
	     CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	     END,
	    cty1.cty_nmstct   origin_nmstct,
	    cty1.cty_state		origin_state,
	    cty2.cty_nmstct   dest_nmstct,
	    cty2.cty_state		dest_state,
	    @billdate	billdate,
	    ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	    cmp1.cmp_altid  billto_altid, 
	    cmp2.cmp_name   shipper_name,
	    cmp3.cmp_name   consignee_name,
        isnull((select sum (isnull(ivd_charge,0.0)) 
             from invoicedetail id 
             where id.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and cht_itemcode = 'GST'),0.0) GSTCharge
        ,ivh_currency
        ,invoiceheader.ord_hdrnumber ord_hdrnumber
    FROM 
	invoiceheader, 
	company cmp1, 
	city cty1, 
	city cty2, 
	company cmp2,
	company cmp3
   WHERE (invoiceheader.ivh_billto = @billto )  
     AND (invoiceheader.ivh_mbnumber is NULL  OR  
          invoiceheader.ivh_mbnumber = 0   ) 
     AND (invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
     AND (invoiceheader.ivh_mbstatus = 'RTP')  
     AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK')) 
     AND (cmp1.cmp_id = invoiceheader.ivh_billto)
     AND (cty1.cty_code = invoiceheader.ivh_origincity) 
     AND (cty2.cty_code = invoiceheader.ivh_destcity)
     AND (cmp2.cmp_id = invoiceheader.ivh_showshipper) 
     AND (cmp3.cmp_id = invoiceheader.ivh_showcons) 


 

END
GO
GRANT EXECUTE ON  [dbo].[d_masterbill99_sp] TO [public]
GO
