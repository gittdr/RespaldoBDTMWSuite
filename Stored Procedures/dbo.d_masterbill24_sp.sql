SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [dbo].[d_masterbill24_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	@revtype1 varchar(6), @mbstatus varchar(6),
	@shipstart datetime,@shipend datetime,@billdate datetime )
AS
/**
 * DESCRIPTION:
  pts13334 JYANG create for Snader. Based on MB02. add ref# information
  Created to allow reprinting of masterbills
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @int0  int
SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'
  
--create the temp ref table
select min(ref_number) ref_number,
       ref_tablekey,
	ref_type
into #ref_temp
from referencenumber
where ref_table = 'orderheader'
and ref_type in ('BL#','HUS#','CAR#')
group by ref_tablekey,ref_type

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
	 cty1.cty_nmstct   origin_nmstct,
	 cty1.cty_state		origin_state,
	 cty2.cty_nmstct   dest_nmstct,
	 cty2.cty_state		dest_state,
	 ivh_billdate      billdate,
	 ISNULL(ref1.ref_number,'')   billoflading,
	 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	  cmp1.cmp_altid  billto_altid ,
	 ref2.ref_number   housenumber,
	 ref3.ref_number   carriernumber,
	 cmp2.cmp_name   shipper_name,
	 cmp3.cmp_name   consignee_name
-- stage results in a temp table so dup invoices can be cleared and
-- yet still show the rest of the info
into #Temp
    FROM  invoiceheader 
			INNER JOIN company cmp1 ON cmp1.cmp_id = invoiceheader.ivh_billto
			INNER JOIN company cmp2 ON cmp2.cmp_id = invoiceheader.ivh_originpoint
			INNER JOIN company cmp3 ON cmp3.cmp_id = invoiceheader.ivh_destpoint
			INNER JOIN city cty1 ON cty1.cty_code = invoiceheader.ivh_origincity
			INNER JOIN city cty2 ON cty2.cty_code = invoiceheader.ivh_destcity
			LEFT OUTER JOIN #ref_temp ref1 ON (ref1.ref_tablekey = invoiceheader.ord_hdrnumber and ref1.ref_type ='BL#')
			LEFT OUTER JOIN #ref_temp ref2 ON (ref2.ref_tablekey = invoiceheader.ord_hdrnumber and ref2.ref_type ='HUS#')
			LEFT OUTER JOIN #ref_temp ref3 ON (ref3.ref_tablekey = invoiceheader.ord_hdrnumber and ref3.ref_type ='CAR#')
   WHERE  invoiceheader.ivh_mbnumber = @mbnumber 
	
Select * from #Temp				
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
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))-1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))-1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) -1),'')
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
	 ISNULL(ref1.ref_number,'') billoflading,
	 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	 cmp1.cmp_altid  billto_altid,
	 ref2.ref_number   housenumber,
	 ref3.ref_number   carriernumber,
	 cmp2.cmp_name   shipper_name,
	 cmp3.cmp_name   consignee_name
-- stage results in a temp table so dup invoices can be cleared and
-- yet still show the rest of the info

into #temp2
    FROM 
	invoiceheader 
		INNER JOIN company cmp1 ON cmp1.cmp_id = invoiceheader.ivh_billto
		INNER JOIN company cmp2 ON cmp2.cmp_id = invoiceheader.ivh_originpoint
		INNER JOIN company cmp3 ON cmp3.cmp_id = invoiceheader.ivh_destpoint
		INNER JOIN city cty1 ON cty1.cty_code = invoiceheader.ivh_origincity
		INNER JOIN city cty2 ON cty2.cty_code = invoiceheader.ivh_destcity
		LEFT OUTER JOIN referencenumber ref1 ON (ref1.ref_tablekey = invoiceheader.ord_hdrnumber and ref1.ref_type = 'BL#')
		LEFT OUTER JOIN #ref_temp ref2 ON (ref2.ref_tablekey = invoiceheader.ord_hdrnumber and ref2.ref_type ='HUS#')
		LEFT OUTER JOIN #ref_temp ref3 ON (ref3.ref_tablekey = invoiceheader.ord_hdrnumber and ref3.ref_type ='CAR#')
   WHERE ( invoiceheader.ivh_billto = @billto )  
     AND    ( invoiceheader.ivh_mbnumber is NULL  OR  
            invoiceheader.ivh_mbnumber = 0   ) 
     AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
     AND     (invoiceheader.ivh_mbstatus = 'RTP')  
     AND    (@revtype1 in (invoiceheader.ivh_revtype1,'UNK')) 
 Select * from #Temp2				
  END

GO
GRANT EXECUTE ON  [dbo].[d_masterbill24_sp] TO [public]
GO
