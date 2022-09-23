SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWCreatePayFromCostsView]
AS
SELECT DISTINCT 0 AS [ord_hdrnumber], [RatingCostHeader_Leg].[lgh_number], 0 AS [mov_number]
FROM [RatingCostDetail] (NOLOCK)
INNER JOIN [RatingCostHeader] (NOLOCK) ON [RatingCostDetail].[CostHeaderID] = [RatingCostHeader].[ID]
INNER JOIN [RatingCostHeader_Leg] (NOLOCK) ON [RatingCostHeader_Leg].[CostHeaderID] = [RatingCostHeader].[ID]
WHERE [RatingCostDetail].[PayDetailId] IS NULL
    AND [RatingCostHeader].[RatingSource] = 2
    AND [RatingCostHeader_Leg].[HeaderType] = 1
UNION
SELECT DISTINCT [RatingCostHeader_OrderOnLeg].[ord_hdrnumber], [RatingCostHeader_OrderOnLeg].[lgh_number], 0 AS [mov_number]
FROM [RatingCostDetail] (NOLOCK)
INNER JOIN [RatingCostHeader] (NOLOCK) ON [RatingCostDetail].[CostHeaderID] = [RatingCostHeader].[ID]
INNER JOIN [RatingCostHeader_OrderOnLeg] (NOLOCK) ON [RatingCostHeader_OrderOnLeg].[CostHeaderID] = [RatingCostHeader].[ID]
WHERE [RatingCostDetail].[PayDetailId] IS NULL
    AND [RatingCostHeader].[RatingSource] = 2
    AND [RatingCostHeader_OrderOnLeg].[HeaderType] = 1
GO
GRANT DELETE ON  [dbo].[TMWCreatePayFromCostsView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWCreatePayFromCostsView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWCreatePayFromCostsView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWCreatePayFromCostsView] TO [public]
GO
