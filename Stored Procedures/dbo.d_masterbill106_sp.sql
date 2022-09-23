SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill106_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), @mbstatus varchar(6),
	@shipstart datetime,@shipend datetime,@delstart datetime, @delend datetime,@billdate datetime,
        @revtype1 varchar(6), @revtype2 varchar(6),@revtype3 varchar(6), @revtype4 varchar(6),
        @shipper varchar(8), @consignee varchar(8),@orderby varchar(8),@ivhrefnum varchar(50))
AS

/**
 * 
 * NAME:
 * dbo.d_masterbill106_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Return data for Masterbill 106 , breaking on ref type.
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
 * 12/04/2007.01 - EMK - PTS 40126 - Created. Adapted from d_masterbill82 for new format 106.
 *
 **/

DECLARE @Rev3Title varchar(50), @cmp_reftype VARCHAR(10), @cmp_gi_reftype varchar(10)
 
SET @cmp_gi_reftype = (Select CASE rtrim(ISNULL(gi_string1, 'REF'))
					  WHEN '' THEN 'REF'
					  WHEN ' ' THEN 'REF'
					  WHEN 'REF' THEN 'REF'
					  ELSE gi_string1
					END
			    From generalinfo
			    Where gi_name = 'MasterBill82DefaultRef')

select @cmp_reftype = (Select CASE rtrim(ISNULL(cmp.cmp_reftype_unique, ''))
						WHEN '' THEN @cmp_gi_reftype
						WHEN 'UNK' THEN @cmp_gi_reftype
						ELSE cmp.cmp_reftype_unique
			           END
					FROM company cmp
					WHERE cmp.cmp_id = @billto)


SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'
SELECT @delstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @delend   = convert(char(12),@shipend  )+'23:59:59'

SELECT @Rev3title = min (labelfile.userlabelname) 
FROM labelfile  
WHERE ( labelfile.userlabelname > '' ) AND
( labelfile.labeldefinition  ='RevType3' ) 

-- if printflag is set to REPRINT, retrieve an already printed mb by #
IF UPPER(@reprintflag) = 'REPRINT' 
BEGIN
	SELECT ivh.ivh_invoicenumber,  
		ivh.ivh_hdrnumber, 
        ivh.ord_number,
        ivh.ord_hdrnumber,
		ivh.ivh_billto,
		ivh.ivh_mbnumber,
		ivh.ivh_billdate,
		Case IsNumeric(IsNULL(ivh_terms,'UNK')) 
						when 1 then ivh_terms 
						else (Case IsNumeric(IsNULL(bill.cmp_terms,'UNK')) 
								when 1 then bill.cmp_terms 
								else 30 --default to 30
					  		  End )
					  End ivh_terms,
		ivh.ivh_shipdate,   
		ivh.ivh_deliverydate,   
		ivh.ivh_revtype1,
		ivh.ivh_revtype3,
		ivh_revtype3_t= @Rev3title,
        CASE (ivh.ivh_trailer)
			WHEN 'UNKNOWN' THEN ''
			ELSE ivh.ivh_trailer
			END ivh_trailer,
		ivh.ivh_originpoint,  
 		orig.cty_nmstct origin_nmstct,
		orig.cty_state origin_state,
		ivh.ivh_origincity,  
		ivh.ivh_destpoint,   
		ivh.ivh_destcity,  
		dest.cty_nmstct dest_nmstct,
		dest.cty_state dest_state,
		ISNULL(ivd_charge, 0) AS ivd_charge,    
		billto_name = bill.cmp_name,
		billto_address = 
		    CASE
				WHEN bill.cmp_mailto_name IS NULL THEN ISNULL(bill.cmp_address1,'')
				WHEN (bill.cmp_mailto_name <= ' ') THEN ISNULL(bill.cmp_address1,'')
				ELSE ISNULL(bill.cmp_mailto_address1,'')
		    END,
		billto_address2 = 
			CASE
				WHEN bill.cmp_mailto_name IS NULL THEN ISNULL(bill.cmp_address2,'')
				WHEN (bill.cmp_mailto_name <= ' ') THEN ISNULL(bill.cmp_address2,'')
				ELSE ISNULL(bill.cmp_mailto_address2,'')
			END,
		 billto_address3 = 
			CASE
				WHEN bill.cmp_mailto_name IS NULL THEN ISNULL(bill.cmp_address3,'')
				WHEN (bill.cmp_mailto_name <= ' ') THEN ISNULL(bill.cmp_address3,'')
				ELSE ''
			END,
		 billto_nmstct = 
		    CASE
			WHEN bill.cmp_mailto_name IS NULL THEN 
			   ISNULL(SUBSTRING(bill.cty_nmstct,1,CASE
				WHEN CHARINDEX('/',bill.cty_nmstct)- 1 < 0 THEN 0
				ELSE CHARINDEX('/',bill.cty_nmstct) -1
				END),'')
			WHEN (bill.cmp_mailto_name <= ' ') THEN 
			   ISNULL(SUBSTRING(bill.cty_nmstct,1,CASE
				WHEN CHARINDEX('/',bill.cty_nmstct)- 1 < 0 THEN 0
				ELSE CHARINDEX('/',bill.cty_nmstct) -1
				END),'')
			ELSE ISNULL(SUBSTRING(bill.mailto_cty_nmstct,1,CASE
				WHEN CHARINDEX('/',bill.mailto_cty_nmstct)- 1 < 0 THEN 0
				ELSE CHARINDEX('/',bill.mailto_cty_nmstct) -1
				END),'')
		    END,
		billto_zip = 
			CASE
				WHEN bill.cmp_mailto_name IS NULL  THEN ISNULL(bill.cmp_zip ,'')  
				WHEN (bill.cmp_mailto_name <= ' ') THEN ISNULL(bill.cmp_zip,'')
				ELSE ISNULL(bill.cmp_mailto_zip,'')
			END,
		ivh_shipper_name = CASE(ship.cmp_name) 
								WHEN 'UNKNOWN' then ''
								ELSE ship.cmp_name
							 END,
		ivh_shipper_address = ISNULL(ship.cmp_address1,''),
	 	ivh_shipper_address2 = ISNULL(ship.cmp_address2,''), 
		ivh_shipper_address3 = ISNULL(ship.cmp_address3,''),
	  	ivh_shipper_nmstct = ISNULL(SUBSTRING(ship.cty_nmstct,1,CASE
									WHEN CHARINDEX('/',ship.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',ship.cty_nmstct) -1
									END),''),
		ivh_shipto_zip = ISNULL(ship.cmp_zip,''),
		ivh_consignee_name = CASE(consig.cmp_name) 
								WHEN 'UNKNOWN' then ''
								ELSE consig.cmp_name
							 END,
		ivh_consignee_address = ISNULL(consig.cmp_address1,''),
	 	ivh_consignee_address2 = ISNULL(consig.cmp_address2,''), 
		ivh_consignee_address3 = ISNULL(consig.cmp_address3,''), 
	  	ivh_consignee_nmstct = ISNULL(SUBSTRING(consig.cty_nmstct,1,CASE
									WHEN CHARINDEX('/',consig.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',consig.cty_nmstct) -1
									END),''),
		ivh_consignee_zip = ISNULL(consig.cmp_zip,''),
		refnumber = IsNull((SELECT MIN(ref_number)
		  FROM referencenumber
		  WHERE ord_hdrnumber = ivh.ord_hdrnumber
		  AND ref_table = 'orderheader'
		      AND ref_type = @cmp_reftype),''),
		ISNULL(bill.cmp_mailto_name,'') cmp_mailto_name,
		ivd_number,
		Case ivd_description 
			When 'UNKNOWN' Then cht.cht_description 
			When '' Then cht.cht_description
			Else ivd_description 
		End ivd_description,
		ivd_sequence,
		ivd_rate,
		ivd_quantity,
		cht.cht_basis,
		irefnumber = IsNull((SELECT MIN(ref_sequence)
								FROM referencenumber r
								WHERE r.ref_tablekey = ivh.ivh_hdrnumber
								and ord_hdrnumber = 0
								AND ref_table = 'invoiceheader'
								AND ref_type = @cmp_reftype),''),
        copy = 1
    FROM invoiceheader ivh
		JOIN invoicedetail ivd on ivd.ivh_hdrnumber = ivh.ivh_hdrnumber
		JOIN chargetype cht on cht.cht_itemcode = ivd.cht_itemcode
		JOIN company bill on bill.cmp_id = ivh.ivh_billto
		JOIN company ship on ship.cmp_id = ivh_shipper
		JOIN company consig on consig.cmp_id = ivh_consignee
		LEFT OUTER JOIN CITY orig  on orig.cty_code = ivh.ivh_origincity
		LEFT OUTER JOIN CITY dest on dest.cty_code = ivh.ivh_destcity
   WHERE ivh.ivh_mbnumber = @mbnumber
        --AND (ivd_Charge <> 0)
  END

-- for master bills with 'RTP' status
IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
	IF @ivhrefnum IS Null
		--No reference numbers
		SELECT ivh.ivh_invoicenumber,  
				ivh.ivh_hdrnumber, 
		        ivh.ord_number,
		        ivh.ord_hdrnumber,
				ivh.ivh_billto,
				@mbnumber ivh_mbnumber,
				ivh.ivh_billdate,
				Case IsNumeric(IsNULL(ivh_terms,'UNK')) 
								when 1 then ivh_terms 
								else (Case IsNumeric(IsNULL(bill.cmp_terms,'UNK')) 
										when 1 then bill.cmp_terms 
										else 30 --default to 30
							  		  End )
							  End ivh_terms,
				--DATEADD(day, 21, ivh.ivh_billdate) ivh_duedate
				ivh.ivh_shipdate,   
				ivh.ivh_deliverydate,   
				ivh.ivh_revtype1,
				ivh.ivh_revtype3,
				ivh_revtype3_t= @Rev3title,
		        CASE (ivh.ivh_trailer)
					WHEN 'UNKNOWN' THEN ''
					ELSE ivh.ivh_trailer
				END ivh_trailer,
				ivh.ivh_originpoint,  
		 		orig.cty_nmstct origin_nmstct,
				orig.cty_state origin_state,
				ivh.ivh_origincity,  
				ivh.ivh_destpoint,   
				ivh.ivh_destcity,  
				dest.cty_nmstct dest_nmstct,
				dest.cty_state dest_state,
				ISNULL(ivd_charge, 0) AS ivd_charge,  
				billto_name = bill.cmp_name,
				billto_address = 
				    CASE
						WHEN bill.cmp_mailto_name IS NULL THEN ISNULL(bill.cmp_address1,'')
						WHEN (bill.cmp_mailto_name <= ' ') THEN ISNULL(bill.cmp_address1,'')
						ELSE ISNULL(bill.cmp_mailto_address1,'')
				    END,
				billto_address2 = 
					CASE
						WHEN bill.cmp_mailto_name IS NULL THEN ISNULL(bill.cmp_address2,'')
						WHEN (bill.cmp_mailto_name <= ' ') THEN ISNULL(bill.cmp_address2,'')
						ELSE ISNULL(bill.cmp_mailto_address2,'')
					END,
				 billto_address3 = 
					CASE
						WHEN bill.cmp_mailto_name IS NULL THEN ISNULL(bill.cmp_address3,'')
						WHEN (bill.cmp_mailto_name <= ' ') THEN ISNULL(bill.cmp_address3,'')
						ELSE ''
					END,
				 billto_nmstct = 
				    CASE
					WHEN bill.cmp_mailto_name IS NULL THEN 
					   ISNULL(SUBSTRING(bill.cty_nmstct,1,CASE
						WHEN CHARINDEX('/',bill.cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',bill.cty_nmstct) -1
						END),'')
					WHEN (bill.cmp_mailto_name <= ' ') THEN 
					   ISNULL(SUBSTRING(bill.cty_nmstct,1,CASE
						WHEN CHARINDEX('/',bill.cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',bill.cty_nmstct) -1
						END),'')
					ELSE ISNULL(SUBSTRING(bill.mailto_cty_nmstct,1,CASE
						WHEN CHARINDEX('/',bill.mailto_cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',bill.mailto_cty_nmstct) -1
						END),'')
				    END,
				billto_zip = 
					CASE
						WHEN bill.cmp_mailto_name IS NULL  THEN ISNULL(bill.cmp_zip ,'')  
						WHEN (bill.cmp_mailto_name <= ' ') THEN ISNULL(bill.cmp_zip,'')
						ELSE ISNULL(bill.cmp_mailto_zip,'')
					END,
				ivh_shipper_name = CASE(ship.cmp_name) 
								WHEN 'UNKNOWN' then ''
								ELSE ship.cmp_name
							 END,
				ivh_shipper_address = ISNULL(ship.cmp_address1,''),
			 	ivh_shipper_address2 = ISNULL(ship.cmp_address2,''),
				ivh_shipper_address3 = ISNULL(ship.cmp_address3,''),
			  	ivh_shipper_nmstct =  ISNULL(SUBSTRING(ship.cty_nmstct,1,CASE
												WHEN CHARINDEX('/',ship.cty_nmstct)- 1 < 0 THEN 0
												ELSE CHARINDEX('/',ship.cty_nmstct) -1 END),''),
				ivh_shipto_zip = ISNULL(ship.cmp_zip,''),
				ivh_consignee_name = CASE(consig.cmp_name) 
								WHEN 'UNKNOWN' then ''
								ELSE consig.cmp_name
							 END,
				ivh_consignee_address = ISNULL(consig.cmp_address1,''),
			 	ivh_consignee_address2 = ISNULL(consig.cmp_address2,''),
				ivh_consignee_address3 = ISNULL(consig.cmp_address3,''), 
	  			ivh_consignee_nmstct = ISNULL(SUBSTRING(consig.cty_nmstct,1,CASE
									WHEN CHARINDEX('/',consig.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',consig.cty_nmstct) -1
									END),''),
				ivh_consignee_zip = ISNULL(consig.cmp_zip,''),
				refnumber = '',
				ISNULL(bill.cmp_mailto_name,'') cmp_mailto_name,
				ivd_number,
				Case ivd_description 
					When 'UNKNOWN' Then cht.cht_description 
					When '' Then cht.cht_description
					Else ivd_description 
				End ivd_description,
				ivd_sequence,
				ivd_rate,
				ivd_quantity,
				cht.cht_basis,
                copy=1
		    FROM invoiceheader ivh
				JOIN invoicedetail ivd on ivd.ivh_hdrnumber = ivh.ivh_hdrnumber
				JOIN chargetype cht on cht.cht_itemcode = ivd.cht_itemcode
				JOIN company bill on bill.cmp_id = ivh.ivh_billto
				JOIN company ship on ship.cmp_id = ivh.ivh_shipper
				JOIN company consig on consig.cmp_id = ivh_consignee
				LEFT OUTER JOIN CITY orig  on orig.cty_code = ivh.ivh_origincity
				LEFT OUTER JOIN CITY dest on dest.cty_code = ivh.ivh_destcity
		   WHERE ( ivh.ivh_billto = @billto ) 
		     AND    ( IsNull(ivh.ivh_mbnumber,0) = 0   ) 
		     AND    ( ivh.ivh_shipdate between @shipstart AND @shipend ) 
		     AND    ( ivh.ivh_deliverydate between @delstart AND @delend ) 
		     AND     (ISNULL(ivh.ivh_mbstatus,'') = 'RTP')  
		     AND    (@revtype1 in (ivh.ivh_revtype1,'UNK')) 
		     AND (@revtype2 in (ivh.ivh_revtype2,'UNK')) 
		     AND (@revtype3 in (ivh.ivh_revtype3,'UNK'))
		     AND (@revtype4 in (ivh.ivh_revtype4,'UNK')) 
		     AND (@shipper IN(ivh.ivh_shipper,'UNKNOWN'))
		     AND (@consignee IN (ivh.ivh_consignee,'UNKNOWN'))
			 AND NOT EXISTS (SELECT 1 FROM referencenumber r
								WHERE (r.ref_tablekey = ivh.ivh_hdrnumber AND ref_table = 'invoiceheader')
								OR (r.ref_tablekey = ivh.ord_hdrnumber AND ref_table = 'orderheader')
								AND ref_type = @cmp_reftype)

		ELSE
			--Get reference numbers
			SELECT ivh.ivh_invoicenumber,  
				ivh.ivh_hdrnumber, 
		        ivh.ord_number,
		        ivh.ord_hdrnumber,
				ivh.ivh_billto,
				@mbnumber ivh_mbnumber,
				ivh.ivh_billdate,
				Case IsNumeric(IsNULL(ivh_terms,'UNK')) 
								when 1 then ivh_terms 
								else (Case IsNumeric(IsNULL(bill.cmp_terms,'UNK')) 
										when 1 then bill.cmp_terms 
										else 30 --default to 30
							  		  End )
							  End ivh_terms,
				--DATEADD(day, 21, ivh.ivh_billdate) ivh_duedate
				ivh.ivh_shipdate,   
				ivh.ivh_deliverydate,   
				ivh.ivh_revtype1,
				ivh.ivh_revtype3,
				ivh_revtype3_t= @Rev3title,
		        CASE (ivh.ivh_trailer)
					WHEN 'UNKNOWN' THEN ''
					ELSE ivh.ivh_trailer
				END ivh_trailer,
				ivh.ivh_originpoint,  
		 		orig.cty_nmstct origin_nmstct,
				orig.cty_state origin_state,
				ivh.ivh_origincity,  
				ivh.ivh_destpoint,   
				ivh.ivh_destcity,  
				dest.cty_nmstct dest_nmstct,
				dest.cty_state dest_state,
				ISNULL(ivd_charge, 0) AS ivd_charge,  
				billto_name = bill.cmp_name,
				billto_address = 
				    CASE
						WHEN bill.cmp_mailto_name IS NULL THEN ISNULL(bill.cmp_address1,'')
						WHEN (bill.cmp_mailto_name <= ' ') THEN ISNULL(bill.cmp_address1,'')
						ELSE ISNULL(bill.cmp_mailto_address1,'')
				    END,
				billto_address2 = 
					CASE
						WHEN bill.cmp_mailto_name IS NULL THEN ISNULL(bill.cmp_address2,'')
						WHEN (bill.cmp_mailto_name <= ' ') THEN ISNULL(bill.cmp_address2,'')
						ELSE ISNULL(bill.cmp_mailto_address2,'')
					END,
				 billto_address3 = 
					CASE
						WHEN bill.cmp_mailto_name IS NULL THEN ISNULL(bill.cmp_address3,'')
						WHEN (bill.cmp_mailto_name <= ' ') THEN ISNULL(bill.cmp_address3,'')
						ELSE ''
					END,
				 billto_nmstct = 
				    CASE
					WHEN bill.cmp_mailto_name IS NULL THEN 
					   ISNULL(SUBSTRING(bill.cty_nmstct,1,CASE
						WHEN CHARINDEX('/',bill.cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',bill.cty_nmstct) -1
						END),'')
					WHEN (bill.cmp_mailto_name <= ' ') THEN 
					   ISNULL(SUBSTRING(bill.cty_nmstct,1,CASE
						WHEN CHARINDEX('/',bill.cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',bill.cty_nmstct) -1
						END),'')
					ELSE ISNULL(SUBSTRING(bill.mailto_cty_nmstct,1,CASE
						WHEN CHARINDEX('/',bill.mailto_cty_nmstct)- 1 < 0 THEN 0
						ELSE CHARINDEX('/',bill.mailto_cty_nmstct) -1
						END),'')
				    END,
				billto_zip = 
					CASE
						WHEN bill.cmp_mailto_name IS NULL  THEN ISNULL(bill.cmp_zip ,'')  
						WHEN (bill.cmp_mailto_name <= ' ') THEN ISNULL(bill.cmp_zip,'')
						ELSE ISNULL(bill.cmp_mailto_zip,'')
					END,
				ivh_shipper_name = CASE(ship.cmp_name) 
								WHEN 'UNKNOWN' then ''
								ELSE ship.cmp_name
							 END,
				ivh_shipper_address = ISNULL(ship.cmp_address1,''),
			 	ivh_shipper_address2 = ISNULL(ship.cmp_address2,''),
				ivh_shipper_address3 = ISNULL(ship.cmp_address3,''),
	  			ivh_shipper_nmstct = ISNULL(SUBSTRING(ship.cty_nmstct,1,CASE
									WHEN CHARINDEX('/',ship.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',ship.cty_nmstct) -1
									END),''),
				ivh_shipto_zip = ISNULL(ship.cmp_zip,''),
				ivh_consignee_name = CASE(consig.cmp_name) 
								WHEN 'UNKNOWN' then ''
								ELSE consig.cmp_name
							 END,
				ivh_consignee_address = ISNULL(consig.cmp_address1,''),
			 	ivh_consignee_address2 = ISNULL(consig.cmp_address2,''),
				ivh_consignee_address3 = ISNULL(consig.cmp_address3,''), 
			  	ivh_consignee_nmstct =  ISNULL(SUBSTRING(consig.cty_nmstct,1,CASE
												WHEN CHARINDEX('/',consig.cty_nmstct)- 1 < 0 THEN 0
											ELSE CHARINDEX('/',consig.cty_nmstct) -1 END),''),
				ivh_consignee_zip = ISNULL(consig.cmp_zip,''),
				refnumber = case ivh.ivh_hdrnumber when 0 then iref.ref_number else oref.ref_number end  ,
				ISNULL(bill.cmp_mailto_name,'') cmp_mailto_name,
				ivd_number,
				Case ivd_description 
					When 'UNKNOWN' Then cht.cht_description 
					When '' Then cht.cht_description
					Else ivd_description 
				End ivd_description,
				ivd_sequence,
				ivd_rate,
				ivd_quantity,
				cht.cht_basis,
                copy = 1
		    FROM invoiceheader ivh
				JOIN invoicedetail ivd on ivd.ivh_hdrnumber = ivh.ivh_hdrnumber
				JOIN chargetype cht on cht.cht_itemcode = ivd.cht_itemcode
				JOIN company bill on bill.cmp_id = ivh.ivh_billto
				JOIN company ship on ship.cmp_id = ivh_shipper
				JOIN company consig on consig.cmp_id = ivh_consignee
				LEFT OUTER JOIN CITY orig  on orig.cty_code = ivh.ivh_origincity
				LEFT OUTER JOIN CITY dest on dest.cty_code = ivh.ivh_destcity
				LEFT OUTER JOIN (select  distinct ref_type,ref_number,ref_tablekey from referencenumber where ref_table = 'orderheader' and ref_type = @cmp_reftype and ref_number = @ivhrefnum) oref
                               on oref.ref_tablekey = ivh.ord_hdrnumber
				LEFT OUTER JOIN (select  distinct ref_type,ref_number,ref_tablekey from referencenumber where ref_table = 'invoiceheader' and ref_type = @cmp_reftype and ref_number = @ivhrefnum) iref
                               on iref.ref_tablekey = ivh.ivh_hdrnumber
		   WHERE ( ivh.ivh_billto = @billto ) 
		     AND    ( IsNull(ivh.ivh_mbnumber,0) = 0   ) 
		     AND    ( ivh.ivh_shipdate between @shipstart AND @shipend ) 
		     AND    ( ivh.ivh_deliverydate between @delstart AND @delend ) 
		     AND     (ISNULL(ivh.ivh_mbstatus,'') = 'RTP')  
		     AND    (@revtype1 in (ivh.ivh_revtype1,'UNK')) 
		     AND (@revtype2 in (ivh.ivh_revtype2,'UNK')) 
		     AND (@revtype3 in (ivh.ivh_revtype3,'UNK'))
		     AND (@revtype4 in (ivh.ivh_revtype4,'UNK')) 
		     AND (@shipper IN(ivh.ivh_shipper,'UNKNOWN'))
		     AND (@consignee IN (ivh.ivh_consignee,'UNKNOWN'))
		     And (oref.ref_number is not null or iref.ref_number is not null)
		
		  END

GO
GRANT EXECUTE ON  [dbo].[d_masterbill106_sp] TO [public]
GO
