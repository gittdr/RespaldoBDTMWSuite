SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE	VIEW [dbo].[PaperworkRequirementsView] AS
SELECT	L.lgh_number AS LegNumber, oh.ord_hdrnumber AS OrderNumber, pw.abbr AS DocType, lf.name AS DocTypeName,CASE WHEN pw.pw_received = 'Y' THEN 'Yes' ELSE 'No' END AS Received
FROM	orderheader oh
		INNER JOIN paperwork pw ON oh.ord_hdrnumber = pw.ord_hdrnumber
		INNER JOIN paperwork_by_assettypes pba ON pw.abbr = pba.pat_doctype
		INNER JOIN labelfile lf ON pba.pat_doctype = lf.abbr
		INNER JOIN legheader L ON oh.ord_hdrnumber = L.ord_hdrnumber
WHERE	pba.asgn_type = 'CAR' AND lf.labeldefinition = 'paperwork'
		and (pba.asset_type1 <> 'UNK' or pba.asset_type2 <> 'UNK' or pba.asset_type3 <> 'UNK' or pba.asset_type4 <> 'UNK')
UNION All
SELECT	L.lgh_number AS LegNumber, oh.ord_hdrnumber AS OrderNumbeer, pw.abbr AS DocType, lf.name AS DocTypeName,CASE WHEN pw.pw_received = 'Y' THEN 'Yes' ELSE 'No' END AS Received
FROM	orderheader oh
		INNER JOIN paperwork pw ON oh.ord_hdrnumber = pw.ord_hdrnumber
		INNER JOIN BillDoctypes bdt ON bdt.cmp_id = oh.ord_billto
		INNER JOIN labelfile lf ON lf.abbr = bdt.bdt_doctype
		INNER JOIN legheader L ON oh.ord_hdrnumber = L.ord_hdrnumber
WHERE	lf.labeldefinition = 'paperwork' AND pw.abbr = bdt.bdt_doctype AND bdt.bdt_inv_required = 'Y'


GO
