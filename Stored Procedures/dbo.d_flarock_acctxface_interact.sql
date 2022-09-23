SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_flarock_acctxface_interact] 
@invoice_number varchar(12)
AS
/**
 * 
 * REVISION HISTORY:
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @vchar12 varchar(12), @money money, @int int


SELECT @money = 0.00 
SELECT @vchar12 = '            '
SELECT @int = 0
 
CREATE TABLE #invview_interact
	(ivh_invoicestatus varchar(6),
	ivh_mbstatus varchar(6),	
	mov_number int,
	ivh_invoicenumber varchar(12),
	ivh_billto varchar(8),
	ivh_shipdate datetime NULL,
 	ivh_deliverydate datetime NULL,
 	ivh_revtype1 int NULL,
	ivh_revtype2 varchar(6),
 	ivh_printdate datetime NULL,
 	ivh_billdate datetime NULL,
 	ivh_lastprintdate datetime NULL,
 	ord_hdrnumber int,
 	ivh_totalcharge money,
	ivh_totalmiles float,
 	ivh_hdrnumber int,
 	ord_number char(12),
	ivh_trailer varchar(8),
	ivh_tractor varchar(8),
	totallinehaul money,
	ivh_creditmemo varchar(1),
	ship_ticket varchar(12) NULL,
	ivh_driver varchar(8) NULL,
	ivh_cmp_altid varchar(8), 
	ivh_mbnumber int,
	ivh_xferdate datetime NULL,
	cht_primary_count int)

INSERT INTO #invview_interact
SELECT 	IsNull(invoiceheader.ivh_invoicestatus, ''),
	IsNull(invoiceheader.ivh_mbstatus, ''),
	IsNull(invoiceheader.mov_number, 0),
	IsNull(invoiceheader.ivh_invoicenumber, ''),
	IsNull(invoiceheader.ivh_billto, ''), 
	invoiceheader.ivh_shipdate,
 	invoiceheader.ivh_deliverydate,
 	IsNULL(labelfile.code, 0), 
	IsNull(invoiceheader.ivh_revtype2, 'UNK'),
 	invoiceheader.ivh_printdate,
 	invoiceheader.ivh_billdate,
 	invoiceheader.ivh_lastprintdate,
 	IsNull(invoiceheader.ord_hdrnumber, 0),
 	IsNull(invoiceheader.ivh_totalcharge, 0),
	IsNull(invoiceheader.ivh_totalmiles, 0),
 	IsNull(invoiceheader.ivh_hdrnumber, 0),
 	IsNull(invoiceheader.ord_number, ''),
	IsNull(invoiceheader.ivh_trailer, ''),
	IsNull(invoiceheader.ivh_tractor, ''),
	@money 'totallinehaul', 
	IsNull(invoiceheader.ivh_creditmemo, ''),
	@vchar12 'ship_ticket',
	IsNull(invoiceheader.ivh_driver, ''),
	IsNull(company.cmp_altid, ''),
	IsNull(invoiceheader.ivh_mbnumber, -1),
	invoiceheader.ivh_xferdate,
	@int 'cht_primary'
	FROM  invoiceheader  LEFT OUTER JOIN  labelfile  ON  (invoiceheader.ivh_revtype1  = labelfile.abbr and labelfile.labeldefinition  = 'RevType1'),
		 company --, invoicedetail, chargetype
	WHERE	invoiceheader.ivh_billto  = company.cmp_id
	 AND	invoiceheader.ivh_invoicenumber  = @invoice_number

-- Provide a total linehaul charge for each invoice
UPDATE	#invview_interact
SET	totallinehaul = (SELECT	ISNULL(SUM(d.ivd_charge),0) 
				FROM 	invoicedetail d, chargetype c
				WHERE	#invview_interact.ivh_hdrnumber = d.ivh_hdrnumber
				AND	d.cht_itemcode = c.cht_itemcode
				AND	c.cht_primary = 'Y'
				)

-- Provide a count of linehaul items for each invoice
UPDATE	#invview_interact
SET	cht_primary_count = (SELECT	count(*) 
				FROM 	invoicedetail d, chargetype c
				WHERE	#invview_interact.ivh_hdrnumber = d.ivh_hdrnumber
				AND	d.cht_itemcode = c.cht_itemcode
				AND	c.cht_primary = 'Y'
				)

-- Provide a shippers ticket for each invoice
UPDATE	#invview_interact
SET	ship_ticket = (SELECT	Min(IsNull(r.ref_number, @vchar12))
				FROM 	referencenumber r
				WHERE	#invview_interact.ord_hdrnumber = r.ref_tablekey
				AND	r.ref_table = 'orderheader'
				AND	r.ref_type = 'SHIPTK'
				)

-- Provide a PO Number for each invoice without a shippers ticket
UPDATE	#invview_interact
SET	ship_ticket = (SELECT	Min(IsNull(r.ref_number, @vchar12))
				FROM 	referencenumber r
				WHERE	#invview_interact.ord_hdrnumber = r.ref_tablekey
				AND	r.ref_table = 'orderheader'
				AND	r.ref_type = 'PO#'
				)
WHERE	ship_ticket Is Null Or ship_ticket = @vchar12

SELECT * from #invview_interact
GO
GRANT EXECUTE ON  [dbo].[d_flarock_acctxface_interact] TO [public]
GO
