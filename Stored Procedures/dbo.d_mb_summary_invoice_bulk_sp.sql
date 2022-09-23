SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_mb_summary_invoice_bulk_sp](@billto varchar(30),
	@start_date datetime,
	@end_date datetime,
	@print_status varchar(10),
	@mbnumber int,
	@rpt_date datetime)
AS
/**
 * 
 * NAME:
 * dbo.d_mb_summary_invoice_bulk_sp
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001:    
 * Calls002:    
 *
 * CalledBy001:  
 * CalledBy002:  
 *
 * 
 * REVISION HISTORY:
 * Original: 11/17/97 wsc - Added to the return set so can use for Bulkmatic 
 * pts 2532
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 * 10/31/2007.01 ? PTS40115 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/


/**********************************************************************************************/
/* Declaration and initialization of variables */

DECLARE @char1 varchar(30),
        @char2 int,
        @char3 datetime,
        @char4 real,
        @char5 money,
        @char6 varchar(5),
        @char7 varchar(13),
        @char8 varchar(7),
	@char9 varchar(8),
	@char10 varchar(40),
	@char11 varchar(25),
	@char12 varchar(9),
	@char13 varchar(60),
	@minord int
	
SELECT @start_date = convert(char(12), @start_date) +'00:00:00'
SELECT @end_date = convert(char(12), @end_date) +'23:59:59'

/**********************************************************************************************/
/* Create temporary table for MasterBill */

SELECT ivh1.ivh_invoicenumber invoice_number, 
	ivh1.ivh_hdrnumber,
	ivh1.ivh_revtype4,
	ivh1.ivh_billdate,
	ivh1.ivh_billto,
	ivh1.ivh_mbnumber,
	@char1 cmp_billto_name,
	@char10 cmp_billto_address1,
	@char10 cmp_billto_address2,
       	@char11 cmp_billto_cty_nmstct,
	@char12 cmp_billto_zip,
	ivh1.ivh_carrier,
	ivh1.ivh_totalcharge,
	ivh1.ivh_shipdate,
	ivh1.ivh_ref_number,
	@rpt_date invoice_date,
	carrier.car_name,
	l.name,
 	ivd1.ivd_refnum,
 	(SELECT MIN(ref_number) 	
		FROM referencenumber, invoiceheader ivh3, orderheader oh3
		WHERE ivh3.ivh_invoicenumber = ivh1.ivh_invoicenumber
		AND ivh3.ord_hdrnumber = oh3.ord_hdrnumber
		AND oh3.ord_hdrnumber = referencenumber.ref_tablekey
		AND referencenumber.ref_table = 'stops'
		AND referencenumber.ref_type = 'BL#') ordhdr_bl,
	ivd1.ord_hdrnumber ord_hdrnumber,
	@char2 carrier_order_num,
	@char1 unit_br,
	@char8 tractor,
	@char6 trailer,
	ivh1.ivh_consignee consignee_id,
	@char7 consignee,
	@char3 order_date,
	@char6 load_point,
	@char6 unld_point,
	(SELECT MIN(ivd4.cmd_code)
		FROM invoicedetail ivd4
		WHERE ivd4.ivh_hdrnumber = ivh1.ivh_hdrnumber
		AND ivd4.cht_itemcode = 'DEL') product,
	ivd1.ivd_quantity quant,
	ivd1.ivd_rateunit um,
	ivd1.ivd_rate rate,
	@char4 freight_amount,
	ivd1.ivd_charge revenue,
	ivd1.cht_itemcode code,
	@char1 lab_gst,
	@char1 lab_pst,
	@char5 tot_gst,
	@char5 tot_pst,
	@char7 gst_number,
	@char7 branch_phone,
	@char1 cht_desc,
	ivd1.ivd_sequence,
	ivh1.ord_number,
	ivh1.ivh_shipper,
	@char1 cmp_shipper_name,
	@char10 cmp_shipper_address1,
	@char10 cmp_shipper_address2,
       	@char11 cmp_shipper_cty_nmstct,
	@char12 cmp_shipper_zip,
	@char1 cmp_billto_contact,
	(SELECT MIN(ivd5.ivd_wgt)
		FROM invoicedetail ivd5
		WHERE ivd5.ivh_hdrnumber = ivh1.ivh_hdrnumber
		AND ivd5.cht_itemcode = 'DEL')	ivd_wgt,
	@char11 consignee_cty_nmstct,
	@char13 cmd_name
INTO #masterbill
FROM invoiceheader ivh1 left outer join carrier on ivh1.ivh_carrier = carrier.car_id, --pts40115 jg outer join conversion
	invoicedetail ivd1,
	labelfile l
WHERE (ivh1.ivh_hdrnumber = ivd1.ivh_hdrnumber)
AND (ivh1.ivh_billto = @billto )
AND (ivh1.ivh_mbnumber is null OR ivh1.ivh_mbnumber = 0 OR ivh1.ivh_mbnumber = @mbnumber)
AND (ivh1.ivh_mbstatus = @print_status OR (ivh_invoicestatus <> 'HLD' and ivh_mbstatus is null ))
AND (l.labeldefinition = 'RevType4')
AND (ivh1.ivh_revtype4 = l.abbr)
AND (ivh1.ivh_shipdate between @start_date and @end_date)

/**********************************************************************************************/

SELECT @minord = 0

WHILE (	SELECT COUNT(DISTINCT ord_hdrnumber)
	FROM #masterbill
	WHERE ord_hdrnumber > @minord) > 0

	BEGIN

	SELECT @minord = MIN(ord_hdrnumber)
	FROM #masterbill
	WHERE ord_hdrnumber > @minord
	
	/* Find first billable frieght stop */

	UPDATE #masterbill
	SET load_point = stops.cmp_name              
	FROM stops
	WHERE stops.ord_hdrnumber = @minord
	AND #masterbill.ord_hdrnumber = @minord
	AND stops.stp_mfh_sequence = (	SELECT MIN(stp_mfh_sequence)
					FROM stops, eventcodetable
					WHERE stops.ord_hdrnumber = @minord
					AND stops.stp_type = 'PUP'
					AND stops.stp_event = eventcodetable.abbr
					AND eventcodetable.ect_billable = 'Y')

	/* Find last billable frieght stop */

	UPDATE #masterbill
	SET unld_point = stops.cmp_name
	FROM stops
	WHERE stops.ord_hdrnumber = @minord
	AND #masterbill.ord_hdrnumber = @minord
	AND stops.stp_mfh_sequence = (	SELECT MAX(stp_mfh_sequence)
					FROM stops, eventcodetable
					WHERE stops.ord_hdrnumber = @minord
					AND stops.stp_type = 'DRP'
					AND stops.stp_event = eventcodetable.abbr
					AND eventcodetable.ect_billable = 'Y')

	/* Find tractor and trailer from the event table for each invoice */
  
	UPDATE #masterbill
	SET tractor = event.evt_tractor,
		trailer = event.evt_trailer1
	FROM event
	WHERE event.ord_hdrnumber = @minord
	AND #masterbill.ord_hdrnumber = @minord

	/* Find order date from the orderheader table for each invoice */

	UPDATE #masterbill
	SET order_date = orderheader.ord_datetaken
        FROM orderheader
	WHERE orderheader.ord_hdrnumber = @minord
	AND #masterbill.ord_hdrnumber = @minord

	/* Find freight amount for each order for each invoice */

	UPDATE #masterbill
	SET freight_amount = revenue
	FROM #masterbill
	WHERE #masterbill.ord_hdrnumber = @minord

  	/* Find consignee for each order for each invoice */

 	UPDATE #masterbill
	SET consignee = company.cmp_name,
		consignee_cty_nmstct = city.cty_nmstct
	FROM #masterbill, company, city
	WHERE #masterbill.ord_hdrnumber = @minord
	AND #masterbill.consignee_id = company.cmp_id
	AND company.cmp_city = city.cty_code

/**********************************************************************************************/
/*	GST and PST calculations
	UPDATE #masterbill
	SET tot_gst = (SELECT SUM(revenue)
			FROM #masterbill, labelfile
			WHERE #masterbill.ord_hdrnumber = @minord
			AND #masterbill.code = labelfile.abbr
			AND labelfile.labeldefinition = 'TaxType1')
 	FROM labelfile, #masterbill
	WHERE #masterbill.ord_hdrnumber = @minord
	AND #masterbill.code = labelfile.abbr
	AND labelfile.labeldefinition = 'TaxType1'

	UPDATE #masterbill
	SET tot_pst = (SELECT SUM(revenue)
			FROM #masterbill, labelfile
			WHERE #masterbill.ord_hdrnumber = @minord
			AND #masterbill.code = labelfile.abbr
			AND labelfile.labeldefinition = 'TaxType2')
	FROM labelfile, #masterbill
	WHERE #masterbill.ord_hdrnumber = @minord
	AND #masterbill.code = labelfile.abbr
	AND labelfile.labeldefinition = 'TaxType2'    

	UPDATE #masterbill
	SET lab_gst = (SELECT labelfile.abbr
			FROM labelfile
			WHERE #masterbill.ord_hdrnumber = @minord
			AND #masterbill.code = labelfile.abbr
			AND labelfile.labeldefinition = 'TaxType1')
	FROM labelfile, #masterbill
	WHERE #masterbill.ord_hdrnumber = @minord
	AND #masterbill.code = labelfile.abbr
	AND labelfile.labeldefinition = 'TaxType1'

	UPDATE #masterbill
	SET lab_pst = (SELECT labelfile.abbr
			FROM labelfile
			WHERE #masterbill.ord_hdrnumber = @minord
			AND #masterbill.code = labelfile.abbr
			AND labelfile.labeldefinition = 'TaxType2')
	FROM labelfile, #masterbill
	WHERE #masterbill.ord_hdrnumber = @minord
	AND #masterbill.code = labelfile.abbr
	AND labelfile.labeldefinition = 'TaxType2'
*/ 
/**********************************************************************************************/	
/* GST
	UPDATE #masterbill
	SET #masterbill.product = #masterbill.code
	FROM #masterbill, labelfile
	WHERE #masterbill.code = labelfile.abbr
	AND labelfile.labeldefinition = 'TaxType1'
	AND #masterbill.ord_hdrnumber = @minord

	UPDATE #masterbill
	SET #masterbill.quant = (SELECT SUM(a.freight_amount)
					FROM #masterbill a, labelfile b, labelfile c
					WHERE b.labeldefinition = 'TaxType1'
					AND c.labeldefinition = 'TaxType2'
					AND b.abbr <> a.code
					AND c.abbr <> a.code)
	FROM #masterbill, labelfile
	WHERE #masterbill.code = labelfile.abbr
	AND labelfile.labeldefinition = 'TaxType1'
	AND #masterbill.ord_hdrnumber = @minord

	UPDATE #masterbill
	SET #masterbill.freight_amount = #masterbill.tot_gst
	FROM #masterbill, labelfile
	WHERE #masterbill.code = labelfile.abbr
	AND labelfile.labeldefinition = 'TaxType1'
	AND #masterbill.ord_hdrnumber = @minord
*/	
/**********************************************************************************************/
/* PST
	UPDATE #masterbill
	SET #masterbill.product = #masterbill.code
	FROM #masterbill, labelfile
	WHERE #masterbill.code = labelfile.abbr
	AND labelfile.labeldefinition = 'TaxType2'
	AND #masterbill.ord_hdrnumber = @minord

	UPDATE #masterbill
	SET #masterbill.quant = (SELECT SUM(a.freight_amount)
					FROM #masterbill a, labelfile b, labelfile c
					WHERE b.labeldefinition = 'TaxType1'
					AND c.labeldefinition = 'TaxType2'
					AND b.abbr <> a.code
					AND c.abbr <> a.code)
	FROM #masterbill, labelfile
	WHERE #masterbill.code = labelfile.abbr
	AND labelfile.labeldefinition = 'TaxType2'
	AND #masterbill.ord_hdrnumber = @minord

	UPDATE #masterbill
	SET #masterbill.freight_amount = #masterbill.tot_pst
	FROM #masterbill, labelfile
	WHERE #masterbill.code = labelfile.abbr
	AND labelfile.labeldefinition = 'TaxType2'
	AND #masterbill.ord_hdrnumber = @minord  


	Charge type description for accessorial charges
      
 	UPDATE #masterbill
	SET cht_desc = chargetype.cht_description
	FROM #masterbill, chargetype
	WHERE #masterbill.code = chargetype.cht_itemcode
	AND ord_hdrnumber = @minord */
	
 	END

/**********************************************************************************************/
/* Find branch */
   
UPDATE #masterbill
SET unit_br = orderheader.ord_revtype1
FROM orderheader
WHERE orderheader.ord_billto = @billto

/* Find branch tax id and branch phone

UPDATE #masterbill
SET gst_number = branch.brn_tax_id,
	branch_phone = branch.brn_phone
FROM branch, #masterbill
WHERE #masterbill.unit_br = branch.brn_id
*/

/* Find billto company info */
UPDATE #masterbill
SET cmp_billto_name = company.cmp_name,
	cmp_billto_address1 = company.cmp_address1,
	cmp_billto_address2 = company.cmp_address2,
	cmp_billto_cty_nmstct = city.cty_nmstct,
	cmp_billto_zip = city.cty_zip,
	cmp_billto_contact = company.cmp_contact
FROM #masterbill, company, city
WHERE #masterbill.ivh_billto = company.cmp_id
AND company.cmp_city = city.cty_code

/* Find shipper company info */
UPDATE #masterbill
SET cmp_shipper_name = company.cmp_name,
	cmp_shipper_address1 = company.cmp_address1,
	cmp_shipper_address2 = company.cmp_address2,
       	cmp_shipper_cty_nmstct = city.cty_nmstct,
	cmp_shipper_zip = city.cty_zip
FROM #masterbill, company, city
WHERE #masterbill.ivh_shipper = company.cmp_id
AND company.cmp_city = city.cty_code

/* Find commodity name */
UPDATE #masterbill
SET cmd_name = commodity.cmd_name
FROM commodity
WHERE #masterbill.product = commodity.cmd_code

/* Get exchange
INSERT INTO #masterbill
SELECT ivh1.ivh_invoicenumber invoice_number, 
	ivh1.ivh_hdrnumber, 
	'',
	ivh1.ivh_billdate, 
	'',
	0,
	'',
	'',
	'',
	'',
	'',
	'',
	0,
	ivh1.ivh_shipdate,
	'',
	@rpt_date invoice_date, 
	'',
	'',
	'',
	'',
	ivh1.ord_hdrnumber ord_hdrnumber,
	0,
	'',
	'',
	'',
	'',
	'',
	@char3 order_date,
	'',
	'',
	'Exchange',
	ivh1.ivh_totalcharge,
	'%',
	(ivh1.ivh_archarge / ivh_totalcharge ), 
	(ivh_archarge - ivh1.ivh_totalcharge ), 
	(ivh_archarge - ivh1.ivh_totalcharge), 
	'',
	'',
	'',
	0,
	0,
	'',
	'',
	'',
	999,
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	0,
	'',
	''
FROM invoiceheader ivh1
WHERE (ivh1.ivh_billto = @billto )
AND (ivh1.ivh_mbnumber is null OR ivh1.ivh_mbnumber = 0 OR ivh1.ivh_mbnumber = @mbnumber)
AND (ivh1.ivh_mbstatus = @print_status OR ivh1.ivh_mbstatus is null)
AND (ivh1.ivh_shipdate between @start_date and @end_date)
AND ivh1.ivh_archarge <> ivh1.ivh_totalcharge
*/

SELECT * from #masterbill
ORDER BY invoice_number, ivd_sequence

GO
GRANT EXECUTE ON  [dbo].[d_mb_summary_invoice_bulk_sp] TO [public]
GO
