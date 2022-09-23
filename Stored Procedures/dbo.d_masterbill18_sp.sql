SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill18_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	@revtype1 varchar(6), @mbstatus varchar(6),
	@shipstart datetime,@shipend datetime,@billdate datetime )
AS
/**
 * DESCRIPTION:
  Created to allow reprinting of masterbills
  jy created for pts12105
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
  * 5/10/11 DPETE PTS 56993 for some reason re print was bringing back data, but it did nto appear on the datwindow
  *        Substituted select for original master bill as select for reprint.
 *
 **/

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
         invoiceheader.ivh_totalcharge,   
         invoiceheader.ivh_originpoint,  
         invoiceheader.ivh_destpoint,   
         invoiceheader.ivh_origincity,   
         invoiceheader.ivh_destcity,   
         invoiceheader.ivh_shipdate,   
         invoiceheader.ivh_deliverydate,   
         invoiceheader.ivh_revtype1,
	 ivh_mbnumber,
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
	 ivh_billdate	billdate,
	 ISNULL(ref.ref_number,'') billoflading,
	 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	 invoiceheader.ivh_revtype3,
	 inh_revtype3_t=(SELECT distinct upper(userlabelname)
	  		 FROM	labelfile
	  		 WHERE labeldefinition = 'revtype3') 
-- stage results in a temp table so dup invoices can be cleared and
-- yet still show the rest of the info
-- stage results in a temp table so dup invoices can be cleared and
-- yet still show the rest of the info
into #Temp
    FROM 
	invoiceheader LEFT OUTER JOIN referencenumber ref ON (ref.ref_tablekey = invoiceheader.ord_hdrnumber and ref.ref_table = 'orderheader' and ref.ref_type ='BL#'), 
	company cmp1, 
	city cty1, 
	city cty2 	
   WHERE 
	( invoiceheader.ivh_mbnumber = @mbnumber ) 
	AND (cmp1.cmp_id = invoiceheader.ivh_billto) 
	AND (cty1.cty_code = invoiceheader.ivh_origincity) 
	AND (cty2.cty_code = invoiceheader.ivh_destcity)
--	AND (ref.ref_table = 'orderheader')
--	AND (ref.ref_tablekey =* invoiceheader.ord_hdrnumber)
--	AND (ref.ref_type ='BL#' ) 

-- Above allows dup invoices when there is more than one BL reference number
-- So, quick change to stage the results in a temp table and
-- then zero out the totalcharge on  any but the first BL
Update #Temp
	Set ivh_totalcharge=0
	from #temp
	where
		(	Select 
				count(*)
			From 
				#temp T1
			where 
				T1.ivh_hdrnumber=#temp.ivh_hdrnumber
		)>1
		and
		#temp.billoflading <>
			(
				Select 
					MIN(t1.billoflading)
				From 
					#Temp T1	
				WHERE
					T1.ivh_hdrnumber=#temp.ivh_hdrnumber
			)
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
	 ISNULL(ref.ref_number,'') billoflading,
	 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	 invoiceheader.ivh_revtype3,
	 inh_revtype3_t=(SELECT distinct upper(userlabelname)
	  		 FROM	labelfile
	  		 WHERE labeldefinition = 'revtype3') 
-- stage results in a temp table so dup invoices can be cleared and
-- yet still show the rest of the info

into #temp2
    FROM 
	invoiceheader LEFT OUTER JOIN referencenumber ref ON (ref.ref_tablekey = invoiceheader.ord_hdrnumber and ref.ref_table = 'orderheader' and ref.ref_type ='BL#'), 
	company cmp1, 
	city cty1, 
	city cty2
   WHERE ( invoiceheader.ivh_billto = @billto )  
     AND    ( invoiceheader.ivh_mbnumber is NULL  OR  
            invoiceheader.ivh_mbnumber = 0   ) 
     AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
     AND     (invoiceheader.ivh_mbstatus = 'RTP')  
     AND    (@revtype1 in (invoiceheader.ivh_revtype1,'UNK')) 
     AND    (cmp1.cmp_id = invoiceheader.ivh_billto)
     AND    (cty1.cty_code = invoiceheader.ivh_origincity) 
     AND    (cty2.cty_code = invoiceheader.ivh_destcity)
--     AND (ref.ref_table = 'orderheader')
--     AND (ref.ref_tablekey =* invoiceheader.ord_hdrnumber)
--     AND (ref.ref_type ='BL#'  )


-- Above allows dup invoices when there is more than one BL reference number
-- So, quick change to stage the results in a temp table and
-- then zero out the totalcharge on  any but the first BL

Update #Temp2
	Set ivh_totalcharge=0
	from #temp2
	where
		(	Select 
				count(*)
			From 
				#temp2 T1
			where 
				T1.ivh_hdrnumber=#temp2.ivh_hdrnumber
		)>1
		and
		#temp2.billoflading <>
			(
				Select 
					MIN(t1.billoflading)
				From 
					#Temp2 T1	
				WHERE
					T1.ivh_hdrnumber=#temp2.ivh_hdrnumber
			)

	Select * from #Temp2				


  

  END

GO
GRANT EXECUTE ON  [dbo].[d_masterbill18_sp] TO [public]
GO
