SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
  Created For C&K masterbills 71 and 72
  DPETE PTS26914 - If argument @ivhrefnum is '?ALL?' return all values
  (Michalynn Kelly added cmp_address3 in out of VSS version)
  DPETE 32040 add ord_hdrnumber to return set  (Michalynn had added ord_number and address3 as a SUpport change)
 DPETE 45780 select @delstart and end was converting form ship arguments not delivery
*/
  



CREATE PROC [dbo].[d_masterbill71_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	@mbstatus varchar(6),
	@shipstart datetime,@shipend datetime,@delstart datetime, @delend datetime,@billdate datetime,
        @revtype1 varchar(6), @revtype2 varchar(6),@revtype3 varchar(6), @revtype4 varchar(6),
        @shipper varchar(8), @consignee varchar(8),@orderby varchar(8),@ivhrefnum varchar(50) )
AS

DECLARE @Rev3Title varchar(50)


SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'
SELECT @delstart = convert(char(12),@delstart)+'00:00:00'
SELECT @delend   = convert(char(12),@delend  )+'23:59:59'

SELECT @Rev3title = min ( labelfile.userlabelname ) 
FROM labelfile  
WHERE ( labelfile.userlabelname > '' ) AND
( labelfile.labeldefinition  ='RevType3' )

  

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN

    SELECT IH.ivh_invoicenumber,  
	 IH.ivh_hdrnumber, 
         IH.ivh_billto,   
         ID.ivd_charge,   
         IH.ivh_originpoint,  
         IH.ivh_destpoint,   
         IH.ivh_origincity,   
         IH.ivh_destcity,   
         IH.ivh_shipdate,   
         IH.ivh_deliverydate,   
         IH.ivh_revtype1,
	 IH.ivh_mbnumber,
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
          billto_address3 = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address3,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address3,'')
		ELSE ''
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
	 refnumber = ISNULL(ivh_ref_number,''),
	 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	 IH.ivh_revtype3,
	 ivh_revtype3_t= @Rev3title ,
         ShipperName = scmp.cmp_name,
         ConsName = ccmp.cmp_name,
         ivh_trailer,
         ivd_description= Case ivd_description When 'UNKNOWN' Then cht_description Else ivd_description End,
         ivd_sequence,
         IH.ord_number,
         IH.ord_hdrnumber
    FROM 
	invoiceheader IH
        JOIN invoicedetail ID on  ID.ivh_hdrnumber = IH.ivh_hdrnumber
        JOIN company CMP1 on CMP1.cmp_id = IH.ivh_billto
        JOIN company SCMP on SCMP.cmp_id = ivh_shipper
        JOIN company CCMP on CCMP.cmp_ID = ivh_consignee
	LEFT OUTER JOIN CITY CTY1  on CTY1.cty_code = IH.ivh_origincity
        LEFT OUTER JOIN CITY CTY2 on CTY2.cty_code = IH.ivh_destcity
        LEFT OUTER JOIN chargetype CHT on CHT.cht_itemcode = ID.cht_itemcode
   WHERE 
	( IH.ivh_mbnumber = @mbnumber ) 
        AND (ivd_Charge <> 0)
	


  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN

     SELECT IH.ivh_invoicenumber,  
	 IH.ivh_hdrnumber, 
         IH.ivh_billto,   
         ID.ivd_charge,   
         IH.ivh_originpoint,  
         IH.ivh_destpoint,   
         IH.ivh_origincity,   
         IH.ivh_destcity,   
         IH.ivh_shipdate,   
         IH.ivh_deliverydate,   
         IH.ivh_revtype1,
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
        billto_address3 = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address3,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address3,'')
		ELSE ''
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
	 ISNULL(ivh_ref_number,'') refnumber,
	 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	 IH.ivh_revtype3,
	 ivh_revtype3_t= @Rev3title,
         ShipperName = scmp.cmp_name,
         ConsName = ccmp.cmp_name ,
         ivh_trailer,
         ivd_description= Case ivd_description When 'UNKNOWN' Then cht_description Else ivd_description End,
         ivd_sequence,
         IH.ord_number,
         IH.ord_hdrnumber
    FROM 
	invoiceheader IH
        JOIN invoicedetail ID on  ID.ivh_hdrnumber = IH.ivh_hdrnumber
        JOIN company CMP1 on CMP1.cmp_id = IH.ivh_billto
        JOIN company SCMP on SCMP.cmp_id = ivh_shipper
        JOIN company CCMP on CCMP.cmp_ID = ivh_consignee
	LEFT OUTER JOIN CITY CTY1  on CTY1.cty_code = IH.ivh_origincity
        LEFT OUTER JOIN CITY CTY2 on CTY2.cty_code = IH.ivh_destcity
        LEFT OUTER JOIN chargetype CHT on CHT.cht_itemcode = ID.cht_itemcode
   WHERE ( IH.ivh_billto = @billto )
     AND (ivd_Charge <> 0)  
     AND    ( IsNull(IH.ivh_mbnumber,0) = 0   ) 
     AND    ( IH.ivh_shipdate between @shipstart AND @shipend ) 
     AND    ( IH.ivh_deliverydate between @delstart AND @delend ) 
     AND     (IH.ivh_mbstatus = 'RTP')  
     AND    (@revtype1 in (IH.ivh_revtype1,'UNK')) 
     AND (@revtype2 in (IH.ivh_revtype2,'UNK')) 
     AND (@revtype3 in (IH.ivh_revtype3,'UNK'))
     AND (@revtype4 in (IH.ivh_revtype4,'UNK')) 
     AND (@shipper IN(IH.ivh_shipper,'UNKNOWN'))
     AND (@consignee IN (IH.ivh_consignee,'UNKNOWN'))
     AND IsNull(ivh_ref_number,'') = Case @ivhrefnum When '?ALL?' Then IsNull(ivh_ref_number,'') else @ivhrefnum End



  

  END

GO
GRANT EXECUTE ON  [dbo].[d_masterbill71_sp] TO [public]
GO
