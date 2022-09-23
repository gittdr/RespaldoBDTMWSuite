CREATE TABLE [dbo].[RatingCostDetail_RatingRule]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[CostDetailID] [int] NOT NULL,
[RatingRuleID] [int] NOT NULL,
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime2] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingCostDetail_RatingRule] ADD CONSTRAINT [PK_RatingCostDetailRatingRule] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingCostDetail_RatingRule] ADD CONSTRAINT [FK_RatingCostDetailRatingRule_RatingCostDetail] FOREIGN KEY ([CostDetailID]) REFERENCES [dbo].[RatingCostDetail] ([ID])
GO
ALTER TABLE [dbo].[RatingCostDetail_RatingRule] ADD CONSTRAINT [FK_RatingCostDetailRatingRule_RatingCostRule] FOREIGN KEY ([RatingRuleID]) REFERENCES [dbo].[RatingCostRule] ([ID])
GO
GRANT DELETE ON  [dbo].[RatingCostDetail_RatingRule] TO [public]
GO
GRANT INSERT ON  [dbo].[RatingCostDetail_RatingRule] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RatingCostDetail_RatingRule] TO [public]
GO
GRANT SELECT ON  [dbo].[RatingCostDetail_RatingRule] TO [public]
GO
GRANT UPDATE ON  [dbo].[RatingCostDetail_RatingRule] TO [public]
GO
