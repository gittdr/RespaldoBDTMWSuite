SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill76_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	@revtype1 varchar(6), @mbstatus varchar(6),@shipstart datetime,
        @shipend datetime,@billdate datetime, @shipper varchar(8),@consignee varchar(8),
        @copy int, @ivh_invoicenumber varchar(12))
AS

/**
 * 
 * NAME:
 * dbo.d_masterbill76_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure builds the result set used by MasterBill Format 76 originally developed for Jim Aartman (PTS 30509)
 * Based of masterbill format 07
 * 
 * RETURNS:
 * None
 *
 * RESULT SETS: 
 * ord_number varchar(12),                     Order Number
 * ivh_invoicenumber varchar(12),              Invoice Number
 * ivh_hdrnumber int NULL,                     Invoice Header Number
 * ivh_billto varchar(8) NULL,                 Invoice Billto
 * ivh_shipper varchar(8) NULL,                Invoice Shipper
 * ivh_consignee varchar(8) NULL,              Invoice Consignee
 * ivh_totalcharge money NULL,                 Total Charges of the Invoice
 * ivh_originpoint  varchar(8) NULL,           Origin company
 * ivh_destpoint varchar(8) NULL,              Dest company
 * ivh_origincity int NULL,                    Origin City
 * ivh_destcity int NULL,                      Dest City
 * ivh_shipdate datetime NULL,                 Ship Date
 * ivh_deliverydate datetime NULL,             Delivery Date
 * ivh_revtype1 varchar(6) NULL,               Revtype 1
 * ivh_mbnumber int NULL,                      Master Bill Number
 * ivh_billto_name varchar(30)  NULL,          BillTo Company Name
 * ivh_billto_address varchar(40) NULL,        BillTo Address
 * ivh_billto_address2 varchar(40) NULL,       BillTo Address Line 2
 * ivh_billto_nmstct varchar(25) NULL ,        BillTo City, State/County
 * ivh_billto_zip varchar(9) NULL,             BillTo Zip
 * ivh_ref_number varchar(30) NULL,            Primary Reference Number for the invoice
 * ivh_tractor varchar(8) NULL,                Tractor
 * ivh_trailer varchar(13) NULL,               Trailer
 * origin_nmstct varchar(25) NULL,             Origin City, State/County
 * origin_state varchar(2) NULL,               Origin State
 * dest_nmstct varchar(25) NULL,               Dest City, State/County
 * dest_state varchar(2) NULL,                 Dest State
 * billdate datetime NULL,                     Invoice Bill Date
 * cmp_mailto_name varchar(30)  NULL,          Mail To for the billto
 * bill_quantity float  NULL,                  Quantity of the invoice
 * ivd_refnumber varchar(30) NULL,             Invoice Detail Referencenumber 
 * ivd_weight float NULL,                      Invoice Detail Weight
 * ivd_weightunit char(6) NULL,                Invoice Detail Weight Unit Of Measure
 * ivd_count float NULL,                       Invoice Detail Count
 * ivd_countunit char(6) NULL,                 Invoice Detail Count Unit Of Measure
 * ivd_volume float NULL,                      Invoice Detail Volume
 * ivd_volunit char(6) NULL,                   Invoice Detail Volume Unit Of Measure
 * ivd_unit char(6) NULL,                      
 * ivd_rate money NULL,                        Rate on the invoice detail
 * ivd_rateunit char(6) NULL,                  Rate on the invoice detail Unit of Measure
 * ivd_charge money NULL,                      Charge on the invoice detail
 * cht_description varchar(30) NULL,           Charge type's description
 * cht_primary char(1) NULL,                   Flag on if it is a primary or secondary rate
 * cmd_name varchar(60)  NULL,                 Commodity Name
 * ivd_description varchar(60) NULL,           Description on the Invoice Detail
 * ivd_type char(6) NULL,                      Type of invoicedetail
 * stp_city int NULL,                          City Code for the stop 
 * stp_cty_nmstct varchar(25) NULL,            City, State/ county of the stop
 * ivd_sequence int NULL,                      Sequence number for the detail
 * stp_number int NULL,                        Stop number detail relates to
 * copy int NULL,                              Number of copies to print
 * ivh_totalweight float NULL,                 Total Weight on the Invoice
 * cmp_id varchar(8) NULL,                     Compnay on the invoice's ID
 * cmp_name varchar(30) NULL,                  Compnay on the invoice's Name
 * ivh_remark varchar(254) NULL                Remark on the Invoice Header
 * 
 * PARAMETERS:
 * @reprintflag varchar(10),       Flag to determine if the print job is reprinting an existing masterbill or creating a new one
 * @mbnumber int,                  Master Bill number 0 if new master bill or contains the mb number to reprint
 * @billto varchar(8),             Billto selection criteria
 * @revtype1 varchar(6),           RevType1 selection criteria 
 * @mbstatus varchar(6),           Status of invoices to seach for
 * @shipstart datetime,            Start date of the date restriction
 * @shipend datetime,              End date of the date restriction
 * @billdate datetime,             Date to stamp the billdate
 * @shipper varchar(8),            Shipper restriction
 * @consignee varchar(8),          Consignee restriction
 * @copy int,                      Number of copies
 * @ivh_invoicenumber varchar(12)  Master is value used for masterbill retrivals


 * 
 * REVISION HISTORY:
 * 02/22/2006.01 ? PTS30509 - Jason Bauwin ? Original
 *
 **/






DECLARE @int0  int
SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'


CREATE TABLE #masterbill_temp (		ord_number varchar(12),
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
		ivh_billto_name varchar(30)  NULL,
		ivh_billto_address varchar(40) NULL,
		ivh_billto_address2 varchar(40) NULL,
		ivh_billto_nmstct varchar(25) NULL ,
		ivh_billto_zip varchar(9) NULL,
		ivh_ref_number varchar(30) NULL,
		ivh_tractor varchar(8) NULL,
		ivh_trailer varchar(13) NULL,
		origin_nmstct varchar(25) NULL,
		origin_state varchar(2) NULL,
		dest_nmstct varchar(25) NULL,
		dest_state varchar(2) NULL,
		billdate datetime NULL,
		cmp_mailto_name varchar(30)  NULL,
		bill_quantity float  NULL,
		ivd_refnumber varchar(30) NULL,
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
		stp_cty_nmstct varchar(25) NULL,
		ivd_sequence int NULL,
		stp_number int NULL,
		copy int NULL,
		ivh_totalweight float NULL,
		cmp_id varchar(8) NULL,
		cmp_name varchar(30) NULL,
		ivh_remark varchar(254) NULL)



-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN
    INSERT INTO	#masterbill_temp
    SELECT 	IsNull(invoiceheader.ord_number, ''),
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
	 ivh_billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
	    END,
	ivh_billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
		invoiceheader.ivh_ref_number,
		invoiceheader.ivh_tractor,
		invoiceheader.ivh_trailer,
		cty1.cty_nmstct   origin_nmstct,
		cty1.cty_state		origin_state,
		cty2.cty_nmstct   dest_nmstct,
		cty2.cty_state		dest_state,
		ivh_billdate      billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		ivd.ivd_quantity 'bill_quantity',
		IsNull(ivd.ivd_refnum, ''),
		IsNull(ivd.ivd_wgt, 0),
		IsNull(ivd.ivd_wgtunit, ''),
		IsNull(ivd.ivd_count, 0),
		IsNull(ivd.ivd_countunit, ''),
		IsNull(ivd.ivd_volume, 0),
		IsNull(ivd.ivd_volunit, ''),
		IsNull(ivd.ivd_unit, ''),
		IsNull(ivd.ivd_rate, 0),
		IsNull(ivd.ivd_rateunit, ''),
		ivd.ivd_charge,
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
		ivh_totalweight,
		ivd.cmp_id cmp_id,
		cmp2.cmp_name,
		invoiceheader.ivh_remark
    FROM 	invoiceheader
   JOIN invoicedetail ivd on ivd.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
   JOIN company cmp1 on cmp1.cmp_id = invoiceheader.ivh_billto
   JOIN company cmp2 on cmp2.cmp_id = ivd.cmp_id
   JOIN chargetype cht on cht.cht_itemcode = ivd.cht_itemcode
   LEFT OUTER JOIN city cty1 on invoiceheader.ivh_origincity = cty1.cty_code
   LEFT OUTER JOIN city cty2 on invoiceheader.ivh_destcity = cty2.cty_code
   LEFT OUTER JOIN stops stp on stp.stp_number = ivd.stp_number
   LEFT OUTER JOIN commodity cmd on ivd.cmd_code = cmd.cmd_code
   WHERE	(invoiceheader.ivh_mbnumber = @mbnumber )
     AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
	  AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))

  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
     INSERT INTO 	#masterbill_temp
     SELECT IsNull(invoiceheader.ord_number,''),
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
            ivh_billto_nmstct = 
	      CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
	      END,
            ivh_billto_zip = 
	      CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	      END,
	    invoiceheader.ivh_ref_number,
	    invoiceheader.ivh_tractor,
	    invoiceheader.ivh_trailer,
            cty1.cty_nmstct   origin_nmstct,
            cty1.cty_state		origin_state,
            cty2.cty_nmstct   dest_nmstct,
            cty2.cty_state		dest_state,
            --PTS#23284 ILB 07/28/2004 
	    @billdate billdate,
	    --ivh_billdate      billdate,
	    --PTS#23284 ILB 07/28/2004
            ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
            ivd.ivd_quantity 'bill_quantity',
	    IsNull(ivd.ivd_refnum, ''),
            IsNull(ivd.ivd_wgt, 0),
            IsNull(ivd.ivd_wgtunit, ''),
            IsNull(ivd.ivd_count, 0),
            IsNull(ivd.ivd_countunit, ''),
            IsNull(ivd.ivd_volume, 0),
            IsNull(ivd.ivd_volunit, ''),
            IsNull(ivd.ivd_unit, ''),
            IsNull(ivd.ivd_rate, 0),
            IsNull(ivd.ivd_rateunit, ''),
            ivd.ivd_charge,
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
	         ivh_totalweight,
            ivd.cmp_id cmp_id,
	    cmp2.cmp_name,
	    invoiceheader.ivh_remark
    FROM 	invoiceheader
    JOIN invoicedetail ivd on ivd.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
    JOIN company cmp1 on cmp1.cmp_id = invoiceheader.ivh_billto
    JOIN company cmp2 on cmp2.cmp_id = ivd.cmp_id
    JOIN chargetype cht on cht.cht_itemcode = ivd.cht_itemcode
    LEFT OUTER JOIN city cty1 on invoiceheader.ivh_origincity = cty1.cty_code
    LEFT OUTER JOIN city cty2 on invoiceheader.ivh_destcity = cty2.cty_code
    LEFT OUTER JOIN stops stp on stp.stp_number = ivd.stp_number
    LEFT OUTER JOIN commodity cmd on ivd.cmd_code = cmd.cmd_code
   WHERE invoiceheader.ivh_billto = @billto and
         invoiceheader.ivh_shipdate between @shipstart AND @shipend and 
         invoiceheader.ivh_mbstatus = 'RTP' and 
         @revtype1 in (invoiceheader.ivh_revtype1,'UNK') and 
         @shipper in (invoiceheader.ivh_shipper,'UNKNOWN') and
         @consignee IN (invoiceheader.ivh_consignee,'UNKNOWN') and
         @ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master')


  END

  UPDATE 	#masterbill_temp 
  SET		#masterbill_temp.stp_cty_nmstct = city.cty_nmstct
  FROM		#masterbill_temp, city 
  WHERE		#masterbill_temp.stp_city = city.cty_code 

  SELECT * 
  FROM		#masterbill_temp
  ORDER BY	ord_number, ivd_sequence

GO
GRANT EXECUTE ON  [dbo].[d_masterbill76_sp] TO [public]
GO
