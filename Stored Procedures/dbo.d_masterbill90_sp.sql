SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill90_sp] (@reprintflag varchar(10),
                               @mbnumber int,
                               @billto varchar(8), 
	                       @revtype1 varchar(6), 
                               @revtype2 varchar(6),
                               @mbstatus varchar(6),
	                       @shipstart datetime,
                               @shipend datetime,
                               @billdate datetime, 
                               @shipper varchar(8), 
                               @consignee varchar(8),
                               @copy int,
                               @ivh_invoicenumber varchar(12),
			       @p_delstart datetime, 
			       @p_delend datetime,
			       @p_revtype3 varchar(6), 
		               @p_revtype4 varchar(6),
					@p_ivsnumber int)
AS

/**
 * 
 * NAME:
 * dbo.d_masterbill90_sp
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
 * 009 - @billdate datetime, 
 * 010 - @shipper varchar(8), 
 * 011 - @consignee varchar(8),
 * 012 - @copy int,
 * 013 - @ivh_invoicenumber varchar(12)
 * 014 - @p_delstart datetime 
 * 015 - @p_delend datetime
 * 016 - @p_revtype3 varchar(6)
 * 017 - @p_revtype4 varchar(6)
 *
 * REFERENCES:
 * NONE
 * 
 * REVISION HISTORY:
 * 08/14/2006.01 - PTS33367 - ILB - Created stored proc for use with Master Bill Format 90, which is inherited
 *                                  from masterbill format 44.
 * 11/17/2006.01 - PTS35176 - PRB - Added delivery date and revtypes 3 and 4 for filtering.
 * 12/04/2006.02 - PTS35176 - PRB - Fixed two issues with SQL.  Substring not check nulls, and Subquery returned more than
 *                                - 1 value.
 * 11/09/2007.01 - PTS37555 - EMK - Pass in invoice selection number to get correct terms/remitto
 **/

DECLARE @int0  int
SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'
--PRB PTS35176
Select @p_delstart = convert(char(12),@p_delstart)+'00:00:00'  
Select @p_delend   = convert(char(12),@p_delend  )+'23:59:59'
--END PTS35176

CREATE TABLE #masterbill_temp (		ord_hdrnumber int,
		ivh_invoicenumber varchar(12),  
		ivh_hdrnumber int NULL, 
		ivh_billto varchar(8) NULL,
		ivh_shipper varchar(8) NULL,
		ivh_consignee varchar(8) NULL,
		ivh_totalcharge money NULL,   
		ivh_originpoint  varchar(8) NULL,  
		ivh_destpoint varchar(8) NULL,   
		ivh_origincity int NULL,   
		ivh_destcity int NULL,   
		ivh_shipdate datetime NULL,   
		ivh_deliverydate datetime NULL,   
		ivh_revtype1 varchar(6) NULL,
		ivh_mbnumber int NULL,
		--PTS 26041 START Made size adjustments for columns to match storage sizes
		ivh_shipper_name varchar(100) NULL ,
		ivh_shipper_address varchar(100) NULL,
		ivh_shipper_address2 varchar(100) NULL,
		ivh_shipper_nmstct varchar(36) NULL ,
		ivh_shipper_zip varchar(10) NULL,
		ivh_billto_name varchar(100)  NULL,
		ivh_billto_address varchar(100) NULL,
		ivh_billto_address2 varchar(100) NULL,
		ivh_billto_address3 varchar(100) NULL,
		ivh_billto_nmstct varchar(36) NULL ,
		ivh_billto_zip varchar(10) NULL,
		ivh_consignee_name varchar(100)  NULL,
		ivh_consignee_address varchar(100) NULL,
		ivh_consignee_address2 varchar(100) NULL,
		ivh_consignee_nmstct varchar(36)  NULL,
		ivh_consignee_zip varchar(10) NULL,
		--PTS 26041 END Made size adjustments for columns to match storage sizes
		ivh_ref_number varchar(30) NULL,
		--PTS 26041 START Made size adjustments for columns to match storage sizes
		origin_nmstct varchar(36) NULL,
		--PTS 26041 END Made size adjustments for columns to match storage sizes
		origin_state varchar(2) NULL,
		--PTS 26041 START Made size adjustments for columns to match storage sizes
		dest_nmstct varchar(36) NULL,
		--PTS 26041 END Made size adjustments for columns to match storage sizes
		dest_state varchar(2) NULL,
		billdate datetime NULL,
		cmp_mailto_name varchar(30) NULL,
		bill_quantity float  NULL,
		ivd_weight float NULL,
		ivd_weightunit char(6) NULL,
		ivd_count float NULL,
		ivd_countunit char(6) NULL,
		ivd_volume float NULL,
		ivd_volunit char(6) NULL,
		ivd_unit char(6) NULL,
		ivd_rate money NULL,
		ivd_rateunit char(6) NULL,
		ivd_charge money NULL,
		cht_description varchar(30) NULL,
		cht_primary char(1) NULL,
		cmd_name varchar(60)  NULL,
		--vmj1+
		ivd_description varchar(60) NULL,
--		ivd_description varchar(30) NULL,
		--vmj1-
		ivd_type char(6) NULL,
		stp_city int NULL,
		--PTS 26041 START Made size adjustments for columns to match storage sizes
		stp_cty_nmstct varchar(36) NULL,
		--PTS 26041 END Made size adjustments for columns to match storage sizes
		ivd_sequence int NULL,
		stp_number int NULL,
		copy int NULL,
		cmp_id varchar(8) NULL,
		cmd_code varchar(60) NULL,
		ivh_tractor varchar(8) NULL,
		billto_altid varchar(25) NULL,
		ord_totalweight float NULL,
                mov_number int NULL,
		terms varchar(500) NULL)



-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN
	
    --PTS# 33367 ILB 08/11/2006
    --Insert the misc, supplemental invoices
    INSERT INTO	#masterbill_temp
    SELECT 	IsNull(invoiceheader.ord_hdrnumber, -1),
		invoiceheader.ivh_invoicenumber,  
		invoiceheader.ivh_hdrnumber, 
		invoiceheader.ivh_billto,
		invoiceheader.ivh_shipper,
		invoiceheader.ivh_consignee,   
		invoiceheader.ivh_totalcharge,   
		invoiceheader.ivh_originpoint,  
		invoiceheader.ivh_destpoint,   
		invoiceheader.ivh_origincity,   
		invoiceheader.ivh_destcity,   
		invoiceheader.ivh_shipdate,   
		invoiceheader.ivh_deliverydate,   
		invoiceheader.ivh_revtype1,
		invoiceheader.ivh_mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_shipto_address = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address1,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address1,'')
		ELSE ISNULL(cmp2.cmp_mailto_address1,'')
	    END,
	 ivh_shipto_address2 = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address2,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address2,'')
		ELSE ISNULL(cmp2.cmp_mailto_address2,'')
	    END,
	 ivh_shipto_nmstct = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
						      END),'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp2.mailto_cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.mailto_cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.mailto_cty_nmstct) -1
						      END),'')
	    END,
	ivh_shipto_zip = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL  THEN ISNULL(cmp2.cmp_zip ,'')  
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_zip,'')
		ELSE ISNULL(cmp2.cmp_mailto_zip,'')
	    END,
		ivh_billto_name = cmp1.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
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
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address3,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address3,'')
		ELSE ''
	    END,
	 ivh_billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
						      END),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) -1
						      END),'')
	    END,
	ivh_billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
		ivh_consignee_name = cmp3.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_consignee_address = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address1,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 ivh_consignee_address2 = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address2,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	 ivh_consignee_nmstct = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
						      END),'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp3.mailto_cty_nmstct) -1
						      END),'')
	    END,
	ivh_consignee_zip = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')  
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')
		ELSE ISNULL(cmp3.cmp_mailto_zip,'')

	    END,
		ivh_ref_number,
		--PRB Commented out causes error
		--substring(cty1.cty_nmstct,1,CHARINDEX('/',cty1.cty_nmstct)-1)   origin_nmstct,
		origin_nmstct = CASE WHEN cmp1.cmp_state <> 'XX' THEN
					ISNULL(SUBSTRING(cty1.cty_nmstct,1,CASE 
							WHEN CHARINDEX('/',cty1.cty_nmstct)- 1 < 0 THEN
						           0
							ELSE CHARINDEX('/',cty1.cty_nmstct) - 1
						      END),'')
				ELSE ''
				END,
		--substring(cty1.cty_nmstct,1,CHARINDEX('/',cty1.cty_nmstct)-1)   origin_nmstct,
		cty1.cty_state		origin_state,
		--PRB Commented out casuses error
		--substring(cty2.cty_nmstct,1,CHARINDEX('/',cty2.cty_nmstct)-1)   dest_nmstct,
		dest_nmstct = CASE WHEN cmp1.cmp_state <> 'XX' THEN
					ISNULL(SUBSTRING(cty2.cty_nmstct,1,CASE 
						WHEN CHARINDEX('/',cty2.cty_nmstct)- 1 < 0 THEN
						        0
						ELSE CHARINDEX('/',cty2.cty_nmstct) - 1
						END),'')
			      ELSE ''
			      END,
		cty2.cty_state		dest_state,
		ivh_billdate      billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		ivd.ivd_quantity 'bill_quantity',
		IsNull(ivd.ivd_wgt, 0),
		IsNull(ivd.ivd_wgtunit, ''),
		IsNull(ivd.ivd_count, 0),
		IsNull(ivd.ivd_countunit, ''),
		IsNull(ivd.ivd_volume, 0),
		IsNull(ivd.ivd_volunit, ''),
		IsNull(ivd.ivd_unit, ''),
	ivd_rate = Case When (cht.cht_primary = 'Y' and ivd_rate > 0)then
			(Select sum(IsNull(ivd_rate,0)) From invoicedetail d2,chargetype c2 
			where d2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and IsNull(d2.ivd_charge,0) <> 0 and d2.cht_itemcode = c2.cht_itemcode 
			and (c2.cht_primary = 'Y' or c2.cht_rollintolh = 1) ) 
		else ivd_rate 
		End, 
		IsNull(ivd.ivd_rateunit, ''),
	 ivd_charge = Case When (cht.cht_primary = 'Y' and ivd_charge > 0) Then (Select sum(IsNull(ivd_charge,0)) From invoicedetail d3,chargetype c3 
	where d3.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and IsNull(d3.ivd_charge,0) <> 0 and d3.cht_itemcode = c3.cht_itemcode 
	and (c3.cht_primary = 'Y' or c3.cht_rollintolh = 1) ) else ivd_charge End,  
		cht.cht_description,
		cht.cht_primary,
		cmd.cmd_name,
		IsNull(ivd_description, ''),
		ivd.ivd_type,
		stp.stp_city,
		'',
		ivd_sequence,
		IsNull(stp.stp_number, -1),
		@copy,
		ivd.cmp_id cmp_id,
		cmd.cmd_code,
		invoiceheader.ivh_tractor,
		cmp1.cmp_altid,
		0, --orderheader.ord_totalweight
                isnull(invoiceheader.mov_number,0),
		'' --terms
    FROM 	---invoiceheader, 
		company cmp1, 
		company cmp2,
		company cmp3,
		city cty1, 
		city cty2, 
		---invoicedetail ivd, 
		--commodity cmd, 
		chargetype cht,
		--stops stp,
		--orderheader
		invoiceheader JOIN invoicedetail as ivd ON (ivd.ivh_hdrnumber = invoiceheader.ivh_hdrnumber )  
        	LEFT OUTER JOIN STOPS AS STP ON ( IVD.STP_NUMBER = STP.STP_NUMBER)   
         	LEFT OUTER JOIN commodity AS CMD ON (ivd.cmd_code = CMD.cmd_code) 

   WHERE	(invoiceheader.ivh_mbnumber = @mbnumber )
		--AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		AND (invoiceheader.ord_hdrnumber = 0)
		--AND (ivd.stp_number *= stp.stp_number)
		--AND (ivd.cmd_code *= cmd.cmd_code)
		AND (cmp1.cmp_id = invoiceheader.ivh_billto) 
		AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
		AND (cmp3.cmp_id = invoiceheader.ivh_consignee) 
		AND (cty1.cty_code = invoiceheader.ivh_origincity) 
		AND (cty2.cty_code = invoiceheader.ivh_destcity)
		AND (ivd.cht_itemcode = cht.cht_itemcode)
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		AND (cht.cht_primary = 'Y' or IsNull(cht.cht_rollintolh,0) = 0)
		--and invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber
		--and orderheader.ord_hdrnumber <> 0
		--and ivd_charge <> 0
    --END PTS# 33367 ILB 08/11/2006

    INSERT INTO	#masterbill_temp
    SELECT 	IsNull(invoiceheader.ord_hdrnumber, -1),
		invoiceheader.ivh_invoicenumber,  
		invoiceheader.ivh_hdrnumber, 
		invoiceheader.ivh_billto,
		invoiceheader.ivh_shipper,
		invoiceheader.ivh_consignee,   
		invoiceheader.ivh_totalcharge,   
		invoiceheader.ivh_originpoint,  
		invoiceheader.ivh_destpoint,   
		invoiceheader.ivh_origincity,   
		invoiceheader.ivh_destcity,   
		invoiceheader.ivh_shipdate,   
		invoiceheader.ivh_deliverydate,   
		invoiceheader.ivh_revtype1,
		invoiceheader.ivh_mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_shipto_address = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address1,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address1,'')
		ELSE ISNULL(cmp2.cmp_mailto_address1,'')
	    END,
	 ivh_shipto_address2 = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address2,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address2,'')
		ELSE ISNULL(cmp2.cmp_mailto_address2,'')
	    END,
	 ivh_shipto_nmstct = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
						      END),'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp2.mailto_cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.mailto_cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.mailto_cty_nmstct) -1
						      END),'')
	    END,
	ivh_shipto_zip = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL  THEN ISNULL(cmp2.cmp_zip ,'')  
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_zip,'')
		ELSE ISNULL(cmp2.cmp_mailto_zip,'')
	    END,
		ivh_billto_name = cmp1.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
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
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address3,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address3,'')
		ELSE ''
	    END,
	 ivh_billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
						      END),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) -1
						      END),'')
	    END,
	ivh_billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
		ivh_consignee_name = cmp3.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_consignee_address = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address1,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 ivh_consignee_address2 = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address2,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	 ivh_consignee_nmstct = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
						      END),'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp3.mailto_cty_nmstct) -1
						      END),'')
	    END,
	ivh_consignee_zip = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')  
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')
		ELSE ISNULL(cmp3.cmp_mailto_zip,'')

	    END,
		ivh_ref_number,
		--PRB Commented out causes error
		--substring(cty1.cty_nmstct,1,CHARINDEX('/',cty1.cty_nmstct)-1)   origin_nmstct,
		origin_nmstct = CASE WHEN cmp1.cmp_state <> 'XX' THEN
					ISNULL(SUBSTRING(cty1.cty_nmstct,1,CASE 
							WHEN CHARINDEX('/',cty1.cty_nmstct)- 1 < 0 THEN
						           0
							ELSE CHARINDEX('/',cty1.cty_nmstct) - 1
						      END),'')
				ELSE ''
				END,
		--substring(cty1.cty_nmstct,1,CHARINDEX('/',cty1.cty_nmstct)-1)   origin_nmstct,
		cty1.cty_state		origin_state,
		--PRB Commented out casuses error
		--substring(cty2.cty_nmstct,1,CHARINDEX('/',cty2.cty_nmstct)-1)   dest_nmstct,
		dest_nmstct = CASE WHEN cmp1.cmp_state <> 'XX' THEN
					ISNULL(SUBSTRING(cty2.cty_nmstct,1,CASE 
						WHEN CHARINDEX('/',cty2.cty_nmstct)- 1 < 0 THEN
						        0
						ELSE CHARINDEX('/',cty2.cty_nmstct) - 1
						END),'')
			      ELSE ''
			      END,
		cty2.cty_state		dest_state,
		ivh_billdate      billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		ivd.ivd_quantity 'bill_quantity',
		IsNull(ivd.ivd_wgt, 0),
		IsNull(ivd.ivd_wgtunit, ''),
		IsNull(ivd.ivd_count, 0),
		IsNull(ivd.ivd_countunit, ''),
		IsNull(ivd.ivd_volume, 0),
		IsNull(ivd.ivd_volunit, ''),
		IsNull(ivd.ivd_unit, ''),
	ivd_rate = Case When (cht.cht_primary = 'Y' and ivd_rate > 0)then
			(Select sum(IsNull(ivd_rate,0)) From invoicedetail d2,chargetype c2 
			where d2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and IsNull(d2.ivd_charge,0) <> 0 and d2.cht_itemcode = c2.cht_itemcode 
			and (c2.cht_primary = 'Y' or c2.cht_rollintolh = 1) ) 
		else ivd_rate 
		End, 
		IsNull(ivd.ivd_rateunit, ''),
	 ivd_charge = Case When (cht.cht_primary = 'Y' and ivd_charge > 0) Then (Select sum(IsNull(ivd_charge,0)) From invoicedetail d3,chargetype c3 
	where d3.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and IsNull(d3.ivd_charge,0) <> 0 and d3.cht_itemcode = c3.cht_itemcode 
	and (c3.cht_primary = 'Y' or c3.cht_rollintolh = 1) ) else ivd_charge End,  
		cht.cht_description,
		cht.cht_primary,
		cmd.cmd_name,
		IsNull(ivd_description, ''),
		ivd.ivd_type,
		stp.stp_city,
		'',
		ivd_sequence,
		IsNull(stp.stp_number, -1),
		@copy,
		ivd.cmp_id cmp_id,
		cmd.cmd_code,
		invoiceheader.ivh_tractor,
		cmp1.cmp_altid,
		orderheader.ord_totalweight,
                isnull(invoiceheader.mov_number,0),
		'' --terms		
    FROM 	--invoiceheader, 
		company cmp1, 
		company cmp2,
		company cmp3,
		city cty1, 
		city cty2, 
		--invoicedetail ivd, 
		--commodity cmd, 
		chargetype cht,
		--stops stp,
		orderheader,
		invoiceheader JOIN invoicedetail as ivd ON (ivd.ivh_hdrnumber = invoiceheader.ivh_hdrnumber )  
        	LEFT OUTER JOIN STOPS AS STP ON ( IVD.STP_NUMBER = STP.STP_NUMBER)   
         	LEFT OUTER JOIN commodity AS CMD ON (ivd.cmd_code = CMD.cmd_code) 

   WHERE	( invoiceheader.ivh_mbnumber = @mbnumber )
		--AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		--AND (ivd.stp_number *= stp.stp_number)
		--AND (ivd.cmd_code *= cmd.cmd_code)
		AND (cmp1.cmp_id = invoiceheader.ivh_billto) 
		AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
		AND (cmp3.cmp_id = invoiceheader.ivh_consignee) 
		AND (cty1.cty_code = invoiceheader.ivh_origincity) 
		AND (cty2.cty_code = invoiceheader.ivh_destcity)
		AND (ivd.cht_itemcode = cht.cht_itemcode)
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		and (cht.cht_primary = 'Y' or IsNull(cht.cht_rollintolh,0) = 0)
		and invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber
		and orderheader.ord_hdrnumber <> 0
		--and ivd_charge <> 0
  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
     --PTS# 33367 ILB 08/11/2006
     --Insert the misc, supplemental invoices
     INSERT INTO 	#masterbill_temp
     SELECT 	IsNull(invoiceheader.ord_hdrnumber,-1),
		invoiceheader.ivh_invoicenumber,  
		invoiceheader.ivh_hdrnumber, 
		invoiceheader.ivh_billto,   
		invoiceheader.ivh_shipper,
		invoiceheader.ivh_consignee,
		invoiceheader.ivh_totalcharge,   
		invoiceheader.ivh_originpoint,  
		invoiceheader.ivh_destpoint,   
		invoiceheader.ivh_origincity,   
		invoiceheader.ivh_destcity,   
		invoiceheader.ivh_shipdate,   
		invoiceheader.ivh_deliverydate,   		
		invoiceheader.ivh_revtype1,
		@mbnumber     ivh_mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_shipto_address = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address1,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address1,'')
		ELSE ISNULL(cmp2.cmp_mailto_address1,'')
	    END,
	 ivh_shipto_address2 = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address2,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address2,'')
		ELSE ISNULL(cmp2.cmp_mailto_address2,'')
	    END,
	 ivh_shipto_nmstct = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
						      END),'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp2.mailto_cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.mailto_cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.mailto_cty_nmstct) -1
						      END),'')
	    END,
	ivh_shipto_zip = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL  THEN ISNULL(cmp2.cmp_zip ,'')  
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_zip,'')
		ELSE ISNULL(cmp2.cmp_mailto_zip,'')
	    END,
		ivh_billto_name = cmp1.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
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
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address3,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address3,'')
		ELSE ''
	    END,

	 ivh_billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct)- 1
						      END),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct)- 1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
								  WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct) - 1 < 0 THEN
								     0
								  ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) - 1
						      END),'')
	    END,

	ivh_billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
		ivh_consignee_name = cmp3.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto

	 ivh_consignee_address = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address1,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,

	 ivh_consignee_address2 = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address2,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,

	 ivh_consignee_nmstct = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE 
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
						           0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) - 1
						      END),'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE 
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
						           0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) - 1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,CASE
								 WHEN CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1 < 0 THEN
								    0
								 ELSE CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1
							       END),'')
	    END,

	ivh_consignee_zip = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')  
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')
		ELSE ISNULL(cmp3.cmp_mailto_zip,'')
	    END,

		ivh_ref_number,
		--PRB Commented out causes error
		--substring(cty1.cty_nmstct,1,CHARINDEX('/',cty1.cty_nmstct)-1)   origin_nmstct,
		origin_nmstct = CASE WHEN cmp1.cmp_state <> 'XX' THEN
					ISNULL(SUBSTRING(cty1.cty_nmstct,1,CASE 
							WHEN CHARINDEX('/',cty1.cty_nmstct)- 1 < 0 THEN
						           0
							ELSE CHARINDEX('/',cty1.cty_nmstct) - 1
						      END),'')
				ELSE ''
				END,
		--substring(cty1.cty_nmstct,1,CHARINDEX('/',cty1.cty_nmstct)-1)   origin_nmstct,
		cty1.cty_state		origin_state,
		--PRB Commented out casuses error
		--substring(cty2.cty_nmstct,1,CHARINDEX('/',cty2.cty_nmstct)-1)   dest_nmstct,
		dest_nmstct = CASE WHEN cmp1.cmp_state <> 'XX' THEN
					ISNULL(SUBSTRING(cty2.cty_nmstct,1,CASE 
						WHEN CHARINDEX('/',cty2.cty_nmstct)- 1 < 0 THEN
						        0
						ELSE CHARINDEX('/',cty2.cty_nmstct) - 1
						END),'')
			      ELSE ''
			      END,
		cty2.cty_state		dest_state,
		@billdate	billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		ivd.ivd_quantity 'bill_quantity',
		IsNull(ivd.ivd_wgt, 0),
		IsNull(ivd.ivd_wgtunit, ''),
		IsNull(ivd.ivd_count, 0),
		IsNull(ivd.ivd_countunit, ''),
		IsNull(ivd.ivd_volume, 0),
		IsNull(ivd.ivd_volunit, ''),
		IsNull(ivd.ivd_unit, ''),
		ivd_rate = Case When (cht.cht_primary = 'Y' and ivd_rate > 0)then
			   (Select sum(IsNull(ivd_rate,0)) From invoicedetail d2,chargetype c2 
			   where d2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and IsNull(d2.ivd_charge,0) <> 0 and d2.cht_itemcode = c2.cht_itemcode 
			   and (c2.cht_primary = 'Y' or c2.cht_rollintolh = 1) ) 
			   else ivd_rate 
		End, 
		IsNull(ivd.ivd_rateunit, ''),
	 	ivd_charge = Case When (cht.cht_primary = 'Y' and ivd_charge > 0) Then (Select sum(IsNull(ivd_charge,0)) From invoicedetail d3,chargetype c3 
			          where d3.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and IsNull(d3.ivd_charge,0) <> 0 and d3.cht_itemcode = c3.cht_itemcode 
				  and (c3.cht_primary = 'Y' or c3.cht_rollintolh = 1) ) else ivd_charge End,  
		cht.cht_description,
		cht.cht_primary,
		cmd.cmd_name,
		IsNull(ivd_description, ''),
		ivd.ivd_type,		
	  	stp.stp_city,
		'',
		ivd_sequence,
		IsNull(stp.stp_number, -1),
		@copy,
		ivd.cmp_id cmp_id,
		cmd.cmd_code,
		invoiceheader.ivh_tractor,
		cmp1.cmp_altid,
		0, --orderheader.ord_totalweight
                isnull(invoiceheader.mov_number,0),
		'' --terms
	FROM 	--invoiceheader, 
		company cmp1,
		company cmp2,
		company cmp3,
		city cty1, 
		city cty2,
		--stops stp, 
		--invoicedetail ivd, 
		--commodity cmd, 
		chargetype cht,
		invoiceheader JOIN invoicedetail as ivd ON (ivd.ivh_hdrnumber = invoiceheader.ivh_hdrnumber )  
        	LEFT OUTER JOIN STOPS AS STP ON ( IVD.STP_NUMBER = STP.STP_NUMBER)   
         	LEFT OUTER JOIN commodity AS CMD ON (ivd.cmd_code = CMD.cmd_code) 

	WHERE 	( invoiceheader.ivh_billto = @billto )  
		--AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		AND  invoiceheader.ord_hdrnumber = 0
		--AND (ivd.stp_number *= stp.stp_number)
		--AND (ivd.cmd_code *= cmd.cmd_code)
		AND ( invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
		--PRB PTS35176
		AND ( invoiceheader.ivh_deliverydate between @p_delstart AND @p_delend )
		--END PTS35176
		AND (invoiceheader.ivh_mbstatus = 'RTP')  
		AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
		AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK'))
		--PRB PTS35176
		AND (@p_revtype3 in (invoiceheader.ivh_revtype3,'UNK'))
		AND (@p_revtype4 in (invoiceheader.ivh_revtype4,'UNK'))
		--END PRB
		AND (cmp1.cmp_id = invoiceheader.ivh_billto)
		AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
	 	AND (cmp3.cmp_id = invoiceheader.ivh_consignee)
		AND (cty1.cty_code = invoiceheader.ivh_origincity) 
		AND (cty2.cty_code = invoiceheader.ivh_destcity)
		AND (ivd.cht_itemcode = cht.cht_itemcode)
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		AND (@ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master'))
		AND (cht.cht_primary = 'Y' or IsNull(cht.cht_rollintolh,0) = 0)
    --END PTS# 33367 ILB 08/11/2006
     
     INSERT INTO 	#masterbill_temp
     SELECT 	IsNull(invoiceheader.ord_hdrnumber,-1),
		invoiceheader.ivh_invoicenumber,  
		invoiceheader.ivh_hdrnumber, 
		invoiceheader.ivh_billto,   
		invoiceheader.ivh_shipper,
		invoiceheader.ivh_consignee,
		invoiceheader.ivh_totalcharge,   
		invoiceheader.ivh_originpoint,  
		invoiceheader.ivh_destpoint,   
		invoiceheader.ivh_origincity,   
		invoiceheader.ivh_destcity,   
		invoiceheader.ivh_shipdate,   
		invoiceheader.ivh_deliverydate,   		invoiceheader.ivh_revtype1,
		@mbnumber     ivh_mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_shipto_address = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address1,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address1,'')
		ELSE ISNULL(cmp2.cmp_mailto_address1,'')
	    END,
	 ivh_shipto_address2 = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address2,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address2,'')
		ELSE ISNULL(cmp2.cmp_mailto_address2,'')
	    END,
	 ivh_shipto_nmstct = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
						      END),'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp2.mailto_cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.mailto_cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.mailto_cty_nmstct) -1
						      END),'')
	    END,
	ivh_shipto_zip = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL  THEN ISNULL(cmp2.cmp_zip ,'')  
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_zip,'')
		ELSE ISNULL(cmp2.cmp_mailto_zip,'')
	    END,
		ivh_billto_name = cmp1.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
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
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address3,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address3,'')
		ELSE ''
	    END,
	 ivh_billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct)- 1
						      END),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct)- 1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
								  WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct) - 1 < 0 THEN
								     0
								  ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) - 1
						      END),'')
	    END,
	ivh_billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
		ivh_consignee_name = cmp3.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_consignee_address = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address1,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 ivh_consignee_address2 = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address2,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	 ivh_consignee_nmstct = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE 
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
						           0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) - 1
						      END),'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE 
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
						           0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) - 1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,CASE
								 WHEN CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1 < 0 THEN
								    0
								 ELSE CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1
							       END),'')
	    END,
	ivh_consignee_zip = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')  
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')
		ELSE ISNULL(cmp3.cmp_mailto_zip,'')
	    END,
		ivh_ref_number,
		--PRB Commented out causes error
		--substring(cty1.cty_nmstct,1,CHARINDEX('/',cty1.cty_nmstct)-1)   origin_nmstct,
		origin_nmstct = CASE WHEN cmp1.cmp_state <> 'XX' THEN
					ISNULL(SUBSTRING(cty1.cty_nmstct,1,CASE 
							WHEN CHARINDEX('/',cty1.cty_nmstct)- 1 < 0 THEN
						           0
							ELSE CHARINDEX('/',cty1.cty_nmstct) - 1
						      END),'')
				ELSE ''
				END,
		--substring(cty1.cty_nmstct,1,CHARINDEX('/',cty1.cty_nmstct)-1)   origin_nmstct,
		cty1.cty_state		origin_state,
		--PRB Commented out casuses error
		--substring(cty2.cty_nmstct,1,CHARINDEX('/',cty2.cty_nmstct)-1)   dest_nmstct,
		dest_nmstct = CASE WHEN cmp1.cmp_state <> 'XX' THEN
					ISNULL(SUBSTRING(cty2.cty_nmstct,1,CASE 
						WHEN CHARINDEX('/',cty2.cty_nmstct)- 1 < 0 THEN
						        0
						ELSE CHARINDEX('/',cty2.cty_nmstct) - 1
						END),'')
			      ELSE ''
			      END,
		cty2.cty_state		dest_state,
		@billdate	billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		ivd.ivd_quantity 'bill_quantity',
		IsNull(ivd.ivd_wgt, 0),
		IsNull(ivd.ivd_wgtunit, ''),
		IsNull(ivd.ivd_count, 0),
		IsNull(ivd.ivd_countunit, ''),
		IsNull(ivd.ivd_volume, 0),
		IsNull(ivd.ivd_volunit, ''),
		IsNull(ivd.ivd_unit, ''),
	ivd_rate = Case When (cht.cht_primary = 'Y' and ivd_rate > 0)then
			(Select sum(IsNull(ivd_rate,0)) From invoicedetail d2,chargetype c2 
			where d2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and IsNull(d2.ivd_charge,0) <> 0 and d2.cht_itemcode = c2.cht_itemcode 
			and (c2.cht_primary = 'Y' or c2.cht_rollintolh = 1) ) 
		else ivd_rate 
		End, 
		IsNull(ivd.ivd_rateunit, ''),
	 ivd_charge = Case When (cht.cht_primary = 'Y' and ivd_charge > 0) Then (Select sum(IsNull(ivd_charge,0)) From invoicedetail d3,chargetype c3 
	where d3.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and IsNull(d3.ivd_charge,0) <> 0 and d3.cht_itemcode = c3.cht_itemcode 
	and (c3.cht_primary = 'Y' or c3.cht_rollintolh = 1) ) else ivd_charge End,  
		cht.cht_description,
		cht.cht_primary,
		cmd.cmd_name,
		IsNull(ivd_description, ''),
		ivd.ivd_type,		stp.stp_city,
		'',
		ivd_sequence,
		IsNull(stp.stp_number, -1),
		@copy,
		ivd.cmp_id cmp_id,
		cmd.cmd_code,
		invoiceheader.ivh_tractor,
		cmp1.cmp_altid,
		orderheader.ord_totalweight,
                isnull(invoiceheader.mov_number,0),
		'' --terms
	FROM 	--invoiceheader, 
		company cmp1,
		company cmp2,
		company cmp3,
		city cty1, 
		city cty2,
		--stops stp, 
		--invoicedetail ivd, 
		--commodity cmd, 
		chargetype cht,
		orderheader,
		invoiceheader JOIN invoicedetail as ivd ON (ivd.ivh_hdrnumber = invoiceheader.ivh_hdrnumber )  
        	LEFT OUTER JOIN STOPS AS STP ON ( IVD.STP_NUMBER = STP.STP_NUMBER)   
         	LEFT OUTER JOIN commodity AS CMD ON (ivd.cmd_code = CMD.cmd_code) 

	WHERE 	( invoiceheader.ivh_billto = @billto )  
		--AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		--AND (ivd.stp_number *= stp.stp_number)
		--AND (ivd.cmd_code *= cmd.cmd_code)
		AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend )
		--PRB PTS35176
		AND ( invoiceheader.ivh_deliverydate between @p_delstart AND @p_delend )
		--END PTS35176
		AND     (invoiceheader.ivh_mbstatus = 'RTP')  
		AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
		AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK')) 
		--PRB PTS35176
		AND (@p_revtype3 in (invoiceheader.ivh_revtype3,'UNK'))
		AND (@p_revtype4 in (invoiceheader.ivh_revtype4,'UNK'))
		--END PRB
		AND    (cmp1.cmp_id = invoiceheader.ivh_billto)
		AND	(cmp2.cmp_id = invoiceheader.ivh_shipper)
	 	AND	(cmp3.cmp_id = invoiceheader.ivh_consignee)
		AND    (cty1.cty_code = invoiceheader.ivh_origincity) 
		AND    (cty2.cty_code = invoiceheader.ivh_destcity)
		AND    (ivd.cht_itemcode = cht.cht_itemcode)
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		AND (@ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master'))
		and (cht.cht_primary = 'Y' or IsNull(cht.cht_rollintolh,0) = 0)
		and (invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber)
		and (orderheader.ord_hdrnumber <> 0)
		--and ivd_charge <> 0	
  END

  UPDATE 	#masterbill_temp 
  SET		#masterbill_temp.stp_cty_nmstct = city.cty_nmstct
  FROM		#masterbill_temp, city 
  WHERE		#masterbill_temp.stp_city = city.cty_code 

 UPDATE 	#masterbill_temp 
  SET		#masterbill_temp.cmd_code = commodity.cmd_name
  FROM		#masterbill_temp, invoicedetail, commodity
  WHERE		#masterbill_temp.ord_hdrnumber = invoicedetail.ord_hdrnumber 
  AND		invoicedetail.cmd_code = commodity.cmd_code 
                and invoicedetail.ivd_sequence = 1

declare @hdrnumber int,@seq int
Select @hdrnumber = min(ivh_hdrnumber) from  #masterbill_temp 

Insert into #masterbill_temp
Select ord_hdrnumber = t.ord_hdrnumber,
		ivh_invoicenumber = 'ZZZZZZZZZZZZ',  
		ivh_hdrnumber = t.ivh_hdrnumber, 
		ivh_billto= 'ZZZZZZZZ',
		ivh_shipper = 'unknown',
		ivh_consignee = 'unknown',
		ivh_totalcharge = 0,   
		ivh_originpoint = 'UNKNOWN',  
		ivh_destpoint = 'UNKNOWN',   
		ivh_origincity =0,   
		ivh_destcity= 0,   
		ivh_shipdate = t.ivh_shipdate,   
		ivh_deliverydate = t.ivh_deliverydate,   
		ivh_revtype1 = t.ivh_revtype1,
		ivh_mbnumber= t.ivh_mbnumber,
		ivh_shipper_name='' ,
		ivh_shipper_address= '',
		ivh_shipper_address2= '',
		ivh_shipper_nmstct= '' ,
		ivh_shipper_zip ='',
		ivh_billto_name = t.ivh_billto_name,
		ivh_billto_address = t.ivh_billto_address ,
		ivh_billto_address2= t.ivh_billto_address2,
		ivh_billto_address3= t.ivh_billto_address3,
		ivh_billto_nmstct = t.ivh_billto_nmstct ,
		ivh_billto_zip= t.ivh_billto_zip,
		ivh_consignee_name= '',
		ivh_consignee_address ='',
		ivh_consignee_address2= '',
		ivh_consignee_nmstct='',
		ivh_consignee_zip ='',
		ivh_ref_number='',
		origin_nmstct = 'UNKNOWN',
		origin_state ='',
		dest_nmstct= 'UNKNOWN',
		dest_state ='',
		billdate =getdate(),
		cmp_mailto_name = t.cmp_mailto_name,
		bill_quantity =0,
		ivd_weight=0,
		ivd_weightunit ='UNK',
		ivd_count =0,
		ivd_countunit ='UNK',
		ivd_volume =0,
		ivd_volunit  ='UNK',
		ivd_unit  ='UNK',
		ivd_rate =0,
		ivd_rateunit  ='UNK',
		ivd_charge =0,
		cht_description ='',
		cht_primary ='Y',
		cmd_name ='',
		--vmj1+
		ivd_description='',
--		ivd_description varchar(30) NULL,
		--vmj1-
		ivd_type  ='UNK',
		stp_city =0,
		stp_cty_nmstct='UNKNOWN',
		ivd_sequence =1,
		stp_number =0,
		copy =1,
		cmp_id ='UNKNOWN',
		cmd_code ='UNKNOWN',
		ivh_tractor ='UNKNOWN',
		billto_altid='',
		ord_totalweight=0,
                mov_number = 0,
                terms = ''
From  #masterbill_temp t
Where t.ivh_hdrnumber = @hdrnumber
and t.ivd_sequence = 1

--PTS# 33367 ILB 08/16/2006 add terms to the format
--PRB PTS 35176 - put in MIN
Update #masterbill_temp
   set terms = ivs_terms 
		   from invoiceselection
  		  where ivs_number = @p_ivsnumber  --PTS 37555
--PTS# 33367 ILB 08/16/2006 add terms to the format
 
SELECT * 
  FROM		#masterbill_temp
 where ivd_charge <> 0.00 OR ivh_billto = 'ZZZZZZZZ'
ORDER BY ivh_invoicenumber, ivd_sequence

DROP TABLE 	#masterbill_temp
GO
GRANT EXECUTE ON  [dbo].[d_masterbill90_sp] TO [public]
GO
