SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill01_sp] 
		(@reprintflag varchar(10)
		,@mbnumber int
		,@billto varchar(8)
		,@revtype1 varchar(6)
		,@mbstatus varchar(6)
		,@shipstart datetime
		,@shipend datetime	
		,@billdate datetime

		--vmj1+	PTS 17305	03/05/2003	Restrict by RevTypes 2, 3, and 4 also.
		,@revtype2	varchar(6)
		,@revtype3	varchar(6)
		,@revtype4	varchar(6)
		--vmj1-
		)
AS
/**
 * DESCRIPTION:
  Created to allow reprinting of masterbills
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
 * 8/17/09 DPETE PTS 48679 created from proc for mb format02 which this format used to use
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
	 invoiceheader.ivh_mbnumber,
	 billto_name =  cmp1.cmp_name,  -- note maito name is brought back later
	 billto_address = case Rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 billto_address2 = case Rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	 billto_nmstct = case Rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct +'/'))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct + '/')) - 1),'')
	    END,
	billto_zip =   case Rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN ''  THEN ISNULL(cmp1.cmp_zip ,'')  
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
	 cty1.cty_nmstct   origin_nmstct,
	 cty1.cty_state		origin_state,
	 cty2.cty_nmstct   dest_nmstct,
	 cty2.cty_state		dest_state,
	 ivh_billdate      billdate,
	 ' '  billoflading,  -- not used on format ISNULL(ref.ref_number,'')   billoflading,
	 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	  cmp1.cmp_altid  billto_altid 
-- stage results in a temp table so dup invoices can be cleared and
-- yet still show the rest of the info

    FROM 
	invoiceheader 
	join company cmp1 on invoiceheader.ivh_billto = cmp1.cmp_id
	join city cty1 on invoiceheader.ivh_origincity = cty1.cty_code
	join city cty2 on invoiceheader.ivh_destcity = cty2.cty_code
   WHERE 
	( invoiceheader.ivh_mbnumber = @mbnumber ) 

 
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
	 billto_name =  cmp1.cmp_name,  -- note maito name is brought back later
	 billto_address = case Rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 billto_address2 = case Rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	 billto_nmstct = case Rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct +'/'))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct + '/')) - 1),'')
	    END,
	billto_zip =   case Rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN ''  THEN ISNULL(cmp1.cmp_zip ,'')  
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
	 cty1.cty_nmstct   origin_nmstct,
	 cty1.cty_state		origin_state,
	 cty2.cty_nmstct   dest_nmstct,
	 cty2.cty_state		dest_state,
	 @billdate	billdate,
	 ' ' billoflading,  -- not used ISNULL(ref.ref_number,'') billoflading,
	 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	 cmp1.cmp_altid  billto_altid

    FROM 
	invoiceheader 
	join company cmp1 on invoiceheader.ivh_billto = cmp1.cmp_id
	join city cty1 on invoiceheader.ivh_origincity = cty1.cty_code
	join city cty2 on invoiceheader.ivh_destcity = cty2.cty_code
   	WHERE ( invoiceheader.ivh_billto = @billto )  
     AND    ( invoiceheader.ivh_mbnumber is NULL  OR  
            invoiceheader.ivh_mbnumber = 0   ) 
     AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
     AND     (invoiceheader.ivh_mbstatus = 'RTP')  
     AND    (@revtype1 in (invoiceheader.ivh_revtype1,'UNK')) 
	 and	@revtype2 in (invoiceheader.ivh_revtype2, 'UNK')
	 and	@revtype3 in (invoiceheader.ivh_revtype3, 'UNK')
	 and	@revtype4 in (invoiceheader.ivh_revtype4, 'UNK')

  

  END

GO
GRANT EXECUTE ON  [dbo].[d_masterbill01_sp] TO [public]
GO
