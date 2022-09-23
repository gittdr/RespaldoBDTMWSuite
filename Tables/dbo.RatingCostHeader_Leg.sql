CREATE TABLE [dbo].[RatingCostHeader_Leg]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[CostHeaderID] [int] NOT NULL,
[lgh_number] [int] NOT NULL,
[HeaderType] [int] NOT NULL,
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime2] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingCostHeader_Leg] ADD CONSTRAINT [PK_RatingCostHeaderLeg] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_RatingCostHeader_Leg_CostHeaderID] ON [dbo].[RatingCostHeader_Leg] ([CostHeaderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_RatingCostHeader_Leg_lgh_number] ON [dbo].[RatingCostHeader_Leg] ([lgh_number]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingCostHeader_Leg] ADD CONSTRAINT [FK_RatingCostHeaderLeg_RatingCostHeader] FOREIGN KEY ([CostHeaderID]) REFERENCES [dbo].[RatingCostHeader] ([ID])
GO
GRANT DELETE ON  [dbo].[RatingCostHeader_Leg] TO [public]
GO
GRANT INSERT ON  [dbo].[RatingCostHeader_Leg] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RatingCostHeader_Leg] TO [public]
GO
GRANT SELECT ON  [dbo].[RatingCostHeader_Leg] TO [public]
GO
GRANT UPDATE ON  [dbo].[RatingCostHeader_Leg] TO [public]
GO
