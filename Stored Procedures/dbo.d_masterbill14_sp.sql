SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*          
                 CHANGE LOG
  
 11/28/00 dpete created pts9400 Written for Earth Transport who enters simple PUP/DROP
   orders after the fact.  They must print a single page with the total amount due followed by 
   multiple pages of detail. One line per invoice where we display the order number (called
   ticked #) insteadof the invoice number.  THere is only one commodity shipped.  THe master
  bill is all invoice for a bill to with the same origin, destination, commodity code.  These
  are passed as arguments.  THere is a job number on the printout.  It is supposed to be the
  same reference number (the first) on all orders with the origin/dest/commod. 

  The totalordetail is just a flag to identify the total amount line from the detail. It
  permits setting a page break on the datawindow, since the customer wants the total due on 
  a single sheet.

  THis is not likely to be useable by anyone else

 2/20/2001 pts10015 Earth Transport wants the bill date on the selection window to
        print ont he masterbill

*/

CREATE PROC [dbo].[d_masterbill14_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                       @revtype1 varchar(6), @revtype2 varchar(6),@mbstatus varchar(6),
	                       @shipstart datetime,@shipend datetime,@billdate datetime, 
                               @shipper varchar(8), @consignee varchar(8),
                               @copy int,@cmd_code varchar(8))
AS

DECLARE @int0  int, @level smallint
SELECT @int0 = 0, @level = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'
SELECT @cmd_code = ISNULL(@cmd_code,'UNKNOWN')





-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN
    SELECT 	totalordetail = 0,
		ord_number = '',
		ord_hdrnumber = 0,
		ivh_invoicenumber = '',  
		ivh_hdrnumber = 0, 
		ivh_billto = max(ivh_billto) ,
		ivh_shipper = max(ivh_shipper) ,
		ivh_consignee = max(ivh_consignee) ,   
		ivh_totalcharge = SUM(invoiceheader.ivh_totalcharge) ,   
		ivh_shipdate  = '19500101' ,   
		ivh_deliverydate = '19500101' ,
		mbnumber = @mbnumber,
		ivh_shipto_name = MAX(cmp2.cmp_name),
		ivh_billto_name = MAX(cmp1.cmp_name),
		ivh_billto_address = MAX(cmp1.cmp_address1),
		ivh_billto_address2 = MAX(cmp1.cmp_address2),
		ivh_billto_nmstct = MAX(ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   LEN(cmp1.cty_nmstct)
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
						      END),'')),
		ivh_billto_zip = MAX(cmp1.cmp_zip),
		ivh_consignee_name = MAX(cmp3.cmp_name),
		ivh_consignee_misc1 = MAX(cmp3.cmp_misc1),
		ivh_consignee_misc2 = MAX(cmp3.cmp_misc2),
		ivh_consignee_misc3 = MAX(cmp3.cmp_misc3),
		ivh_consignee_misc4 = MAX(cmp3.cmp_misc4),
		billdate = MAX(ivh_billdate)      ,
		ivh_quantity = SUM(ISNULL(ivh_quantity,0))  ,
		ivh_unit = MAX(ivh_unit) ,
		ivd_rate = MAX(ISNULL(ivd.ivd_rate,0)) ,
		ivd_rateunit = MAX(IsNull(ivd.ivd_rateunit, '')) ,
		cmd_code  = max(ord.cmd_code),
		cmd_description = MAX(ISNULL(cmd.cmd_name,'')) ,
		copy = @copy ,
		ivh_tractor = MAX(ivh_tractor),
		jobnumber = MAX(ivh_ref_number)
    FROM 	invoiceheader, 
		company cmp1,
		company cmp2,
		company cmp3,
		invoicedetail ivd,
		orderheader ord,
		commodity cmd
   WHERE	( invoiceheader.ivh_mbnumber = @mbnumber )
		AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		AND (ord.ord_hdrnumber = invoiceheader.ord_hdrnumber)
		AND (ivd.ivd_type = 'SUB')
		AND (cmd.cmd_code = ord.cmd_code)
		AND (cmp1.cmp_id = invoiceheader.ivh_billto) 
		AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
		AND (cmp3.cmp_id = invoiceheader.ivh_consignee) 
   -- ORDER BY  ivh_shipdate, ord_number	

	
    UNION
    SELECT 	totalordetail = 1,
		ord_number = IsNull(invoiceheader.ord_number, ''),
		ord_hdrnumber = IsNull(invoiceheader.ord_hdrnumber, -1),
		ivh_invoicenumber = invoiceheader.ivh_invoicenumber,  
		ivh_hdrnumber = invoiceheader.ivh_hdrnumber, 
		ivh_billto = invoiceheader.ivh_billto ,
		ivh_shipper = invoiceheader.ivh_shipper ,
		ivh_consignee = invoiceheader.ivh_consignee ,   
		ivh_totalcharge = invoiceheader.ivh_totalcharge ,   
		ivh_shipdate = invoiceheader.ivh_shipdate ,   
		ivh_deliverydate = invoiceheader.ivh_deliverydate,
		mbnumber = invoiceheader.ivh_mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
		ivh_billto_name = cmp1.cmp_name,
		ivh_billto_address = cmp1.cmp_address1,
		ivh_billto_address2 = cmp1.cmp_address2,
		ivh_billto_nmstct = ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   LEN(cmp1.cty_nmstct)
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
						      END),''),
		ivh_billto_zip = cmp1.cmp_zip,
		ivh_consignee_name = cmp3.cmp_name,
		ivh_consignee_misc1 = cmp3.cmp_misc1,
		ivh_consignee_misc2 = cmp3.cmp_misc2,
		ivh_consignee_misc3 = cmp3.cmp_misc3,
		ivh_consignee_misc4 = cmp3.cmp_misc4,
		billdate = ivh_billdate      ,
		ivh_quantity = ISNULL(ivh_quantity,0)  ,
		ivh_unit = ISNULL(ivh_unit,'UNK') ,
		ivd_rate = ISNULL(ivd.ivd_rate,0) ,
		ivd_rateunit = IsNull(ivd.ivd_rateunit, '') ,
		cmd_code = ord.cmd_code,
		cmd_description = ISNULL(cmd.cmd_name,'') ,
		copy = @copy ,
		ivh_tractor,
		jobnumber = ivh_ref_number
    FROM 	invoiceheader, 
		company cmp1,
		company cmp2,
		company cmp3,
		invoicedetail ivd,
		orderheader ord,
		commodity cmd
   WHERE	( invoiceheader.ivh_mbnumber = @mbnumber )
		AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		AND (ord.ord_hdrnumber = invoiceheader.ord_hdrnumber)
		AND (ivd.ivd_type = 'SUB')
		AND (cmd.cmd_code = ord.cmd_code)
		AND (cmp1.cmp_id = invoiceheader.ivh_billto) 
		AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
		AND (cmp3.cmp_id = invoiceheader.ivh_consignee) 
   ORDER BY  ivh_shipdate, ord_number
		

  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
     SELECT 	totalordetail = 0,
		ord_number = '',
		ord_hdrnumber = 0,
		ivh_invoicenumber = '',  
		ivh_hdrnumber = 0, 
		ivh_billto = @billto ,
		ivh_shipper = @shipper ,
		ivh_consignee = @consignee ,   
		ivh_totalcharge = SUM(invoiceheader.ivh_totalcharge) ,   
		ivh_shipdate  = '19500101' ,   
		ivh_deliverydate = '19500101' ,
		mbnumber = @mbnumber,
		ivh_shipto_name = MAX(cmp2.cmp_name),
		ivh_billto_name = MAX(cmp1.cmp_name),
		ivh_billto_address = MAX(cmp1.cmp_address1),
		ivh_billto_address2 = MAX(cmp1.cmp_address2),
		ivh_billto_nmstct = MAX(ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   LEN(cmp1.cty_nmstct)
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
						      END),'')),
		ivh_billto_zip = MAX(cmp1.cmp_zip),
		ivh_consignee_name = MAX(cmp3.cmp_name),
		ivh_consignee_misc1 = MAX(cmp3.cmp_misc1),
		ivh_consignee_misc2 = MAX(cmp3.cmp_misc2),
		ivh_consignee_misc3 = MAX(cmp3.cmp_misc3),
		ivh_consignee_misc4 = MAX(cmp3.cmp_misc4),
		billdate = @billdate,    -- 10015 MAX(ivh_billdate)      ,
		ivh_quantity = SUM(ISNULL(ivh_quantity,0))  ,
		ivh_unit = MAX(ivh_unit) ,
		ivd_rate = MAX(ISNULL(ivd.ivd_rate,0)) ,
		ivd_rateunit = MAX(IsNull(ivd.ivd_rateunit, '')) ,
		cmd_code  = @cmd_code,
		cmd_description = MAX(ISNULL(cmd.cmd_name,'')) ,
		copy = @copy,
		ivh_tractor = MAX(ivh_tractor),
		jobnumber = MAX(ivh_ref_number)
	FROM 	invoiceheader, 
		(SELECT cmp_id, cmp_name, cmp_address1, cmp_address2, cty_nmstct,cmp_zip FROM company WHERE cmp_id = @billto) cmp1,
		(SELECT cmp_id, cmp_name FROM company WHERE cmp_id = @shipper) cmp2,
		(SELECT cmp_id, cmp_name, cmp_misc1,cmp_misc2,cmp_misc3,cmp_misc4 FROM company WHERE cmp_id = @consignee) cmp3,
		invoicedetail ivd, 
		orderheader ord,
		(SELECT cmd_code, cmd_name FROM commodity WHERE cmd_code = @cmd_code) cmd
	WHERE 	( invoiceheader.ivh_billto = @billto )  
		AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		AND (ord.ord_hdrnumber = invoiceheader.ord_hdrnumber)
		AND (ord.cmd_code = @cmd_code)
		AND (ivd.ivd_type = 'SUB')
		AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
		AND     (invoiceheader.ivh_mbstatus = 'RTP')  
		AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
		AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK')) 
		AND (cmp1.cmp_id = invoiceheader.ivh_billto)
		AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
	 	AND (cmp3.cmp_id = invoiceheader.ivh_consignee)
		AND (invoiceheader.ivh_shipper = @shipper )
		AND (invoiceheader.ivh_consignee = @consignee )
		AND (cmd.cmd_code = @cmd_code)
--    ORDER BY  ivh_shipdate, ord_number


    UNION
     SELECT 	totalordetail = 1,
		ord_number = IsNull(invoiceheader.ord_number, ''),
		ord_hdrnumber = IsNull(invoiceheader.ord_hdrnumber, -1),
		ivh_invoicenumber = invoiceheader.ivh_invoicenumber,  
		ivh_hdrnumber = invoiceheader.ivh_hdrnumber, 
		ivh_billto = invoiceheader.ivh_billto ,
		ivh_shipper = invoiceheader.ivh_shipper ,
		ivh_consignee = invoiceheader.ivh_consignee ,   
		ivh_totalcharge = invoiceheader.ivh_totalcharge ,   
		ivh_shipdate = invoiceheader.ivh_shipdate ,   
		ivh_deliverydate = invoiceheader.ivh_deliverydate,
		mbnumber = @mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
		ivh_billto_name = cmp1.cmp_name,
		ivh_billto_address = cmp1.cmp_address1,
		ivh_billto_address2 = cmp1.cmp_address2,
		ivh_billto_nmstct = ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   LEN(cmp1.cty_nmstct)
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
						      END),''),
		ivh_billto_zip = cmp1.cmp_zip,
		ivh_consignee_name = cmp3.cmp_name,
		ivh_consignee_misc1 = cmp3.cmp_misc1,
		ivh_consignee_misc2 = cmp3.cmp_misc2,
		ivh_consignee_misc3 = cmp3.cmp_misc3,
		ivh_consignee_misc4 = cmp3.cmp_misc4,
		billdate = @billdate,  --10015  ivh_billdate      ,
		ivh_quantity = ISNULL(ivh_quantity,0)  ,
		ivh_unit = ISNULL(ivh_unit,'UNK') ,
		ivd_rate = ISNULL(ivd.ivd_rate,0) ,
		ivd_rateunit = IsNull(ivd.ivd_rateunit, '') ,
		cmd_code = @cmd_code,
		cmd_description = ISNULL(cmd.cmd_name,'') ,
		copy = @copy ,
		ivh_tractor,
		jobnumber = ivh_ref_number
	FROM 	invoiceheader, 
		(SELECT cmp_id, cmp_name, cmp_address1, cmp_address2, cty_nmstct,cmp_zip FROM company WHERE cmp_id = @billto) cmp1,
		(SELECT cmp_id, cmp_name FROM company WHERE cmp_id = @shipper) cmp2,
		(SELECT cmp_id, cmp_name, cmp_misc1,cmp_misc2,cmp_misc3,cmp_misc4 FROM company WHERE cmp_id = @consignee) cmp3,
		invoicedetail ivd, 
		orderheader ord,
		(SELECT cmd_code, cmd_name FROM commodity WHERE cmd_code = @cmd_code) cmd
	WHERE 	( invoiceheader.ivh_billto = @billto )  
		AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		AND (ivd.ivd_type = 'SUB')
		AND (ord.ord_hdrnumber = invoiceheader.ord_hdrnumber)
		AND (ord.cmd_code = @cmd_code)
		AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
		AND     (invoiceheader.ivh_mbstatus = 'RTP')  
		AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
		AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK')) 
		AND (cmp1.cmp_id = invoiceheader.ivh_billto)
		AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
	 	AND (cmp3.cmp_id = invoiceheader.ivh_consignee)
		AND (cmd.cmd_code = @cmd_code)
		AND (invoiceheader.ivh_shipper = @shipper )
		AND (invoiceheader.ivh_consignee = @consignee )
	ORDER BY  ivh_shipdate, ord_number

  END

  
GO
GRANT EXECUTE ON  [dbo].[d_masterbill14_sp] TO [public]
GO
