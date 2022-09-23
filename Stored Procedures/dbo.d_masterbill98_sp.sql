SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill98_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                       @revtype1 varchar(6), @mbstatus varchar(6),@shipstart datetime,
                               @shipend datetime,@billdate datetime )
AS
/**
 * 
 * NAME:
 * dbo.d_masterbill98_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Return data for master bill format 98
 *
 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * see retrun SET
 *
 * PARAMETERS:
 *	001 - @reprintflag VARCHAR(10),
 *	002 - @mbnumber INT,
 *  003 - @billto VARCHAR(8), 
 *  004 - @revtype1 VARCHAR(6), 
 *  005 - @mbstatus VARCHAR(6),
 *  006 - @shipstart DATETIME,
 *  007 - @shipend DATETIME,
 *  008 - @billdate DATETIME 
 *
 * REVISION HISTORY:
 * 06/01/07.01 PTS36794 - OS - Created stored proc as modification of proc for  d_mb_format
 * DPETE {PTS50645 2/17/10 join to wrong ref table in second select
 *
 **/

DECLARE @int0  int
SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'
/*select ref_number,
       ref_tablekey,
	   ref_sequence       
into #ref_temp
from referencenumber
where ref_table = 'ORDERHEADER'
       --and ref_sequence = 1
*/

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
	   -- ISNULL(ref1.ref_number,'') ref_number,
       isnull( ivh_ref_number,'') ref_number,
	   ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	   cmp1.cmp_altid  billto_altid ,	   
	   cmp2.cmp_name   shipper_name,
	   cmp3.cmp_name   consignee_name,
	   ISNULL(cty1.cty_zip, '')   origin_zip,
	   ISNULL(cty2.cty_zip, '')   dest_zip,
	   invoiceheader.ivh_totalpieces, 
	   invoiceheader.ivh_totalweight,
	  -- ISNULL(ref2.ref_number,'') ref_number2
      Isnull((select ref_number from referencenumber
         where ref_table = 'orderheader' and ref_tablekey = invoiceheader.ord_hdrnumber	
        and ref_sequence = 2),'')  ref_number2 	  
-- stage results in a temp table so dup invoices can be cleared and
-- yet still show the rest of the info
--    INTO #Temp
    FROM invoiceheader join  company cmp1 on cmp1.cmp_id = invoiceheader.ivh_billto  
	join city cty1 on cty1.cty_code = invoiceheader.ivh_origincity  
	join city cty2 on cty2.cty_code = invoiceheader.ivh_destcity  
	--left outer join #ref_temp ref1 on ref1.ref_tablekey = invoiceheader.ord_hdrnumber and ref1.ref_sequence = 1
	--left outer join #ref_temp ref2 on ref2.ref_tablekey = invoiceheader.ord_hdrnumber and ref2.ref_sequence = 2 
	join company cmp2 on cmp2.cmp_id = invoiceheader.ivh_originpoint
	join company cmp3 on cmp3.cmp_id = invoiceheader.ivh_destpoint
	WHERE invoiceheader.ivh_mbnumber = @mbnumber  

--Select * from #Temp				

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
	   -- ISNULL(ref1.ref_number,'') ref_number,
        isnull( ivh_ref_number,'') ref_number,
	    ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	    cmp1.cmp_altid  billto_altid,
	    cmp2.cmp_name   shipper_name,
	    cmp3.cmp_name   consignee_name,
		ISNULL(cty1.cty_zip, '')   origin_zip,
		ISNULL(cty2.cty_zip, '')   dest_zip,
		invoiceheader.ivh_totalpieces, 
		invoiceheader.ivh_totalweight,
		--ISNULL(ref2.ref_number,'') ref_number2 
       Isnull((select ref_number from referencenumber
         where ref_table = 'orderheader' and ref_tablekey = invoiceheader.ord_hdrnumber	
        and ref_sequence = 2),'')  ref_number2 	  
-- stage results in a temp table so dup invoices can be cleared and
-- yet still show the rest of the info
--    INTO #temp2
    FROM invoiceheader join company cmp1 on cmp1.cmp_id = invoiceheader.ivh_billto 
	join city cty1 on cty1.cty_code = invoiceheader.ivh_origincity 
	join city cty2 on cty2.cty_code = invoiceheader.ivh_destcity  
	--left outer join referencenumber ref1 on ref1.ref_tablekey = invoiceheader.ord_hdrnumber and ref1.ref_sequence = 1 
	--left outer join referencenumber ref2 on ref2.ref_tablekey = invoiceheader.ord_hdrnumber and ref2.ref_sequence = 2
	join company cmp2 on cmp2.cmp_id = invoiceheader.ivh_originpoint 
	join company cmp3 on cmp3.cmp_id = invoiceheader.ivh_destpoint
   WHERE (invoiceheader.ivh_billto = @billto)  
     AND (invoiceheader.ivh_mbnumber is NULL OR invoiceheader.ivh_mbnumber = 0) 
     AND (invoiceheader.ivh_shipdate between @shipstart AND @shipend) 
     AND (invoiceheader.ivh_mbstatus = 'RTP')  
     AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK')) 
     
--Select * from #Temp2 

END
GO
GRANT EXECUTE ON  [dbo].[d_masterbill98_sp] TO [public]
GO
