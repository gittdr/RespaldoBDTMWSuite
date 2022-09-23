SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE   PROC [dbo].[d_masterbill46_sp] 
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
 * 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @int0  int, 
        @PO VARCHAR(20), 
        @LH money, 
        @ACC money, 
        @primary_charge money,
        @non_primary_charge money,
        @charge money, 
        @cht_primary char(1), 
        @invoice_no int,
        @invoice_no_prev int

SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'
  

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN

    SELECT 
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
	 --@PO billoflading,
         ivd.ivd_refnum billoflading,
	 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	 --cmp1.cmp_altid  billto_altid ,
         ISNULL(ref.ref_number,'') PO,
         @LH LINE_HAUL,
         @ACC ACCESSORIAL      
-- stage results in a temp table so dup invoices can be cleared and
-- yet still show the rest of the info
into #Temp
    FROM 
        invoicedetail ivd ,
	invoiceheader LEFT OUTER JOIN referencenumber ref ON (ref.ref_tablekey = invoiceheader.ord_hdrnumber AND ref.ref_table = 'orderheader' and ref.ref_sequence = 1), 
	company cmp1, 
	city cty1, 
	city cty2
   WHERE 
	( invoiceheader.ivh_mbnumber = @mbnumber ) 
        AND (ivd.ivh_hdrnumber = invoiceheader.ivh_hdrnumber)
        AND (ivd.ivd_sequence = 1)  
	AND (cmp1.cmp_id = invoiceheader.ivh_billto) 
	AND (cty1.cty_code = invoiceheader.ivh_origincity) 
	AND (cty2.cty_code = invoiceheader.ivh_destcity)
	--  AND (ref.ref_table = 'orderheader')
	--	AND (ref.ref_tablekey =* invoiceheader.ord_hdrnumber)
	--  AND (ref.ref_sequence = 1)
	--  AND (ref.ref_type ='BL#' ) 

-- Above allows dup invoices when there is more than one BL reference number
-- So, quick change to stage the results in a temp table and
-- then zero out the totalcharge on  any but the first BL
Update #Temp
	Set ivh_totalcharge=0
	from #temp
	where
		(	
			Select 
				count(*)
			From 
				#temp T1
			where 
				T1.ivh_hdrnumber=#temp.ivh_hdrnumber
		) > 1
		and
		#temp.billoflading <>
			(
				Select 
					min(t1.billoflading)
				From 
					#Temp T1	
				Where		
					T1.ivh_hdrnumber=#temp.ivh_hdrnumber
			)



 --PTS# 22613 ILB 04/19/2004
  select @primary_charge     = 0 --populate the line_haul column
  select @non_primary_charge = 0 --populate the accessorial column
  select @invoice_no_prev    = 0 --initial value

  --Create a cursor based on the select statement below
  DECLARE primary_secondary_cursor CURSOR FOR  
  
    SELECT ivd.ivd_charge,cht.cht_primary,#Temp.ivh_hdrnumber
      FROM #Temp, invoicedetail ivd, chargetype cht
     WHERE #Temp.ivh_hdrnumber = ivd.ivh_hdrnumber and 
	   ivd.ivh_hdrnumber = #Temp.ivh_hdrnumber and
           ivd.cht_itemcode = cht.cht_itemcode and 
           ivd_charge <> 0
  ORDER BY #Temp.ivh_hdrnumber desc
    
  --Populate the cursor based on the select statement above  
  OPEN primary_secondary_cursor  
  
  --Execute the initial fetch of variable population 
  FETCH NEXT FROM primary_secondary_cursor INTO @charge, @cht_primary, @invoice_no 
  
  --If the fetch is succesful continue to loop
  WHILE @@fetch_status = 0  
   BEGIN  
    
    IF @cht_primary = 'Y'
       Begin                
	    select @primary_charge = @primary_charge + @charge           
       End  

    IF @cht_primary = 'N' 
       Begin   	 
	    select @non_primary_charge = @non_primary_charge + @charge
       End


    select @invoice_no_prev = @invoice_no

    --Fetch the next set of data
    FETCH NEXT FROM primary_secondary_cursor INTO @charge, @cht_primary, @invoice_no 
    
    IF @invoice_no_prev <> @invoice_no
       BEGIN        
         Update #Temp
            set line_haul           = @primary_charge,
                accessorial         = @non_primary_charge               
           from #Temp
          where #Temp.ivh_hdrnumber = @invoice_no_prev 
         
         select @non_primary_charge = 0
         select @primary_charge     = 0
       END

    ELSE
       BEGIN 
    	 Update #Temp
            set line_haul           = @primary_charge,
                accessorial         = @non_primary_charge
          where ivh_hdrnumber       = @invoice_no
       END

   END  
  
   --Close cursor  
   CLOSE primary_secondary_cursor
   --Release cusor resources  
   DEALLOCATE primary_secondary_cursor	
   --PTS# 22613 ILB 04/19/2004  

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
         ivd.ivd_refnum billoflading,
	 --@PO billoflading,
	 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	 --cmp1.cmp_altid  billto_altid,
         ISNULL(ref.ref_number,'') PO,
         @LH LINE_HAUL,
         @ACC ACCESSORIAL

-- stage results in a temp table so dup invoices can be cleared and
-- yet still show the rest of the info

	into #temp2
    FROM 
        invoicedetail ivd ,
	invoiceheader LEFT OUTER JOIN referencenumber ref ON (ref.ref_tablekey = invoiceheader.ord_hdrnumber and ref.ref_table = 'orderheader' and ref.ref_sequence = 1), 
	company cmp1, 
	city cty1, 
	city cty2
   WHERE ( invoiceheader.ivh_billto = @billto )
     AND (ivd.ivh_hdrnumber = invoiceheader.ivh_hdrnumber)
     AND (ivd.ivd_sequence = 1)  
     AND ( invoiceheader.ivh_mbnumber is NULL  OR invoiceheader.ivh_mbnumber = 0   ) 
     AND ( invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
     AND (invoiceheader.ivh_mbstatus = 'RTP')  
     AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK')) 
     AND (cmp1.cmp_id = invoiceheader.ivh_billto)
     AND (cty1.cty_code = invoiceheader.ivh_origincity) 
     AND (cty2.cty_code = invoiceheader.ivh_destcity)
--     AND (ref.ref_table = 'orderheader')
--     AND (ref.ref_tablekey =* invoiceheader.ord_hdrnumber)
--     AND (ref.ref_sequence = 1)
     --AND (ref.ref_type ='BL#'  )
     --vmj1+
     and @revtype2 in (invoiceheader.ivh_revtype2, 'UNK')
     and @revtype3 in (invoiceheader.ivh_revtype3, 'UNK')
     and @revtype4 in (invoiceheader.ivh_revtype4, 'UNK')
     --vmj1-

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

  --PTS# 22613 ILB 04/19/2004
  select @primary_charge     = 0 --populate the line_haul column
  select @non_primary_charge = 0 --populate the accessorial column
  select @invoice_no_prev    = 0 --initial value

  --Create a cursor based on the select statement below
  DECLARE primary_secondary_cursor CURSOR FOR  
  
    SELECT ivd.ivd_charge,cht.cht_primary,#temp2.ivh_hdrnumber
      FROM #temp2, invoicedetail ivd, chargetype cht
     WHERE #temp2.ivh_hdrnumber = ivd.ivh_hdrnumber and 
	   ivd.ivh_hdrnumber = #temp2.ivh_hdrnumber and
           ivd.cht_itemcode = cht.cht_itemcode and 
           ivd_charge <> 0
  ORDER BY #temp2.ivh_hdrnumber desc
    
  --Populate the cursor based on the select statement above  
  OPEN primary_secondary_cursor  
  
  --Execute the initial fetch of variable population 
  FETCH NEXT FROM primary_secondary_cursor INTO @charge, @cht_primary, @invoice_no 
  
  --If the fetch is succesful continue to loop
  WHILE @@fetch_status = 0  
   BEGIN  
    
    IF @cht_primary = 'Y'
       Begin                
	    select @primary_charge = @primary_charge + @charge           
       End  

    IF @cht_primary = 'N' 
       Begin   	 
	    select @non_primary_charge = @non_primary_charge + @charge
       End


    select @invoice_no_prev = @invoice_no

    --Fetch the next set of data
    FETCH NEXT FROM primary_secondary_cursor INTO @charge, @cht_primary, @invoice_no 
    
    IF @invoice_no_prev <> @invoice_no
       BEGIN        
         Update #temp2
            set line_haul           = @primary_charge,
                accessorial         = @non_primary_charge               
           from #temp2
          where #temp2.ivh_hdrnumber = @invoice_no_prev 
         
         select @non_primary_charge = 0
         select @primary_charge     = 0
       END
    ELSE
       BEGIN 
    	 Update #temp2
            set line_haul           = @primary_charge,
                accessorial         = @non_primary_charge
          where ivh_hdrnumber       = @invoice_no
       END

   END  
  
   --Close cursor  
   CLOSE primary_secondary_cursor
   --Release cusor resources  
   DEALLOCATE primary_secondary_cursor	
   --PTS# 22613 ILB 04/19/2004  

   Select * from #Temp2		 

  END
GO
GRANT EXECUTE ON  [dbo].[d_masterbill46_sp] TO [public]
GO
