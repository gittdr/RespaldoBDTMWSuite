SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill84_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                       @revtype1 varchar(6), @mbstatus varchar(6),@shipstart datetime,
                               @shipend datetime,@billdate datetime, @revtype2 varchar(6),
			       @revtype3 varchar(6), @revtype4 varchar(6))
AS

/**
 * 
 * NAME:
 * dbo.d_masterbill84_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Return data for Masterbill 84.  See PTS for description
 *
 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * See SELECT statement.
 *
 * PARAMETERS:
 * 001 - @reprintflag varchar(10),
 * 002 - @mbnumber int
 * 003 - @billto varchar(8)
 * 004 - @revtype1 varchar(6)
 * 005 - @revtype2 varchar(6)
 * 006 - @mbstatus varchar(6)
 * 007 - @shipstart datetime
 * 008 - @shipend datetime
 * 009 - @billdate datetime 
 * 010 - @revtype2 varchar(6)
 * 010 - @revtype3 VARCHAR(6)
 * 011 - @revtype4 varchar(6)
 *
 * REFERENCES:
 * NONE
 * 
 * REVISION HISTORY:
 * 6/15/2006.01 - PRB - Created stored proc for use with Master Bill Format 84, which is inherited
 *                      from masterbill format 48.
 * 7/31/2006/02 - PRB - Fixed Joins.
 * 9/25/2006.03 - PRB - PTS34609 - Fixed Join in the Reprint section.  Was left out of initial fix from 7/31/2006
 *
 **/

DECLARE @int0  int
SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'
  
/* PTS34609 - Don't need this code
select ref_number,
       ref_tablekey       
  into #ref_temp
  from referencenumber
 where ref_table = 'ORDERHEADER'
       and ref_sequence = 1
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
	   --invoiceheader.ivh_shipdate,
           ivh_shipdate = (SELECT MIN(legheader.lgh_enddate_arrival) 
			    FROM stops, legheader
			    WHERE stops.lgh_number = legheader.lgh_number
      			    AND stops.ord_hdrnumber = invoiceheader.ord_hdrnumber),   
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
	   ISNULL(ref1.ref_number,'') ref_number,
	   ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	   cmp1.cmp_altid  billto_altid ,	   
	   cmp2.cmp_name   shipper_name,
	   cmp3.cmp_name   consignee_name
-- stage results in a temp table so dup invoices can be cleared and
-- yet still show the rest of the info
    INTO #Temp
    FROM 
	invoiceheader
	LEFT OUTER JOIN referencenumber ref1
        ON invoiceheader.ord_hdrnumber = ref1.ref_tablekey
	AND ref1.ref_sequence = 1
	AND ref1.ref_table = 'orderheader',
	--RIGHT OUTER JOIN #ref_temp ref1
	--ON ref1.ref_tablekey = invoiceheader.ord_hdrnumber, 
	company cmp1, 
	city cty1, 
	city cty2, 
	--#ref_temp ref1,
	company cmp2,
	company cmp3
   WHERE 
	(invoiceheader.ivh_mbnumber = @mbnumber ) 
	AND(cmp1.cmp_id = invoiceheader.ivh_billto) 
	AND(cty1.cty_code = invoiceheader.ivh_origincity) 
	AND(cty2.cty_code = invoiceheader.ivh_destcity)
	--AND(ref1.ref_tablekey =* invoiceheader.ord_hdrnumber)
	AND(cmp2.cmp_id = invoiceheader.ivh_originpoint) 
	AND(cmp3.cmp_id = invoiceheader.ivh_destpoint) 


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
	    --invoiceheader.ivh_shipdate,   
            ivh_shipdate = (SELECT MIN(legheader.lgh_enddate_arrival) 
			    FROM stops, legheader
			    WHERE stops.lgh_number = legheader.lgh_number
      			    AND stops.ord_hdrnumber = invoiceheader.ord_hdrnumber),
            invoiceheader.ivh_deliverydate,   
            invoiceheader.ivh_revtype1,
	    @mbnumber     ivh_mbnumber,
	    billto_name = cmp1.cmp_name,
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
	    ISNULL(ref1.ref_number,'') ref_number,
	    ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	    cmp1.cmp_altid  billto_altid,

	    cmp2.cmp_name   shipper_name,
	    cmp3.cmp_name   consignee_name
    INTO #temp2
    FROM 
	invoiceheader
	LEFT OUTER JOIN referencenumber ref1
        ON invoiceheader.ord_hdrnumber = ref1.ref_tablekey
	AND ref1.ref_sequence = 1
	AND ref1.ref_table = 'orderheader',
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
     AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK'))
     AND (@revtype3 in (invoiceheader.ivh_revtype3,'UNK'))
     AND (@revtype4 in (invoiceheader.ivh_revtype4,'UNK'))
     AND (cmp1.cmp_id = invoiceheader.ivh_billto)
     AND (cty1.cty_code = invoiceheader.ivh_origincity) 
     AND (cty2.cty_code = invoiceheader.ivh_destcity)
     -- Commented out for PTS33599
     --AND (ref1.ref_table = 'orderheader')     
     --AND (ref1.ref_tablekey =* invoiceheader.ord_hdrnumber)
     --AND (ref1.ref_sequence = 1)
     -- END PTS33599
     AND (cmp2.cmp_id = invoiceheader.ivh_originpoint) 
     AND (cmp3.cmp_id = invoiceheader.ivh_destpoint) 


 Select * from #Temp2	  

END
GO
GRANT EXECUTE ON  [dbo].[d_masterbill84_sp] TO [public]
GO
