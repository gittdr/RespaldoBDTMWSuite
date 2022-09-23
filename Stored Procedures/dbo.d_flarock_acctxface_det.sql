SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_flarock_acctxface_det] 
AS
/**
 * 
 * REVISION HISTORY:
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/
 
CREATE TABLE #invdet (
	ivh_invoicenumber varchar(12),
	ivd_number int,	
	ivh_hdrnumber int,
	ivd_charge money,
	ord_number varchar(12),
	cht_itemcode varchar(6),
	cht_basis varchar(6),
	cht_glnum char(16) NULL,
	ivh_tractor varchar(8),
 	ord_hdrnumber int,
 	ivh_revtype1 int,
	ivh_creditmemo varchar(1),
	ivh_billdate datetime
	)

INSERT INTO #invdet
SELECT  IsNull(invoiceheader.ivh_invoicenumber, ''),
	IsNull(invoicedetail.ivd_number, 0),
	IsNull(invoicedetail.ivh_hdrnumber, 0),
	IsNull(invoicedetail.ivd_charge, 0),
	IsNull(invoiceheader.ord_number, ''),
	IsNull(invoicedetail.cht_itemcode, ''),
	IsNull(chargetype.cht_basis, ''),
	IsNull(chargetype.cht_glnum, ''),
	IsNull(invoiceheader.ivh_tractor, ''),
	Isnull(invoiceheader.ord_hdrnumber, 0),
	IsNull(labelfile.code, 0),
	IsNull(invoiceheader.ivh_creditmemo, ''),
	IsNull(invoiceheader.ivh_billdate, getdate())
FROM  invoiceheader  LEFT OUTER JOIN  labelfile  ON  (invoiceheader.ivh_revtype1  = labelfile.abbr and labelfile.labeldefinition  = 'RevType1'),
	 invoicedetail,
	 chargetype 
WHERE	 (invoicedetail.ivh_hdrnumber  = invoiceheader.ivh_hdrnumber)
 AND	(chargetype.cht_itemcode  = invoicedetail.cht_itemcode)
 AND	(chargetype.cht_primary  <> 'Y')
 AND	(invoiceheader.ivh_invoicestatus  = 'PRN')

SELECT * from #invdet order by ivh_hdrnumber, ivh_invoicenumber
GO
GRANT EXECUTE ON  [dbo].[d_flarock_acctxface_det] TO [public]
GO
