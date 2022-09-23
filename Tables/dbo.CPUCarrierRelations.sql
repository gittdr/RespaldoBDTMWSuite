CREATE TABLE [dbo].[CPUCarrierRelations]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[RatingCostDetailID] [int] NOT NULL,
[CPUCarrierID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CPUCarrierRelations] ADD CONSTRAINT [PK_CPUCarrierRelations] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CPUCarrierRelations] ADD CONSTRAINT [FK_CPUCarrierRelations_RatingCostDetail] FOREIGN KEY ([RatingCostDetailID]) REFERENCES [dbo].[RatingCostDetail] ([ID])
GO
GRANT DELETE ON  [dbo].[CPUCarrierRelations] TO [public]
GO
GRANT INSERT ON  [dbo].[CPUCarrierRelations] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CPUCarrierRelations] TO [public]
GO
GRANT SELECT ON  [dbo].[CPUCarrierRelations] TO [public]
GO
GRANT UPDATE ON  [dbo].[CPUCarrierRelations] TO [public]
GO
