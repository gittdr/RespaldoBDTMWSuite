SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_scroll_invoices_acct_sp] (
	@billto varchar(8),
	@shipper varchar(8),
	@consignee varchar(8),
	@shipdate1 datetime,
	@shipdate2 datetime,
	@deldate1 datetime,
	@deldate2 datetime,
	@rev1 varchar(6),
	@rev2 varchar(6),
	@rev3 varchar(6),
	@rev4 varchar(6),
	@edi_flag varchar(30),
	@orderedby varchar(8),
	@statusntp varchar(3),
	@statushld varchar(3),
	@statusrtp varchar(3),
	@statuspro varchar(3),
	@statusprn varchar(3),
	@statusxfr varchar(3),
	@statuscan varchar(3),
	@statuscld varchar(3))
AS
/**
 * DESCRIPTION:
 * Accounting transfer data source for d_scroll_invoices_acct_sp
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * Original: 10/28/97 wsc
 * Modified: 11/06/97 wsc - added sid ref number
 * 11/1/2007.01 ? PTS40115 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

CREATE TABLE #temp_rtn (
	ivh_invoicenumber varchar(12) not null,
	ivh_billdate datetime null,
	ivh_totalcharge money null,
	ivh_billto varchar(8) null,
	ivh_xferdate datetime null,
	ivh_invoicestatus varchar(6) null,
	ivh_applyto varchar(12) null,
	ivh_user_id1 varchar(20) null,
	ivh_ref_number varchar(30) null,
	ivh_shipdate datetime null,
	ivh_bookyear tinyint null,
	ivh_bookmonth tinyint null,
	ivh_hdrnumber int null,
	ivh_deliverydate datetime null,
	ivh_consignee varchar(8) null,
	ivh_terms char(3) null,
	ivh_remark varchar(254) null,
	ivh_destpoint varchar(8) null,
	ivh_totalweight float null,
	ord_hdrnumber int null,
	ivh_creditmemo char(1) null,
	ivh_taxamount money null,
	ord_number varchar(12) null,
	ivh_driver varchar(8) null,
	ivh_revtype1 varchar(6) null,
	terminal varchar(6) null,
	invoicestatus varchar(20) null,
	sidrefnumber varchar(30) null)

INSERT INTO #temp_rtn
SELECT ivh.ivh_invoicenumber,
	ivh.ivh_billdate,
	ivh.ivh_totalcharge,
	ivh.ivh_billto,
	ivh.ivh_xferdate,
	ivh.ivh_invoicestatus,
	ivh.ivh_applyto,
	ivh.ivh_user_id1,
	ivh.ivh_ref_number,
	ivh.ivh_shipdate,
	ivh.ivh_bookyear,
	ivh.ivh_bookmonth,
	ivh.ivh_hdrnumber,
	ivh.ivh_deliverydate,
	ivh.ivh_consignee,
	ivh.ivh_terms,
	ivh.ivh_remark,
	ivh.ivh_destpoint,
	ivh.ivh_totalweight,
	ivh.ord_hdrnumber,
	ivh.ivh_creditmemo,
	ivh.ivh_taxamount1 + ivh.ivh_taxamount2 + ivh.ivh_taxamount3 + ivh.ivh_taxamount4,
	ord.ord_number,
	ivh.ivh_driver,
	ivh.ivh_revtype1,
	mpp.mpp_terminal,
	lbf.name,
	null
	FROM invoiceheader ivh  LEFT OUTER JOIN  orderheader ord  ON  ivh.ord_hdrnumber  = ord.ord_hdrnumber   
			LEFT OUTER JOIN  manpowerprofile mpp  ON  ivh.ivh_driver  = mpp.mpp_id   
			LEFT OUTER JOIN  labelfile lbf  ON  (ivh.ivh_invoicestatus  = lbf.abbr AND lbf.labeldefinition = 'InvoiceStatus') 
	WHERE @billto IN ('UNKNOWN', ivh.ivh_billto)
	AND @shipper IN ('UNKNOWN', ivh.ivh_shipper)
	AND @consignee IN ('UNKNOWN', ivh.ivh_consignee)
	AND ivh.ivh_shipdate BETWEEN @shipdate1 AND @shipdate2
	AND ivh.ivh_deliverydate BETWEEN @deldate1 AND @deldate2
	AND @rev1 IN ('UNK', ivh.ivh_revtype1)
	AND @rev2 IN ('UNK', ivh.ivh_revtype2)
	AND @rev3 IN ('UNK', ivh.ivh_revtype3)
	AND @rev4 IN ('UNK', ivh.ivh_revtype4)
	AND @edi_flag IN ('NONE', ivh.ivh_edi_flag)
	AND @orderedby IN ('UNKNOWN', ivh.ivh_order_by)
	AND (ivh.ivh_invoicenumber = ivh.ivh_applyto OR ivh.ivh_totalcharge > 0)
	AND ivh.ivh_invoicestatus IN (@statusntp, @statushld, @statusrtp, @statuspro, @statusprn, @statusxfr, @statuscan, @statuscld)

/* Get the revenue type 1 if no driver >>>> jam is for Bulkmatic */
UPDATE #temp_rtn
SET terminal = ISNULL(ivh_revtype1, '')
WHERE terminal IS null

/* Get the shipper id reference number >>> for Bulkmatic */
UPDATE #temp_rtn
SET sidrefnumber = (SELECT isnull(min(ref_number), '')
			FROM referencenumber, #temp_rtn
			WHERE #temp_rtn.ord_hdrnumber = ref_tablekey
			AND ref_table = 'orderheader'
			AND ref_sid = 'Y')

SELECT *
FROM #temp_rtn
ORDER BY ivh_hdrnumber
GO
GRANT EXECUTE ON  [dbo].[d_scroll_invoices_acct_sp] TO [public]
GO
