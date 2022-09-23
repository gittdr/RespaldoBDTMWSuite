SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill82_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), @mbstatus varchar(6),
	@shipstart datetime,@shipend datetime,@delstart datetime, @delend datetime,@billdate datetime,
        @revtype1 varchar(6), @revtype2 varchar(6),@revtype3 varchar(6), @revtype4 varchar(6),
        @shipper varchar(8), @consignee varchar(8),@orderby varchar(8),@ivhrefnum varchar(50))
AS

/**
 * 
 * NAME:
 * dbo.d_masterbill82_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Return data for Masterbill 82 which is based upon the premise of holding ALL invoices for 
 * containers that have not been moved.  They wish to base this on a reference number that may
 * not appear in the first position.  They will set up the Ref_type for the company in FM and we will use
 * that ref_type as our filter.  It is assumed that only 1 ref number will occur per the companies ref_type.  
 * If there are more than 1, our results will be tragically skewed.
 *
 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * See SELECT statement.
 *
 * PARAMETERS:
 * 001 - @reprintflag varchar(10),
 * 002 - @mbnumber int,
 * 003 - @billto varchar(8),
 * 004 - @revtype1 varchar(6),
 * 005 - @revtype2 varchar(6),
 * 006 - @mbstatus varchar(6),
 * 007 - @shipstart datetime,
 * 008 - @shipend datetime,
 * 009 - @billdate datetime, 
 * 010 - @delstart datetime, 
 * 011 - @delend datetime,
 * 012 - @revtype1 VARCHAR(6),
 * 013 - @revtype2 varchar(6),
 * 014 - @revtype3 varchar(6)
 * 015 - @revtype4 varchar(6)
 * 010 - @shipper varchar(8),
 * 011 - @consignee varchar(8),
 * 012 - @orderby int,
 * 013 - @ivh_invoicenumber varchar(12),
 * 014 - @refnum varchar(30) - This will receive the refnum we are looking for.
 *
 * REFERENCES:
 * NONE
 * 
 * REVISION HISTORY:
 * 5/10/2006.01 - PRB - Created stored proc for use with Master Bill Format 82, which is inherited
 *                      from masterbill format 71/72.
 * 12/05/2008 pmill PTS45125 Changes requested by Cowan - Add detail
 *
 **/

DECLARE @Rev3Title varchar(50), @cmp_reftype VARCHAR(10)

SET @cmp_reftype = (Select CASE ISNULL(gi_string1, 'REF')
				  WHEN '' THEN 'REF'
				  WHEN ' ' THEN 'REF'
				  WHEN 'REF' THEN 'REF'
				  ELSE gi_string1
				END
		    From generalinfo
		    Where gi_name = 'MasterBill82DefaultRef')


SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'
SELECT @delstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @delend   = convert(char(12),@shipend  )+'23:59:59'

SELECT @Rev3title = min (labelfile.userlabelname) 
FROM labelfile  
WHERE ( labelfile.userlabelname > '' ) AND
( labelfile.labeldefinition  ='RevType3' ) 

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN

    SELECT IH.ivh_invoicenumber,  
	 IH.ivh_hdrnumber, 
         IH.ivh_billto,
	 --ISNULL(ivh_totalcharge, 0) AS ivd_charge,   
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
	 refnumber = (SELECT MIN(ref_number)
		      FROM referencenumber
		      WHERE ord_hdrnumber = IH.ord_hdrnumber
		      AND ref_table = 'orderheader'
	              AND ref_type = CASE ISNULL(CMP1.cmp_reftype_unique, '')
					WHEN '' THEN @cmp_reftype
					WHEN 'UNK' THEN @cmp_reftype
					ELSE CMP1.cmp_reftype_unique
				     END),
	 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	 IH.ivh_revtype3,
	 ivh_revtype3_t= @Rev3title ,
         ShipperName = scmp.cmp_name,
         ConsName = ccmp.cmp_name,
         ivh_trailer,
         Case ivd_description When 'UNKNOWN' Then cht_description Else ivd_description End,		--ivd_description = 'n', 
         ID.ivd_sequence,  --ivd_sequence = 1,
         IH.ord_number,
         IH.ord_hdrnumber,
		CHT.cht_description
    FROM 
	invoiceheader IH
        JOIN invoicedetail ID on ID.ivh_hdrnumber = IH.ivh_hdrnumber
        JOIN company CMP1 on CMP1.cmp_id = IH.ivh_billto
        JOIN company SCMP on SCMP.cmp_id = ivh_shipper
        JOIN company CCMP on CCMP.cmp_ID = ivh_consignee
	LEFT OUTER JOIN CITY CTY1  on CTY1.cty_code = IH.ivh_origincity
        LEFT OUTER JOIN CITY CTY2 on CTY2.cty_code = IH.ivh_destcity
        LEFT OUTER JOIN chargetype CHT on CHT.cht_itemcode = ID.cht_itemcode
   WHERE 
	( IH.ivh_mbnumber = @mbnumber ) 
        AND (ivd_Charge <> 0)
	ORDER BY ivh_deliverydate, refnumber, ivh_revtype3, shippername, consname, IH.ivh_hdrnumber, ID.ivd_sequence
	


  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN

     SELECT IH.ivh_invoicenumber,  
	 IH.ivh_hdrnumber, 
         IH.ivh_billto, 
	 --ISNULL(ivh_totalcharge, 0) AS ivd_charge,  
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
	 --ISNULL(ivh_ref_number,'') refnumber,
	 --ISNULL(ref.ref_number, '') refnumber,
	 --@ivhrefnum refnumber,
	refnumber = (SELECT MIN(ref_number)
		      FROM referencenumber
		      WHERE ord_hdrnumber = IH.ord_hdrnumber
		      AND ref_table = 'orderheader'
	              AND ref_type = CASE ISNULL(CMP1.cmp_reftype_unique, '')
					WHEN '' THEN @cmp_reftype
					WHEN 'UNK' THEN @cmp_reftype
					ELSE CMP1.cmp_reftype_unique
				     END
		      AND ref_sequence = (SELECT MIN(ref_sequence)
		      		    	  FROM referencenumber r
		      		    	  WHERE r.ord_hdrnumber = IH.ord_hdrnumber
		      		    	  AND ref_table = 'orderheader'
	              		    	  AND ref_type = CASE ISNULL(CMP1.cmp_reftype_unique, '')
							 WHEN '' THEN @cmp_reftype
							 WHEN 'UNK' THEN @cmp_reftype
							 ELSE CMP1.cmp_reftype_unique
				      	   END)),
	 ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	 IH.ivh_revtype3,
	 ivh_revtype3_t= @Rev3title,
         ShipperName = scmp.cmp_name,
         ConsName = ccmp.cmp_name ,
         ivh_trailer,
         Case ivd_description When 'UNKNOWN' Then cht_description Else ivd_description End,   --ivd_description = 'n',
         ID.ivd_sequence,     --ivd_sequence = 1,
         IH.ord_number,
         IH.ord_hdrnumber,
		CHT.cht_description
    FROM 
	invoiceheader IH
        JOIN invoicedetail ID on  ID.ivh_hdrnumber = IH.ivh_hdrnumber
        JOIN company CMP1 on CMP1.cmp_id = IH.ivh_billto
        JOIN company SCMP on SCMP.cmp_id = ivh_shipper
        JOIN company CCMP on CCMP.cmp_ID = ivh_consignee
	LEFT OUTER JOIN CITY CTY1  on CTY1.cty_code = IH.ivh_origincity
        LEFT OUTER JOIN CITY CTY2 on CTY2.cty_code = IH.ivh_destcity
        LEFT OUTER JOIN chargetype CHT on CHT.cht_itemcode = ID.cht_itemcode
        --PRB added code 5/15/06 to join on refnumber table.
	LEFT OUTER JOIN referencenumber ref on ref.ref_tablekey = IH.ord_hdrnumber 
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
     AND (ref.ref_number = @ivhrefnum)
     AND (ref.ref_sequence = (SELECT MIN(ref_sequence)
		      		    	  	 FROM referencenumber r
		      		    	  	 WHERE r.ord_hdrnumber = IH.ord_hdrnumber
		      		    	  	 AND ref_table = 'orderheader'
	              		    	  	 AND ref_type = CASE ISNULL(CMP1.cmp_reftype_unique, '')
							 WHEN '' THEN @cmp_reftype
							 WHEN 'UNK' THEN @cmp_reftype
							 ELSE CMP1.cmp_reftype_unique
				      	   	  END))
     --AND IsNull(ivh_ref_number,'') = Case @ivhrefnum When '?ALL?' Then IsNull(ivh_ref_number,'') else @ivhrefnum End
	ORDER BY ivh_deliverydate, refnumber, ivh_revtype3, shippername, consname, IH.ivh_hdrnumber, ID.ivd_sequence

  END

GO
GRANT EXECUTE ON  [dbo].[d_masterbill82_sp] TO [public]
GO
