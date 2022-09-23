SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWOrdersCostDetailGenOnDemandView]
AS

SELECT DISTINCT [orderheader].[ord_hdrnumber], [legheader].[lgh_number], [stops].[mov_number]
FROM [stops] (NOLOCK)
INNER JOIN [orderheader] (NOLOCK) ON [stops].[ord_hdrnumber] = [orderheader].[ord_hdrnumber]
INNER JOIN [legheader] (NOLOCK) ON [stops].[lgh_number] = [legheader].[lgh_number]
LEFT JOIN [paydetail] (NOLOCK) ON [legheader].[lgh_number] = [paydetail].[lgh_number]
LEFT JOIN [payheader] (NOLOCK) ON [paydetail].[pyh_number] = [payheader].[pyh_pyhnumber]
LEFT JOIN [invoiceheader] (NOLOCK) ON [invoiceheader].[ord_hdrnumber] = [orderheader].[ord_hdrnumber]
INNER JOIN [CompanyContractMgmt] (NOLOCK) ON [orderheader].[ord_billto] = [CompanyContractMgmt].[cmp_id]
LEFT JOIN [RatingCostHeader_Order] (NOLOCK) ON [RatingCostHeader_Order].[ord_hdrnumber] = [orderheader].[ord_hdrnumber]
LEFT JOIN [RatingCostHeader_Leg] (NOLOCK) ON [RatingCostHeader_Leg].[lgh_number] = [legheader].[lgh_number]
WHERE [payheader].[pyh_pyhnumber] IS NULL
    AND [CompanyContractMgmt].[TPLBillingEligible] = 1
    AND [orderheader].[ord_invoicestatus] IN ('AVL', 'PND', '3PLHLD', 'PPD')
    AND [orderheader].[ord_ratemode] = '3PLINV'
    AND [orderheader].[ord_status] <> 'CAN'
    AND ISNULL([invoiceheader].[ivh_invoicestatus], 'HLA') = 'HLA'
UNION
SELECT DISTINCT [orderheader].[ord_hdrnumber], [legheader].[lgh_number], [stops].[mov_number]
FROM [stops] (NOLOCK)
LEFT JOIN [orderheader] (NOLOCK) ON ([stops].[ord_hdrnumber]) = [orderheader].[ord_hdrnumber]
INNER JOIN [legheader] (NOLOCK) ON [stops].[lgh_number] = ([legheader].[lgh_number])
LEFT JOIN [paydetail] (NOLOCK) ON ([legheader].[lgh_number]) = [paydetail].[lgh_number]
LEFT JOIN [payheader] (NOLOCK) ON [paydetail].[pyh_number] = [payheader].[pyh_pyhnumber]
LEFT JOIN [invoiceheader] (NOLOCK) ON [invoiceheader].[ord_hdrnumber] = [orderheader].[ord_hdrnumber]
INNER JOIN [CompanyContractMgmt] (NOLOCK) ON [orderheader].[ord_billto] = [CompanyContractMgmt].[cmp_id]
LEFT JOIN [RatingCostHeader_Order] (NOLOCK) ON [RatingCostHeader_Order].[ord_hdrnumber] = [orderheader].[ord_hdrnumber]
LEFT JOIN [RatingCostHeader_Leg] (NOLOCK) ON [RatingCostHeader_Leg].[lgh_number] = [legheader].[lgh_number]
WHERE [payheader].[pyh_pyhnumber] IS NULL
    AND [CompanyContractMgmt].[TPLBillingEligible] = 1
    AND ISNULL([orderheader].[ord_invoicestatus], 'PND') IN ('AVL', 'PND', '3PLHLD', 'PPD')
    AND [legheader].[lgh_ratemode] = '3PLINV'
    AND [orderheader].[ord_status] <> 'CAN'
    AND ISNULL([invoiceheader].[ivh_invoicestatus], 'HLA') = 'HLA'
UNION
SELECT DISTINCT [orderheader].[ord_hdrnumber], [legheader].[lgh_number], [stops].[mov_number]
FROM [stops] (NOLOCK)
INNER JOIN [orderheader] (NOLOCK) ON [stops].[ord_hdrnumber] = [orderheader].[ord_hdrnumber]
INNER JOIN [legheader] (NOLOCK) ON [stops].[lgh_number] = [legheader].[lgh_number]
LEFT JOIN [paydetail] (NOLOCK) ON ([legheader].[lgh_number]) = [paydetail].[lgh_number]
LEFT JOIN [payheader] (NOLOCK) ON [paydetail].[pyh_number] = [payheader].[pyh_pyhnumber]
LEFT JOIN [invoiceheader] (NOLOCK) ON [invoiceheader].[ord_hdrnumber] = [orderheader].[ord_hdrnumber]
INNER JOIN [CompanyContractMgmt] (NOLOCK) ON [orderheader].[ord_billto] = [CompanyContractMgmt].[cmp_id]
LEFT JOIN [RatingCostHeader_Order] (NOLOCK) ON [RatingCostHeader_Order].[ord_hdrnumber] = [orderheader].[ord_hdrnumber]
LEFT JOIN [RatingCostHeader_Leg] (NOLOCK) ON [RatingCostHeader_Leg].[lgh_number] = [legheader].[lgh_number]
WHERE [CompanyContractMgmt].[AllocationEligible] = 1
    AND [orderheader].[ord_invoicestatus] IN ('AVL', 'PND', '3PLHLD', 'PPD')
    AND [orderheader].[ord_ratemode] = 'ALLOC'
    AND [orderheader].[ord_status] <> 'CAN'
    AND (ISNULL([invoiceheader].[ivh_invoicestatus], 'HLA') = 'HLA' OR ISNULL([payheader].[pyh_paystatus], 'PND') NOT IN ('REL', 'PRN', 'XFR'))
UNION
SELECT DISTINCT [orderheader].[ord_hdrnumber], [legheader].[lgh_number], [stops].[mov_number]
FROM [stops] (NOLOCK)
LEFT JOIN [orderheader] (NOLOCK) ON ([stops].[ord_hdrnumber]) = [orderheader].[ord_hdrnumber]
INNER JOIN [legheader] (NOLOCK) ON [stops].[lgh_number] = ([legheader].[lgh_number])
LEFT JOIN [paydetail] (NOLOCK) ON ([legheader].[lgh_number]) = [paydetail].[lgh_number]
LEFT JOIN [payheader] (NOLOCK) ON [paydetail].[pyh_number] = [payheader].[pyh_pyhnumber]
LEFT JOIN [invoiceheader] (NOLOCK) ON [invoiceheader].[ord_hdrnumber] = [orderheader].[ord_hdrnumber]
INNER JOIN [CompanyContractMgmt] (NOLOCK) ON [orderheader].[ord_billto] = [CompanyContractMgmt].[cmp_id]
LEFT JOIN [RatingCostHeader_Order] (NOLOCK) ON [RatingCostHeader_Order].[ord_hdrnumber] = [orderheader].[ord_hdrnumber]
LEFT JOIN [RatingCostHeader_Leg] (NOLOCK) ON [RatingCostHeader_Leg].[lgh_number] = [legheader].[lgh_number]
WHERE [CompanyContractMgmt].[TPLBillingEligible] = 0
    AND [CompanyContractMgmt].[AllocationEligible] = 1
    AND ISNULL([orderheader].[ord_invoicestatus], 'PND') IN ('AVL', 'PND', '3PLHLD', 'PPD')
    AND [legheader].[lgh_ratemode] = 'ALLOC'
    AND [orderheader].[ord_status] <> 'CAN'
    AND (ISNULL([invoiceheader].[ivh_invoicestatus], 'HLA') = 'HLA' OR ISNULL([payheader].[pyh_paystatus], 'PND') NOT IN ('REL', 'PRN', 'XFR'))
GO
GRANT DELETE ON  [dbo].[TMWOrdersCostDetailGenOnDemandView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWOrdersCostDetailGenOnDemandView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWOrdersCostDetailGenOnDemandView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWOrdersCostDetailGenOnDemandView] TO [public]
GO
