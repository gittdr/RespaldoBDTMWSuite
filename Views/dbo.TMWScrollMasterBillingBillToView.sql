SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  View [dbo].[TMWScrollMasterBillingBillToView]    Script Date: 1/27/2014 3:32:40 PM ******/
CREATE VIEW [dbo].[TMWScrollMasterBillingBillToView] AS
SELECT cmp.*
		,cty.[cty_latitude]
		,cty.[cty_longitude]
FROM dbo.Company cmp (NOLOCK) 
LEFT OUTER JOIN dbo.City cty (NOLOCK) ON cmp.[cmp_city] = cty.[cty_code]
WHERE		cmp.[cmp_billto] = 'Y' 
		AND cmp.[cmp_invoicetype] in ('BTH', 'MAS') 
		AND ISNULL(cmp.[cmp_active], 'Y') = 'Y'
GO
GRANT DELETE ON  [dbo].[TMWScrollMasterBillingBillToView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollMasterBillingBillToView] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMWScrollMasterBillingBillToView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollMasterBillingBillToView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollMasterBillingBillToView] TO [public]
GO
