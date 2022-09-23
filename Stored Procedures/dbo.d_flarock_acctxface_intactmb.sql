SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_flarock_acctxface_intactmb]
@mb_number int
AS
/**
 * 
 * REVISION HISTORY:
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @vchar12 varchar(12), @money money


SELECT @money = 0.00 
SELECT @vchar12 = '            '
 
CREATE TABLE #invview_interact
	(ivh_cmp_altid varchar(8) NULL,
	ivh_mbnumber int NULL,
 	ivh_totalcharge money NULL,
	ivh_billdate DATETIME NULL,
	ivh_revtype1 int NULL,
	ship_ticket VARCHAR(12) NULL)

INSERT INTO #invview_interact
SELECT 	MIN(IsNull(company.cmp_altid, '')),
	MIN(IsNull(invoiceheader.ivh_mbnumber, -1)),
 	SUM(invoiceheader.ivh_totalcharge),
 	MIN(invoiceheader.ivh_billdate),
 	MIN(IsNULL(labelfile.code, 0)), 
	@vchar12 'ship_ticket'
FROM  invoiceheader  LEFT OUTER JOIN  labelfile  ON  (invoiceheader.ivh_revtype1  = labelfile.abbr and labelfile.labeldefinition  = 'RevType1'),
	 company 
WHERE	invoiceheader.ivh_billto  = company.cmp_id
 AND	invoiceheader.ivh_mbnumber  = @mb_number

SELECT * from #invview_interact
GO
GRANT EXECUTE ON  [dbo].[d_flarock_acctxface_intactmb] TO [public]
GO
