SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


create procedure [dbo].[d_masterbill122_sp](@reprintflag varchar(10),
												@mbnumber int,
												@billto varchar(8), 
												@mbstatus varchar(6),
												@shipstart datetime,
												@shipend datetime,
												@delstart datetime, 
												@delend datetime,
												@billdate datetime,
												@billstart datetime, 
												@billend datetime,
												@revtype1 varchar(6), 
												@revtype2 varchar(6),
												@revtype3 varchar(6), 
												@revtype4 varchar(6),
												@shipper varchar(8), 
												@consignee varchar(8),
												@orderby varchar(8),
												@copy int)
as

/**
 * 
 * NAME:
 * dbo.d_masterbill122_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Return data for Masterbill 122, breaking on consignee .
 *
 * RETURNS:
 *
 * RESULT SETS: 
 * See select statement
 *
 * PARAMETERS:
 *
 *
 * REFERENCES: 
 * NONE
 * 
 * REVISION HISTORY:
 * 10/08/2008 pmill created master bill format 122 for Wills Trucking, Inc. 
 *                  This master bill was created from scratch, not based on an existing format
 * 1/30/09 PTS 45782 add WTIC ref number to printout
 **/  

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'
SELECT @delstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @delend   = convert(char(12),@shipend  )+'23:59:59'
SELECT @billstart = convert(char(12), @billstart ) +'00:00:00'
SELECT @billend = convert(char(12),@billend  )+'23:59:59'

IF UPPER(@reprintflag) = 'REPRINT' 
BEGIN
	SELECT	ivh.ivh_invoicenumber,  
				ivh.ivh_hdrnumber, 
				ivh.ord_number,
				ivh.ord_hdrnumber,
				ivh.ivh_billto,
				ivh.ivh_mbnumber,
				@billdate billdate,
				ivh.ivh_shipdate,   
				ivh.ivh_deliverydate,
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
				cht.cht_primary,
				ivd_type,
				cht.cht_rollintolh,
				ord.ord_description,
				ord.ord_totalweight,
				cht.cht_rateunit,
				ivd.cht_itemcode,
				@copy,
                wticref = isnull((select top 1 ref_number from referencenumber
                      where ref_table = 'orderheader' and ref_type = 'WTIC'
                      and ref_tablekey = ivh.ord_hdrnumber),ivh_invoicenumber)

    FROM invoiceheader ivh
			JOIN invoicedetail ivd on ivd.ivh_hdrnumber = ivh.ivh_hdrnumber
			JOIN chargetype cht on cht.cht_itemcode = ivd.cht_itemcode
			JOIN company bill on bill.cmp_id = ivh.ivh_billto
			JOIN company consig on consig.cmp_id = ivh_consignee
			JOIN orderheader ord on ord.ord_hdrnumber = ivh.ord_hdrnumber
   WHERE ivh.ivh_mbnumber = @mbnumber
			AND ( IsNull(ivd.ivd_charge, 0) > 0)
        
  END

-- for master bills with 'RTP' status
IF UPPER(@reprintflag) <> 'REPRINT' 
BEGIN
	SELECT	ivh.ivh_invoicenumber,  
				ivh.ivh_hdrnumber, 
				ivh.ord_number,
				ivh.ord_hdrnumber,
				ivh.ivh_billto,
				@mbnumber ivh_mbnumber,
				@billdate billdate,
				ivh.ivh_shipdate,   
				ivh.ivh_deliverydate,
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
				cht.cht_primary,
				ivd_type,
				cht.cht_rollintolh,
				ord.ord_description,
				ord.ord_totalweight,
				cht.cht_rateunit,
				ivd.cht_itemcode,
				@copy,
                wticref = isnull((select top 1 ref_number from referencenumber
                      where ref_table = 'orderheader' and ref_type = 'WTIC'
                      and ref_tablekey = ivh.ord_hdrnumber),ivh_invoicenumber)

    FROM invoiceheader ivh
			JOIN invoicedetail ivd on ivd.ivh_hdrnumber = ivh.ivh_hdrnumber
			JOIN chargetype cht on cht.cht_itemcode = ivd.cht_itemcode
			JOIN company bill on bill.cmp_id = ivh.ivh_billto
			JOIN company consig on consig.cmp_id = ivh_consignee
			JOIN orderheader ord on ord.ord_hdrnumber = ivh.ord_hdrnumber
   WHERE  (ivh.ivh_billto = @billto ) 
     	AND ( IsNull(ivh.ivh_mbnumber,0) = 0 ) 
     	AND ( ivh.ivh_shipdate between @shipstart AND @shipend ) 
     	AND ( ivh.ivh_deliverydate between @delstart AND @delend ) 
		AND ( ivh.ivh_billdate between @billstart AND @billend)
     	AND ( ivh.ivh_mbstatus = 'RTP')  
     	AND ( @revtype1 in (ivh.ivh_revtype1,'UNK') ) 
     	AND ( @revtype2 in (ivh.ivh_revtype2,'UNK') ) 
		AND ( @revtype3 in (ivh.ivh_revtype3,'UNK') )
     	AND ( @revtype4 in (ivh.ivh_revtype4,'UNK') ) 
     	AND ( @shipper in (ivh.ivh_shipper,'UNKNOWN') )
		AND ( @orderby in (ivh.ivh_order_by, 'UNKNOWN') )
		AND ( @consignee = ivh.ivh_consignee)
		AND ( IsNull(ivd.ivd_charge, 0) > 0)
END

GO
GRANT EXECUTE ON  [dbo].[d_masterbill122_sp] TO [public]
GO
