CREATE TABLE [dbo].[RatingRuleAction]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[RatingCostRuleId] [int] NOT NULL,
[RatingPhase] [int] NOT NULL,
[RatingAction] [int] NOT NULL,
[ResultIsBenchmark] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingRuleAction] ADD CONSTRAINT [PK_RatingRuleAction] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingRuleAction] ADD CONSTRAINT [UX_RatingRuleAction] UNIQUE NONCLUSTERED ([RatingCostRuleId], [RatingPhase]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingRuleAction] ADD CONSTRAINT [FK_RatingRuleAction_RatingCostRule] FOREIGN KEY ([RatingCostRuleId]) REFERENCES [dbo].[RatingCostRule] ([ID])
GO
GRANT DELETE ON  [dbo].[RatingRuleAction] TO [public]
GO
GRANT INSERT ON  [dbo].[RatingRuleAction] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RatingRuleAction] TO [public]
GO
GRANT SELECT ON  [dbo].[RatingRuleAction] TO [public]
GO
GRANT UPDATE ON  [dbo].[RatingRuleAction] TO [public]
GO
