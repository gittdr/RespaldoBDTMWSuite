CREATE TABLE [dbo].[RatingRuleCostAllocationAsgn]
(
[RatingRuleActionID] [int] NOT NULL,
[CostAllocationID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingRuleCostAllocationAsgn] ADD CONSTRAINT [UX_RatingRuleCostAllocationAsgn] UNIQUE NONCLUSTERED ([RatingRuleActionID], [CostAllocationID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingRuleCostAllocationAsgn] ADD CONSTRAINT [FK_RatingRuleCostAllocationAsgn_CostAllocationFormula] FOREIGN KEY ([CostAllocationID]) REFERENCES [dbo].[CostAllocationFormula] ([ID])
GO
ALTER TABLE [dbo].[RatingRuleCostAllocationAsgn] ADD CONSTRAINT [FK_RatingRuleCostAllocationAsgn_RatingCostRuleAction] FOREIGN KEY ([RatingRuleActionID]) REFERENCES [dbo].[RatingRuleAction] ([ID])
GO
GRANT DELETE ON  [dbo].[RatingRuleCostAllocationAsgn] TO [public]
GO
GRANT INSERT ON  [dbo].[RatingRuleCostAllocationAsgn] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RatingRuleCostAllocationAsgn] TO [public]
GO
GRANT SELECT ON  [dbo].[RatingRuleCostAllocationAsgn] TO [public]
GO
GRANT UPDATE ON  [dbo].[RatingRuleCostAllocationAsgn] TO [public]
GO
