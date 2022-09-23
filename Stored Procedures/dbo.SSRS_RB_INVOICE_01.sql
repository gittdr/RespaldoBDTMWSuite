SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


Create PROCEDURE [dbo].[SSRS_RB_INVOICE_01](@invoice_nbr  	int,@copies		int,@ivs_number	int,@billdate	DATETIME)
AS 

DECLARE @printcount AS INT
DECLARE @ret_value AS INT
DECLARE @invoice AS INT
DECLARE @rollINTOLHAmt MONEY
DECLARE @rateconvertion FLOAT

SET @printcount = 1
SET @ret_value = 1
SET @invoice = @invoice_nbr

-------------------- Bill to Mailing Address Section -----------------------

DECLARE @Bill_Address AS TABLE 
	([Invoice Header Bill To Name] VARCHAR(100),
	 [Invoice Header Bill To Add1] VARCHAR(100),
	 [Invoice Header Bill To Add2] VARCHAR(100),
	 [Invoice Header Bill To Add3] VARCHAR(100),
	 [Invoice Header Bill To CityStZip] VARCHAR(100),
	 [Invoice Header Bill To Alternate Company Id] VARCHAR(25),
	 [Invoice Header Bill To Contact] VARCHAR(30)
	)

DECLARE @cmp_mailto VARCHAR(30)

SELECT @cmp_mailto = ISNULL(cmp_mailto_name,'')
	FROM invoiceheader
		INNER JOIN company c on c.cmp_id = invoiceheader.ivh_billto
	WHERE	invoiceheader.ivh_terms in (c.cmp_mailto_crterm1,	c.cmp_mailto_crterm2,	c.cmp_mailto_crterm3,	
			CASE ISNULL(c.cmp_mailtoTermsMatchFlag,'N') WHEN 'Y' THEN '^^' ELSE invoiceheader.ivh_terms END)
			And invoiceheader.ivh_charge <> CASE ISNULL(c.cmp_MailtToForLinehaulFlag,'Y') WHEN 'Y' THEN 0.00 ELSE invoiceheader.ivh_charge + 1.00 END	
			And	ivh_hdrnumber = @invoice

if ISNULL(@cmp_mailto,'') = ''
	-- No MailTo, use main address	
	BEGIN
		INSERT INTO @Bill_Address
		SELECT
			cmp_name,
			cmp_address1,
			cmp_address2,
			cmp_address3,
			cty_name + ', ' + cty_state + ' ' + ISNULL(cmp_zip,''),
			cmp_altid,
			cmp_contact 
		FROM invoiceheader 
			INNER JOIN company c on c.cmp_id = ivh_billto
			INNER JOIN city cty on cty.cty_code = c.cmp_city
		WHERE ivh_hdrnumber = @invoice
	END
ELSE
	-- MailTo address	
	BEGIN
		INSERT INTO @Bill_Address
		SELECT
			cmp_mailto_name,
			cmp_mailto_Address1,
			cmp_mailto_address2,
			'',
			cty_name + ', ' + cty_state + ' ' + ISNULL(cmp_mailto_zip,''),
			cmp_altid,
			cmp_contact			
		FROM invoiceheader 
			INNER JOIN company c on c.cmp_id = ivh_billto
			INNER JOIN city cty on cty.cty_code = c.cmp_mailto_city
		WHERE ivh_hdrnumber = @invoice
	END

------------------------ END BillTo mailing address  -----------------------
------------------------------ Main SELECT ---------------------------------

SELECT 

	ivh.ivh_invoicenumber [Invoice Header Invoice Number],	
	ivh.ivh_hdrnumber [Invoice Header Number],
	ivh.ord_number [Invoice Header Order Number],
	ivh.ord_hdrnumber [Invoice Header Order Header Number],
	ivh.ivh_billto [Invoice Header Bill To],
	[Invoice Header Bill To Name],
	[Invoice Header Bill To Add1],
	[Invoice Header Bill To Add2],
	[Invoice Header Bill To Add3],
	[Invoice Header Bill To CityStZip],
	[Invoice Header Bill To Alternate Company Id],
	[Invoice Header Bill To Contact],
	ivh.ivh_terms [Invoice Header Terms],
	la_terms.name [Labelfile Terms Name],
	ivh.ivh_totalcharge [Invoice Header Total Charge],
	ivh.ivh_shipper [Invoice Header Shipper],
	sc.cmp_name [Shipper Name],
	CASE ivh.ivh_hideshipperaddr WHEN 'Y' THEN '' ELSE sc.cmp_address1 END [Shipper Add1],
	CASE ivh.ivh_hideshipperaddr WHEN 'Y' THEN '' ELSE sc.cmp_address2 END [Shipper Add2],
	CASE ivh.ivh_shipper WHEN 'UNKNOWN' THEN oc_cty.cty_name + ', ' + oc_cty.cty_state + ' ' + ISNULL(oc.cmp_zip,'') ELSE sc_cty.cty_name + ', ' + sc_cty.cty_state + ' ' + ISNULL(sc.cmp_zip,'') END [Shipper CityStZip],
	sc.cmp_geoloc [Shipper Geoloc],
	ivh.ivh_consignee [Invoice Header Consignee],
	cc.cmp_name [Consignee Name],
	CASE ivh.ivh_hideconsignaddr WHEN 'Y' THEN '' ELSE cc.cmp_address1 END [Consignee Add1],
	CASE ivh.ivh_hideconsignaddr WHEN 'Y' THEN '' ELSE cc.cmp_address2 END [Consignee Add2],
	CASE ivh.ivh_consignee WHEN 'UNKNOWN' THEN dc_cty.cty_name + ', ' + dc_cty.cty_state + ' ' + ISNULL(dc.cmp_zip,'') ELSE cc_cty.cty_name + ', ' + cc_cty.cty_state + ' ' + ISNULL(cc.cmp_zip,'') END [Consignee CityStZip],
	cc.cmp_geoloc [Consignee Geoloc],
	ivh.ivh_originpoint [Invoice Header Origin],
	oc.cmp_name [Origin Company Name],
	oc.cmp_address1 [Origin Add1],
	oc.cmp_address2 [Origin Add2],
	oc_cty.cty_name + ', ' + oc_cty.cty_state + ' ' + ISNULL(oc.cmp_zip,'') [Origin CityStZip],
	ivh.ivh_destpoint [Invoice Header Destination],
	dc.cmp_name [Destination Company Name],
	dc.cmp_address1 [Destination Add1],
	dc.cmp_address2 [Destination Add2],
	dc_cty.cty_name + ', ' + dc_cty.cty_state + ' ' + ISNULL(dc.cmp_zip,'') [Destination CityStZip],
	ivh.ivh_invoicestatus [Invoice Header InvoiceStatus],
	ivh.ivh_origincity [Invoice Header Origin City],
	ivh.ivh_destcity [Invoice Header Destination City],
	ivh.ivh_originstate [Invoice Header Origin State],
	ivh.ivh_deststate [Invoice Header Destination State],
	ivh.ivh_originregion1 [Invoice Header Origin Region 1],
	ivh.ivh_originregion2 [Invoice Header Origin Region 2],
	ivh.ivh_originregion3 [Invoice Header Origin Region 3],
	ivh.ivh_originregion4 [Invoice Header Origin Region 4],
	ivh.ivh_destregion1 [Invoice Header Destination Region 1],
	ivh.ivh_destregion2 [Invoice Header Destination Region 2],
	ivh.ivh_destregion3 [Invoice Header Destination Region 3],
	ivh.ivh_destregion4 [Invoice Header Destination Region 4],
	ivh.ivh_supplier [Invoice Header Supplier],
	ivh.ivh_shipdate [Invoice Header Ship Date],
	ivh.ivh_deliverydate [Invoice Header Delivery Date],
	ivh.ivh_revtype1 [Invoice Header Rev Type 1],
	ivh.ivh_revtype2 [Invoice Header Rev Type 2],
	ivh.ivh_revtype3 [Invoice Header Rev Type 3],
	ivh.ivh_revtype4 [Invoice Header Rev Type 4],
	ivh.ivh_totalweight [Invoice Header Total Weight],
	ivh.ivh_totalpieces [Invoice Header Total Pieces],
	ivh.ivh_totalmiles [Invoice Header Total Miles],
	ivh.ivh_currency [Invoice Header Currency],
	ivh.ivh_currencydate [Invoice Header Currency Date],
	ivh.ivh_totalvolume [Invoice Header Total Volume],
	ivh.ivh_taxamount1 [Invoice Header Tax Amount 1],
	ivh.ivh_taxamount2 [Invoice Header Tax Amount 2],
	ivh.ivh_taxamount3 [Invoice Header Tax Amount 3],
	ivh.ivh_taxamount4 [Invoice Header Tax Amount 4],
	ivh.ivh_transtype [Invoice Header Transaction Type],
	ivh.ivh_creditmemo [Invoice Header Credit Memo],
	ivh.ivh_applyto [Invoice Header Apply To],
	ivh.ivh_printdate [Invoice Header Print Date],
	CASE @billdate WHEN '01/01/1950' THEN ivh.ivh_billdate
    ELSE
         CASE ivh.ivh_invoicestatus WHEN 'PRN' THEN ivh.ivh_billdate
                                    WHEN 'XFR' THEN ivh.ivh_billdate
                                    ELSE @billdate
         END
    END [Invoice Header Bill Date],
	ivh.ivh_lastprintdate [Invoice Header Last Print Date],
	ivh.mfh_hdrnumber [Invoice Header MFH Number],
	ivh.ivh_remark [Invoice Header Remark],
	ivh.ivh_driver [Invoice Header Driver],
	ivh.ivh_tractor [Invoice Header Tractor],
	ivh.ivh_trailer [Invoice Header Trailor],
	ivh.ivh_user_id1 [Invoice Header User Id 1],
	ivh.ivh_user_id2 [Invoice Header User Id 2],
	ivh.ivh_ref_number [Invoice Header 1st Reference Number],
	ivh.ivh_driver2 [Invoice Header Driver 2],
	ivh.mov_number [Invoice Header Move Number],
	ivh.ivh_edi_flag [Invoice Header EDI Flag],
	ivh.ivh_freight_miles [Invoice Header Freight Miles],
	ivh.tar_tarriffnumber [Invoice Header Tariff Number],
	ivh.tar_tariffitem [Invoice Header Tariff Item],
	ISNULL(ivh.ivh_rateby,'T') [Invoice Header Rate By],
	ISNULL(ivh.ivh_charge,0.0) [Invoice Header Charge],
	ivd.ivd_number [Invoice Detail Number],
	ivd.stp_number [Invoice Detail Stop Number],
	ivd.ivd_description	[Invoice Detail Description],
	ivd.cht_itemcode [Invoice Detail Charge Type Item Code],
	ivd.ivd_quantity [Invoice Detail Quantity],
	CASE ct.cht_basis WHEN 'TAX' THEN ISNULL(ivd.ivd_rate, 0)/ 100.0000 ELSE ISNULL(ivd.ivd_rate, 0) END as [Charge Type Rate],
	ivd.ivd_charge [Invoice Detail Charge],
	ivd.ivd_taxable1 [Invoice Detail Taxable 1],
	ivd.ivd_taxable2 [Invoice Detail Taxable 2],
	ivd.ivd_taxable3 [Invoice Detail Taxable 3],
	ivd.ivd_taxable4 [Invoice Detail Taxable 4],
	ivd.ivd_unit [Invoice Detail Unit],
	ivd.cur_code [Invoice Detail Currency Code],
	ivd.ivd_currencydate [Invoice Detail Currency Date],
	ivd.ivd_glnum [Invoice Detail GL Number],
	ivd.ivd_type [Invoice Detail Type],
	ivd.ivd_rate [Invoice Detail Rate],
	ivd.ivd_rateunit [Invoice Detail Rate Unit],
	ivd.ivd_itemquantity [Invoice Detail Item Quantity],
	ivd.ivd_subtotalptr [Invoice Detail Subtotal],
	ivd.ivd_allocatedrev [Invoice Detail Allocated Revenue],
	ivd.ivd_sequence [Charge Group Sort Order],
	ivd.ivd_refnum [Invoice Detail 1st Reference Number],
	ivd.ivd_reftype [Invoice Detail Reference Type],
	ivd.cmd_code [Invoice Detail Commodity Code],
	commodity.cmd_name [Commodity Name],
	commodityclass.ccl_description [Commodity Class Description],
	ivd.cmp_id [Invoice Detail Stop ID],
	stc.cmp_name [Invoice Detail Stop Name],
	stc.cmp_address1 [Invoice Detail Stop Add1],
	stc.cmp_address2 [Invoice Detail Stop Add2],
	stp_cty.cty_name + ', ' + stp_cty.cty_state + ' ' + ISNULL(stc.cmp_zip,'') [Invoice Detail Stop CityStZip],
	ivd.ivd_distance [Invoice Detail Distance],
	ivd.ivd_loaded_distance [Invoice Detail Loaded Distance],
	ivd.ivd_distunit [Invoice Detail Distance Unit],
	ivd.ivd_wgt [Invoice Detail Weight],
	ivd.ivd_wgtunit [Invoice Detail Weight Unit],
	ivd.ivd_count [Invoice Detail Count],
	ivd.ivd_countunit [Invoice Detail Count Unit],
	ivd.ivd_volume [Invoice Detail Volume],
	ivd.ivd_volunit [Invoice Detail Volume Unit],
	ivd.evt_number [Invoice Detail Event Number],
	ivd.ivd_payrevenue [Invoice Detail Pay Revenue],
	ivd.fgt_number [Invoice Detail Freight Number],
	coalesce(ivd.cht_rollINTOLH, 0) [Invoice Detail Roll INTO Linehaul Flag],
	ct.cht_primary [Charge Type Primary],
	ct.cht_basis [Charge Type Basis],
	ct.cht_description [Charge Type Description],
	ivs.ivs_terms [Invoice Format Invoice Terms],
	ivs.ivs_logocompanyname [Invoice Format Company Name],
	ivs.ivs_logocompanyloc [Invoice Format Company Address],
	ivs.ivs_logopicturefile [Invoice Format Company Logo File],
	ivs.ivs_remittocompanyname [Invoice Format Remit To Company Name],
	ivs.ivs_remittocompanyloc [Invoice Format Remit To Company Address],
	CASE 
		WHEN ct.cht_primary = 'Y' THEN 1
		WHEN ct.cht_primary = 'N' THEN 3
		WHEN ct.cht_primary = 'Y' and ct.cht_itemcode = 'MIN' THEN 2
		ELSE 0
	END [Charges Group Sort Order]

INTO #rsInvoice
FROM
	invoiceheader ivh

		INNER JOIN company oc on oc.cmp_id = ivh.ivh_originpoint
		INNER JOIN city oc_cty on oc_cty.cty_code = oc.cmp_city
		INNER JOIN company dc on dc.cmp_id = ivh.ivh_destpoint
		INNER JOIN city dc_cty on dc_cty.cty_code = dc.cmp_city
		INNER JOIN company sc on sc.cmp_id = ivh_shipper
		INNER JOIN city sc_cty on sc_cty.cty_code = sc.cmp_city
		INNER JOIN company cc on cc.cmp_id = ivh_consignee
		INNER JOIN city cc_cty on cc_cty.cty_code = cc.cmp_city
		INNER JOIN invoicedetail ivd on ivd.ivh_hdrnumber = ivh.ivh_hdrnumber
		INNER JOIN company stc on stc.cmp_id = ivd.cmp_id
		INNER JOIN city stp_cty on stp_cty.cty_code = stc.cmp_city
		INNER JOIN labelfile la_terms on (la_terms.labeldefinition = 'creditterms' and la_terms.abbr = ivh.ivh_terms) 
		LEFT OUTER JOIN chargetype ct ON ct.cht_itemcode = ivd.cht_itemcode
		LEFT OUTER JOIN  commodity  ON  ivd.cmd_code  = commodity.cmd_code  
		LEFT OUTER JOIN commodityclass ON commodityclass.ccl_code = commodity.cmd_class
		LEFT OUTER JOIN invoiceSELECTion ivs on ivs.ivs_number = @ivs_number,
	 @Bill_Address BillTo
WHERE ivh.ivh_hdrnumber = @invoice

-- exec invoice_GENERIC150 1545,1,103

------------------------------- END Main SELECT -----------------------------

if (SELECT count(*) FROM #rsInvoice) = 0
	BEGIN
		SELECT @ret_value = 0  
		GOTO ERROR_END
	END

/*     *******************ROLLINTOLH************************     */
/* Handle possible roll INTO lh */

SELECT @rollINTOLHAmt = sum([Invoice Detail Charge]) FROM #rsInvoice WHERE [Invoice Detail Roll INTO Linehaul Flag] = 1

SELECT @rollINTOLHAmt = ISNULL(@rollINTOLHAmt,0)

If @rollINTOLHAmt <> 0 and exists(SELECT 1 FROM #rsInvoice WHERE ([Invoice Detail Type] = 'SUB' or [Invoice Detail Charge Type Item Code] = 'MIN') and [Invoice Detail Quantity] <> 0) 
  BEGIN 
      -- determine if a rate conversion factor is involved in the line haul rate
      If exists (SELECT 1 FROM #rsInvoice WHERE [Invoice Detail Charge Type Item Code] = 'MIN')
        BEGIN
          SELECT @rateconvertion = unc_factor
          FROM #rsInvoice ttbl
          JOIN unitconversion on [Invoice Detail Unit] = unc_FROM and [Invoice Detail Rate Unit] = unc_to and unc_convflag = 'R'
          WHERE ttbl.[Invoice Detail Charge Type Item Code] = 'MIN'
          
          SELECT @rateconvertion = ISNULL(@rateconvertion,1) 

          update #rsInvoice
          SET [Invoice Detail Charge] = 
            CASE [Invoice Detail Charge Type Item Code]
            WHEN 'MIN' THEN [Invoice Detail Charge] + @rollINTOLHAmt
            ELSE 0
            END,
          [Invoice Detail Rate] = 
            CASE [Invoice Detail Quantity]
            WHEN 1 THEN ROUND(([Invoice Detail Charge] + @rollINTOLHAmt) / @rateconvertion,4)
            ELSE ROUND(([Invoice Detail Charge] + @rollINTOLHAmt) / (@rateconvertion * [Invoice Detail Quantity]),4)
            END
          FROM #rsInvoice tmp
          WHERE [Invoice Detail Type] = 'SUB' or [Invoice Detail Charge Type Item Code] = 'MIN'
        END
            
      ELSE 
        BEGIN
          SELECT @rateconvertion = unc_factor
          FROM #rsInvoice ttbl
          JOIN unitconversion on [Invoice Detail Unit] = unc_FROM and [Invoice Detail Rate Unit] = unc_to and unc_convflag = 'R'
          WHERE ttbl.[Invoice Detail Type] = 'SUB'
          
          SELECT @rateconvertion = ISNULL(@rateconvertion,1) 

          update #rsInvoice
          SET [Invoice Detail Charge] =  [Invoice Detail Charge] + @rollINTOLHAmt,
          [Invoice Detail Rate] = 
            CASE [Invoice Detail Quantity]
            WHEN 1 THEN ROUND(([Invoice Detail Charge] + @rollINTOLHAmt) / @rateconvertion,4)
            ELSE ROUND(([Invoice Detail Charge] + @rollINTOLHAmt) / (@rateconvertion * [Invoice Detail Quantity]),4)
            END
          FROM #rsInvoice tmp
          WHERE [Invoice Detail Type] = 'SUB'
        END

    delete FROM #rsInvoice WHERE [Invoice Detail Roll INTO Linehaul Flag] = 1

  END

/* END roll INTO lh */
/*     *******************ROLLINTOLH************************     */

-------------------------- Create Copies of Main SELECT ---------------------

SELECT top 1 [Invoice Header Number], 1 as copies
INTO #rsInvoiceCopy
FROM #rsInvoice 

SELECT @printcount = @printcount + 1

while @printcount <= @copies
	
	BEGIN 
		INSERT INTO #rsInvoiceCopy
		SELECT [Invoice Header Number],@printcount as copies
		FROM #rsInvoiceCopy
		WHERE copies = 1
		SELECT @printcount = @printcount + 1
	END

SELECT 
	#rsInvoiceCopy.copies,
	#rsInvoice.*
FROM #rsInvoice
  	INNER JOIN #rsInvoiceCopy on #rsInvoiceCopy.[Invoice Header Number] = #rsInvoice.[Invoice Header Number]
ORDER BY copies, [Charges Group Sort Order], [Charge Group Sort Order]

----------------------- END Create Copies of Main SELECT --------------------
ERROR_END:

IF @@ERROR != 0 SELECT @ret_value = @@ERROR
RETURN @ret_value


GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_INVOICE_01] TO [public]
GO
