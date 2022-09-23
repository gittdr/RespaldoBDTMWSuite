SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWAllocReconcileLinehaulBillView]
AS

SELECT DISTINCT [orderheader].[ord_hdrnumber], [legheader].[lgh_number], [stops].[mov_number], [orderheader].[ord_ratemode] AS 'RateMode'
FROM [stops] (NOLOCK)
INNER JOIN [orderheader] (NOLOCK) ON [stops].[ord_hdrnumber] = [orderheader].[ord_hdrnumber]
INNER JOIN [legheader] (NOLOCK) ON [stops].[lgh_number] = [legheader].[lgh_number]
INNER JOIN [assetassignment] (NOLOCK) ON [legheader].[lgh_number] = [assetassignment].[lgh_number]
LEFT JOIN [invoiceheader] (NOLOCK) ON [orderheader].[ord_hdrnumber] = [invoiceheader].[ord_hdrnumber]
INNER JOIN [CompanyContractMgmt] (NOLOCK) ON [orderheader].[ord_billto] = [CompanyContractMgmt].[cmp_id]
WHERE [assetassignment].[asgn_status] = 'CMP'
    AND [orderheader].[ord_invoicestatus] = 'AVL'
    AND [invoiceheader].[ivh_hdrnumber] IS NULL
    AND [CompanyContractMgmt].[TPLBillingEligible] = 1
    AND [orderheader].[ord_ratemode] = '3PLINV'
UNION
SELECT DISTINCT [orderheader].[ord_hdrnumber], [legheader].[lgh_number], [stops].[mov_number], [legheader].[lgh_ratemode] AS 'RateMode'
FROM [stops] (NOLOCK)
LEFT JOIN [orderheader] (NOLOCK) ON [stops].[ord_hdrnumber] = [orderheader].[ord_hdrnumber]
INNER JOIN [legheader] (NOLOCK) ON [stops].[lgh_number] = [legheader].[lgh_number]
INNER JOIN [assetassignment] (NOLOCK) ON [legheader].[lgh_number] = [assetassignment].[lgh_number]
LEFT JOIN [invoiceheader] (NOLOCK) ON [orderheader].[ord_hdrnumber] = [invoiceheader].[ord_hdrnumber]
INNER JOIN [CompanyContractMgmt] (NOLOCK) ON [orderheader].[ord_billto] = [CompanyContractMgmt].[cmp_id]
WHERE [assetassignment].[asgn_status] = 'CMP'
    AND [orderheader].[ord_invoicestatus] = 'AVL'
    AND [invoiceheader].[ivh_hdrnumber] IS NULL
    AND [CompanyContractMgmt].[TPLBillingEligible] = 1
    AND [legheader].[lgh_ratemode] = '3PLINV'
UNION
SELECT DISTINCT [orderheader].[ord_hdrnumber], [legheader].[lgh_number], [stops].[mov_number], [orderheader].[ord_ratemode] AS 'RateMode'
FROM [stops] (NOLOCK)
INNER JOIN [orderheader] (NOLOCK) ON [stops].[ord_hdrnumber] = [orderheader].[ord_hdrnumber]
INNER JOIN [legheader] (NOLOCK) ON [stops].[lgh_number] = [legheader].[lgh_number]
INNER JOIN [assetassignment] (NOLOCK) ON [legheader].[lgh_number] = [assetassignment].[lgh_number]
LEFT JOIN [invoiceheader] (NOLOCK) ON [orderheader].[ord_hdrnumber] = [invoiceheader].[ord_hdrnumber]
INNER JOIN [CompanyContractMgmt] (NOLOCK) ON [orderheader].[ord_billto] = [CompanyContractMgmt].[cmp_id]
WHERE [assetassignment].[asgn_status] = 'CMP'
    AND [orderheader].[ord_invoicestatus] = 'AVL'
    AND [invoiceheader].[ivh_hdrnumber] IS NULL
    AND [CompanyContractMgmt].[AllocationEligible] = 1
    AND [orderheader].[ord_ratemode] = 'ALLOC'
UNION
SELECT DISTINCT [orderheader].[ord_hdrnumber], [legheader].[lgh_number], [stops].[mov_number], [legheader].[lgh_ratemode] AS 'RateMode'
FROM [stops] (NOLOCK)
LEFT JOIN [orderheader] (NOLOCK) ON [stops].[ord_hdrnumber] = [orderheader].[ord_hdrnumber]
INNER JOIN [legheader] (NOLOCK) ON [stops].[lgh_number] = [legheader].[lgh_number]
INNER JOIN [assetassignment] (NOLOCK) ON [legheader].[lgh_number] = [assetassignment].[lgh_number]
LEFT JOIN [invoiceheader] (NOLOCK) ON [orderheader].[ord_hdrnumber] = [invoiceheader].[ord_hdrnumber]
INNER JOIN [CompanyContractMgmt] (NOLOCK) ON [orderheader].[ord_billto] = [CompanyContractMgmt].[cmp_id]
WHERE [assetassignment].[asgn_status] = 'CMP'
    AND [orderheader].[ord_invoicestatus] = 'AVL'
    AND [invoiceheader].[ivh_hdrnumber] IS NULL
    AND [CompanyContractMgmt].[AllocationEligible] = 1
    AND [legheader].[lgh_ratemode] = 'ALLOC'
GO
GRANT DELETE ON  [dbo].[TMWAllocReconcileLinehaulBillView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWAllocReconcileLinehaulBillView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWAllocReconcileLinehaulBillView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWAllocReconcileLinehaulBillView] TO [public]
GO
