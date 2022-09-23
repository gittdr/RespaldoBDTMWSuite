SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
  Created for Florida Rock which has complicated rules for qualifying
  an invoice for EDI transmission.  The stored proc returns the same
  information as the d_invoice_view datawindow (SQL in datawindow)
  But the edi code has been manipulated by passing thru Florida ROcks
  qualification rules. 

  This is the same as d_invoices_printqueue2_sp, but is for a single invoice.
  There is no retrieval for master bill information
*/
 /* MODIFICATION LOG

PTS 8790 DPETE 5/23/01 return cmp_invoicetype so that we may bypass any output while 'printing'.
		Allows one to pass data to accounting without printint .
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
*/



CREATE PROC [dbo].[d_invoice_printqueue2_sp] (@ivhhdrnumber int)
AS

DECLARE @int0  int, @varchar6 varchar(6), @varchar8 varchar (8), @money money, 
	@varchar254 varchar(254), @varchar30 varchar(30), @char3 char(3), @charn char,
	@chary char, @varchar20 varchar(20), @char1 char(1), @copies smallint
SELECT @int0 = 0, @money = 0.00, @varchar8 = '', @varchar30 = '', @varchar254 = '',
     @varchar6 = '', @char3 = '', @charn = 'N', @chary = 'Y',@varchar20 = '',@copies = 0
 
CREATE TABLE #invview (	
	mov_number int NULL,
	ivh_invoicenumber varchar(12) NULL,
	ivh_invoicestatus varchar(6) NULL,
	ivh_billto varchar(8) NULL,
-- PTS 30277 -- BL (start)
--	billto_name varchar(30) NULL,
	billto_name varchar(100) NULL,
-- PTS 30277 -- BL (end)
	ivh_shipper varchar(8) NULL,
-- PTS 30277 -- BL (start)
--	shipper_name varchar(30) NULL,
	shipper_name varchar(100) NULL,
-- PTS 30277 -- BL (end)
	ivh_consignee varchar(8) NULL,
-- PTS 30277 -- BL (start)
--	consignee_name varchar(30) NULL,
	consignee_name varchar(100) NULL,
-- PTS 30277 -- BL (end)
	ivh_shipdate datetime NULL,
 	ivh_deliverydate datetime NULL,
 	ivh_revtype1 varchar(6) NULL,
 	ivh_revtype2 varchar(6) NULL,
 	ivh_revtype3 varchar(6) NULL,
 	ivh_revtype4 varchar(6) NULL,
 	ivh_totalweight float NULL,
 	ivh_totalpieces float NULL,
 	ivh_totalmiles float NULL,
 	ivh_totalvolume float NULL,
 	ivh_printdate datetime NULL,
 	ivh_billdate datetime NULL,
 	ivh_lastprintdate datetime NULL,
 	ord_hdrnumber int NULL,
 	ivh_remark varchar(254) NULL,
 	ivh_edi_flag char(30) NULL,
 	ivh_totalcharge money NULL,
	RevType1 char(8) NULL,
 	RevType2 char(8) NULL,
 	Revtype3 char(8) NULL,
 	RevType4 char(8) NULL,
 	ivh_hdrnumber int NULL,
 	ivh_order_by varchar(8) NULL,
 	ivh_user_id1 char(20) NULL,
 	ord_number char(12) NULL,
	ivh_terms char(3) NULL,
	ivh_trailer varchar(8) NULL,
	ivh_tractor varchar(8) NULL,
	commodities int NULL,
	validcommodities int NULL,
	accessorials int NULL,
	validaccessorials int NULL,
	trltype3 varchar(6) NULL,
	cmp_subcompany varchar(6) NULL,
	totallinehaul money NULL,
	negativecharges int NULL,
	edi_210_flag int NULL,
	ismasterbill char(1) NULL,
	trltype3name char(8) NULL, 
	cmp_mastercompany varchar(8) NULL,
	refnumber varchar(30) NULL,
	cmp_invoiceto char(3) NULL,
	cmp_invprintto char(1) NULL,
	cmp_invformat int NULL,
	cmp_transfertype varchar(6) NULL,
	ivh_mbstatus varchar(6) NULL,
	trp_linehaulmax money NULL,
	trp_totchargemax money NULL,
	cmp_invcopies smallint NULL,
	cmp_invoicetype varchar(6) NULL,
	ivh_definition varchar(6) NULL,
	ivh_applyto varchar(12) NULL,
	cmp_image_routing1	varchar(254) NULL,
	cmp_image_routing2	varchar(254) NULL,
	cmp_image_routing3	varchar(254) NULL,
	ivh_company	varchar(6) null
	)

INSERT INTO #invview
SELECT invoiceheader.mov_number,
 	invoiceheader.ivh_invoicenumber,
 	invoiceheader.ivh_invoicestatus,
 	invoiceheader.ivh_billto,
 	bcmp.cmp_name billto_name,
 	invoiceheader.ivh_shipper,
 	scmp.cmp_name shipper_name,
 	invoiceheader.ivh_consignee,
 	ccmp.cmp_name consignee_name,
 	invoiceheader.ivh_shipdate,
 	invoiceheader.ivh_deliverydate,
 	invoiceheader.ivh_revtype1,
 	invoiceheader.ivh_revtype2,
 	invoiceheader.ivh_revtype3,
 	invoiceheader.ivh_revtype4,
 	invoiceheader.ivh_totalweight,
 	invoiceheader.ivh_totalpieces,
 	invoiceheader.ivh_totalmiles,
 	invoiceheader.ivh_totalvolume,
 	invoiceheader.ivh_printdate,
 	invoiceheader.ivh_billdate,
 	invoiceheader.ivh_lastprintdate,
 	ord_hdrnumber,
 	ivh_remark,
 	invoiceheader.ivh_edi_flag,
 	invoiceheader.ivh_totalcharge,
	'RevType1' RevType1,
 	'RevType2' RevType2,
 	'RevType3' Revtype3,
 	'RevType4' RevType4,
 	invoiceheader.ivh_hdrnumber,
 	invoiceheader.ivh_order_by,
 	invoiceheader.ivh_user_id1,
 	invoiceheader.ord_number,
	invoiceheader.ivh_terms,
	invoiceheader.ivh_trailer,
	invoiceheader.ivh_tractor,
	@int0 'commodities',
	@int0 'validcommodities',
	@int0 'accessorials',
	@int0 'validaccessorials',
	@varchar6 'trltype3',
	bcmp.cmp_subcompany ,
	@money 'totallinehaul',
	@int0 'negativecharges',
	bcmp.cmp_edi210 'edi_210_flag',
	@charn 'ismasterbill',
	'Trltype3' trltype3name,
	bcmp.cmp_mastercompany,
	@varchar30 'refnumber',
	bcmp.cmp_invoiceto,
	bcmp.cmp_invprintto,
	bcmp.cmp_invformat,
	bcmp.cmp_transfertype,
	invoiceheader.ivh_mbstatus,
	@money trp_linehaulmax,
	@money trp_totchargemax,
	bcmp.cmp_invcopies,
	bcmp.cmp_invoicetype,
	ivh_definition,
	ivh_applyto,
	bcmp.cmp_image_routing1,
	bcmp.cmp_image_routing2,
	bcmp.cmp_image_routing3,
	ivh_company	
	FROM invoiceheader, company bcmp, company scmp, company ccmp 
	WHERE ( @ivhhdrnumber = invoiceheader.ivh_hdrnumber ) 
	AND     ( bcmp.cmp_id = invoiceheader.ivh_billto)
	AND     ( scmp.cmp_id = invoiceheader.ivh_shipper)
	AND	( ccmp.cmp_id = invoiceheader.ivh_consignee)

-- return the trltype3 column value (for flarock indicates tank, dump, flatbed) 
UPDATE	#invview 
SET	trltype3 =  t.trl_type3 
FROM	Trailerprofile t
Where	t.trl_number = #invview.ivh_trailer

-- Provide a total linehaul charge for each invoice
UPDATE	#invview
SET	totallinehaul = (SELECT	SUM(d.ivd_charge)
				FROM 	invoicedetail d, chargetype c
				WHERE	#invview.ivh_hdrnumber = d.ivh_hdrnumber
				AND	d.cht_itemcode = c.cht_itemcode
				AND	c.cht_primary = 'Y'
				)

--dpete 4/29/99 ignore ORDFLT when cking commodities				
-- Count the  distinct commodities on the invoice
	UPDATE 	#invview 
	SET	commodities =   (SELECT COUNT(DISTINCT(d.cmd_code))
						FROM	invoicedetail d  LEFT OUTER JOIN  CHARGETYPE C  ON (d.cht_itemcode  = c.cht_itemcode and ISNULL(c.cht_primary,'N') = 'Y') --pts40012, jg, outer join conversion
						WHERE	#invview.ivh_hdrnumber = d.ivh_hdrnumber
							AND 	d.cht_itemcode NOT IN ('MIN','ORDFLT')
							AND	d.ivd_type <> 'SUB')
			
-- Count the commodities which match to the edicommodity table
	UPDATE 	#invview
	SET	validcommodities =  (SELECT COUNT(DISTINCT(d.cmd_code))
				FROM	edicommodity e, 
						invoicedetail d  LEFT OUTER JOIN  CHARGETYPE C  ON (d.cht_itemcode  = c.cht_itemcode and ISNULL(c.cht_primary,'N') = 'Y') --pts40012, jg, outer join conversion
				WHERE	d.ivh_hdrnumber = #invview.ivh_hdrnumber
				AND	d.ivd_type <> 'SUB'
				AND d.cht_itemcode NOT IN ('MIN','ORDFLT')
				AND	e.cmp_id = #invview.ivh_billto
				AND	e.cmd_code = d.cmd_code)

-- Count the number of charge lines which have either a negative qty or rate
-- Used to edit for invoice with adjustments (negative entries)
Update	#invview
SET	negativecharges = (SELECT count(*)
			FROM   invoicedetail d
			WHERE  d.ivh_hdrnumber = #invview.ivh_hdrnumber
			AND    (d.ivd_quantity < 0 OR d.ivd_rate < 0.0) 
			AND    d.ivd_charge <> 0.0  ) 
-- Obtain the shippers ticket reference number
-- required by Florida Rock
UPDATE 	#invview
SET	refnumber = r.ref_number
FROM	referencenumber r
WHERE	r.ref_table = 'ORDERHEADER'
AND	r.ref_tablekey = #invview.ord_hdrnumber
AND     r.ref_type = 'SHIPTK'

-- retrieve any max charges for edi qualification
UPDATE 	#invview
SET	trp_linehaulmax = t.trp_linehaulmax,
	trp_totchargemax = t.trp_totchargemax
FROM	edi_trading_partner t
WHERE	t.cmp_id = #invview.ivh_billto

SELECT * from #invview

GO
GRANT EXECUTE ON  [dbo].[d_invoice_printqueue2_sp] TO [public]
GO
