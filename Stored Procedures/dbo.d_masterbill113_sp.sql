SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE      PROC [dbo].[d_masterbill113_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                       @revtype1 varchar(6), @revtype2 varchar(6),@mbstatus varchar(6),
	                       @shipstart datetime,@shipend datetime,@billdate datetime, 
                               @shipper varchar(8), @consignee varchar(8),
                               @copy int,@ivh_invoicenumber varchar(12))
AS

/*
 * 
 * NAME:D_MASTERBILL113_SP
 * dbo.
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return SET of all the invoices a master bill.
 * 
 *
 * RETURNS:
 * 0 - IF NO DATA WAS FOUND  
 * 1 - IF SUCCESFULLY EXECUTED  
 * @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS  
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @reprintflag, varchar, input;
 *       Is the masterbill a reprint
 * 002 - @mbnumber, int, input;
 *       Masterbill number
 * 003 - @billto, varchar, input;
 *	 Masterbill Billto
 * 004 - @revtype1, varchar, input, NULL;
 *       Revtype 1
 * 005 - @revtype2, varchar, input, NULL;
 *	 Revtype 2
 * 006 - @mbstatus, varchar, input;
 *	 Status of mastebill RTP, PRN, etc.
 * 007 - @shipstart, datetime, input, 01/01/1950;
 *
 * 008 - @shipend, datetime, input, 12/31/2049;
 *
 * 009 - @billdate, datetime, input, currentdate;
 *
 * 010 - @shipper, varchar, input, NULL;
 *	 invoice shipper
 * 011 - @consignee, varchar, input, NULL;
 * 	 invoice consignee
 * 012 - @copy, int, input, NULL;
 *	 Number of copies
 * 013 - @ivh_invoicenumber, varchar, input, NULL;
 *
 * REFERENCES: (called by AND calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * 2/21/08 BDH pts 39699.  Created this proc for mb113 from mb100.
 * This proc is used for masterbill formats 113-117.
 **/
SET NOCOUNT ON


SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'


CREATE TABLE #masterbill_temp (		
	ord_hdrnumber int,
	ivh_invoicenumber varchar(12),  
	ivh_hdrnumber int NULL, 
	ivh_mbnumber int NULL,
	billdate datetime NULL,
	startdate datetime null,
	enddate datetime null,
	billto_cmp_altid varchar(25) NULL,
	po_num  varchar(30) null,
	ivh_billto varchar(8) NULL,
	ivh_shipper varchar(8) NULL,
	ivh_consignee varchar(8) NULL,
	ivh_billto_name varchar(100)  NULL,		
	ivh_billto_address varchar(100) NULL,
	ivh_billto_address2 varchar(100) NULL,
	ivh_billto_nmstct varchar(30) NULL ,
	ivh_billto_zip varchar(10) NULL,
	ivh_shipper_name varchar(100) NULL ,
	ivh_shipper_nmstct varchar(30) NULL ,
	ivh_consignee_name varchar(100)  NULL,
	ivh_consignee_nmstct varchar(30)  NULL,
	bl_num varchar(30) null,
	ref_num varchar(30) null,
	backhaul_num varchar(30) null,
	ivh_deliverydate datetime NULL,   
	cmd_name varchar(60) NULL,  
	lh_weight float NULL, 
	bill_quantity float  NULL,
	lh_rateunit char(6) NULL,  
	lh_rate money null,
	lh_total money null,
	fsc_rate money null,
	fsc_amount money null,
	ivh_totalcharge money NULL,
	ivh_remark varchar(254) null,
	copy int NULL)

if UPPER(@reprintflag) = 'REPRINT' 
BEGIN

	insert #masterbill_temp (		
	ord_hdrnumber,
	ivh_invoicenumber,  
	ivh_hdrnumber, 
	ivh_mbnumber,
	billdate,
	startdate,
	enddate,
	billto_cmp_altid,
-- 	ivh_billto,
-- 	ivh_shipper,
-- 	ivh_consignee,
	ivh_billto_name,		
	ivh_billto_address,
	ivh_billto_address2,
	ivh_billto_nmstct,
	ivh_billto_zip,
	ivh_shipper_name,
	ivh_shipper_nmstct,
	ivh_consignee_name,
	ivh_consignee_nmstct,
 	bl_num,
 	ref_num,
 	backhaul_num,
	po_num,
	ivh_deliverydate,   
	cmd_name,
 	lh_weight,
	ivh_totalcharge,
	ivh_remark,
	copy )

	select
	IsNull(invoiceheader.ord_hdrnumber, -1),
	invoiceheader.ivh_invoicenumber,  
	invoiceheader.ivh_hdrnumber, 
	invoiceheader.ivh_mbnumber,
	ivh_billdate      billdate,
	@shipstart,
	@shipend,
	cmp1.cmp_altid,

	ivh_billto_name = CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_name,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_name,'')
		ELSE ISNULL(cmp1.cmp_mailto_name,'')
	    END,
	ivh_billto_address = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 ivh_billto_address2 = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	ivh_billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
			END),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
			END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) -1
			END),'')
	    END,
	ivh_billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
	ivh_shipto_name = cmp2.cmp_name,
	ivh_shipto_nmstct = ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
									WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
									END),''),
	ivh_consignee_name = cmp3.cmp_name,
	ivh_consignee_nmstct = ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
			END),''),
	bl_num = (select ref_number from referencenumber
	where ref_table = 
	case invoiceheader.ord_hdrnumber
		when 0 then 'invoiceheader'
		else 'orderheader'
		end
	and ref_tablekey = 
	case invoiceheader.ord_hdrnumber
		when 0 then invoiceheader.ivh_hdrnumber
		else invoiceheader.ord_hdrnumber
		end
		and referencenumber.ref_type = 'BL#'),
	ref_num = (select ref_number from referencenumber
	where ref_table = 
	case invoiceheader.ord_hdrnumber
		when 0 then 'invoiceheader'
		else 'orderheader'
		end
	and ref_tablekey = 
	case invoiceheader.ord_hdrnumber
		when 0 then invoiceheader.ivh_hdrnumber
		else invoiceheader.ord_hdrnumber
		end
		and referencenumber.ref_type = 'REF'),
	backhaul_num = (select ref_number from referencenumber
	where ref_table = 
	case invoiceheader.ord_hdrnumber
		when 0 then 'invoiceheader'
		else 'orderheader'
		end
	and ref_tablekey = 
	case invoiceheader.ord_hdrnumber
		when 0 then invoiceheader.ivh_hdrnumber
		else invoiceheader.ord_hdrnumber
		end
		and referencenumber.ref_type = 'BKHL'),
	po_num = (select ref_number from referencenumber
	where ref_table = 
	case invoiceheader.ord_hdrnumber
		when 0 then 'invoiceheader'
		else 'orderheader'
		end
	and ref_tablekey = 
	case invoiceheader.ord_hdrnumber
		when 0 then invoiceheader.ivh_hdrnumber
		else invoiceheader.ord_hdrnumber
		end
		and referencenumber.ref_type = 'PO'),
	invoiceheader.ivh_deliverydate,   
	cmd.cmd_name,
	invoiceheader.ivh_totalweight,
	invoiceheader.ivh_totalcharge,
	invoiceheader.ivh_remark,
	@copy 

	FROM invoiceheader 
			INNER JOIN company cmp1 ON invoiceheader.ivh_billto = cmp1.cmp_id 
			INNER JOIN company cmp2 ON invoiceheader.ivh_shipper = cmp2.cmp_id 
			INNER JOIN company cmp3 ON invoiceheader.ivh_consignee = cmp3.cmp_id 
			INNER JOIN city cty1 ON invoiceheader.ivh_origincity = cty1.cty_code 
			INNER JOIN city cty2 ON invoiceheader.ivh_destcity = cty2.cty_code 
			LEFT OUTER JOIN commodity cmd ON ivh_order_cmd_code = cmd.cmd_code
		
	WHERE     (invoiceheader.ivh_mbnumber = @mbnumber) 
				AND (@shipper IN (invoiceheader.ivh_shipper, 'UNKNOWN')) 
				AND (@consignee IN (invoiceheader.ivh_consignee, 'UNKNOWN')) 
end
if UPPER(@reprintflag) <> 'REPRINT' 
BEGIN
	insert #masterbill_temp (		
	ord_hdrnumber,
	ivh_invoicenumber,  
	ivh_hdrnumber, 
	ivh_mbnumber,
	billdate,
	startdate,
	enddate,
	billto_cmp_altid,
-- 	ivh_billto,
-- 	ivh_shipper,
-- 	ivh_consignee,
	ivh_billto_name,		
	ivh_billto_address,
	ivh_billto_address2,
	ivh_billto_nmstct,
	ivh_billto_zip,
	ivh_shipper_name,
	ivh_shipper_nmstct,
	ivh_consignee_name,
	ivh_consignee_nmstct,
 	bl_num,
 	ref_num,
 	backhaul_num,
	po_num,
	ivh_deliverydate,   
	cmd_name,
 	lh_weight,
	ivh_totalcharge,
	ivh_remark,
	copy )

	select
	IsNull(invoiceheader.ord_hdrnumber, -1),
	invoiceheader.ivh_invoicenumber,  
	invoiceheader.ivh_hdrnumber, 
	@mbnumber     ivh_mbnumber,--invoiceheader.ivh_mbnumber,
	ivh_billdate      billdate,
	@shipstart,
	@shipend,
	cmp1.cmp_altid,

	ivh_billto_name = CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_name,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_name,'')
		ELSE ISNULL(cmp1.cmp_mailto_name,'')
	    END,
	ivh_billto_address = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 ivh_billto_address2 = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	ivh_billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
			END),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
			END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) -1
			END),'')
	    END,
	ivh_billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
	ivh_shipto_name = cmp2.cmp_name,
	ivh_shipto_nmstct = ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
									WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
									END),''),
	ivh_consignee_name = cmp3.cmp_name,
	ivh_consignee_nmstct = ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
			END),''),
	bl_num = (select ref_number from referencenumber
		where ref_table = 
		case invoiceheader.ord_hdrnumber
			when 0 then 'invoiceheader'
			else 'orderheader'
			end
		and ref_tablekey = 
		case invoiceheader.ord_hdrnumber
			when 0 then invoiceheader.ivh_hdrnumber
			else invoiceheader.ord_hdrnumber
			end
			and referencenumber.ref_type = 'BL#'),
	ref_num = (select ref_number from referencenumber
		where ref_table = 
		case invoiceheader.ord_hdrnumber
			when 0 then 'invoiceheader'
			else 'orderheader'
			end
		and ref_tablekey = 
		case invoiceheader.ord_hdrnumber
			when 0 then invoiceheader.ivh_hdrnumber
			else invoiceheader.ord_hdrnumber
			end
			and referencenumber.ref_type = 'REF'),
	backhaul_num = (select ref_number from referencenumber
		where ref_table = 
		case invoiceheader.ord_hdrnumber
			when 0 then 'invoiceheader'
			else 'orderheader'
			end
		and ref_tablekey = 
		case invoiceheader.ord_hdrnumber
			when 0 then invoiceheader.ivh_hdrnumber
			else invoiceheader.ord_hdrnumber
			end
			and referencenumber.ref_type = 'BKHL'),
	po_num = (select ref_number from referencenumber
	where ref_table = 
	case invoiceheader.ord_hdrnumber
		when 0 then 'invoiceheader'
		else 'orderheader'
		end
	and ref_tablekey = 
	case invoiceheader.ord_hdrnumber
		when 0 then invoiceheader.ivh_hdrnumber
		else invoiceheader.ord_hdrnumber
		end
		and referencenumber.ref_type = 'PO'),
	invoiceheader.ivh_deliverydate,   
	cmd.cmd_name,
	invoiceheader.ivh_totalweight,
	invoiceheader.ivh_totalcharge,
	invoiceheader.ivh_remark,
	@copy 

	FROM invoiceheader 
			INNER JOIN company cmp1 ON invoiceheader.ivh_billto = cmp1.cmp_id 
			INNER JOIN company cmp2 ON invoiceheader.ivh_shipper = cmp2.cmp_id 
			INNER JOIN company cmp3 ON invoiceheader.ivh_consignee = cmp3.cmp_id 
			INNER JOIN city cty1 ON invoiceheader.ivh_origincity = cty1.cty_code 
			INNER JOIN city cty2 ON invoiceheader.ivh_destcity = cty2.cty_code 
			LEFT OUTER JOIN commodity cmd ON ivh_order_cmd_code = cmd.cmd_code
	WHERE @shipper IN (invoiceheader.ivh_shipper, 'UNKNOWN') 
				AND (invoiceheader.ivh_billto = @billto )  
				AND @consignee IN (invoiceheader.ivh_consignee, 'UNKNOWN')
				AND @ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master')
				AND invoiceheader.ivh_deliverydate between @shipstart AND @shipend  -- PTS 38242 -- SGB 
				AND invoiceheader.ivh_mbstatus = 'RTP'  
				AND @revtype1 in (invoiceheader.ivh_revtype1,'UNK')
				AND @revtype2 in (invoiceheader.ivh_revtype2,'UNK') 




end


update #masterbill_temp
set fsc_rate = ivd_rate,
fsc_amount = ivd_charge
from invoicedetail 
where #masterbill_temp.ord_hdrnumber = invoicedetail.ord_hdrnumber 
and invoicedetail.cht_itemcode in ('FSCREV', 'FSCMIL')


update #masterbill_temp
set lh_rate = ivd_rate,
lh_total = ivd_charge,
lh_rateunit = ivd_rateunit,
bill_quantity = ivd_quantity

from invoicedetail, chargetype 
where #masterbill_temp.ord_hdrnumber = invoicedetail.ord_hdrnumber 
and invoicedetail.cht_itemcode = chargetype.cht_itemcode
and chargetype.cht_primary = 'Y'
and invoicedetail.cht_itemcode <> 'DEL'




  SELECT * 
  FROM		#masterbill_temp
  --ORDER BY	ord_hdrnumber, ivd_sequence

  DROP TABLE #masterbill_temp

GO
GRANT EXECUTE ON  [dbo].[d_masterbill113_sp] TO [public]
GO
