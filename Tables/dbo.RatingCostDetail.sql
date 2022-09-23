CREATE TABLE [dbo].[RatingCostDetail]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[CostHeaderID] [int] NOT NULL,
[tar_number] [int] NOT NULL,
[ItemCode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Quantity] [float] NOT NULL,
[Rate] [money] NOT NULL,
[RateFactor] [float] NOT NULL,
[Amount] [money] NOT NULL,
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime2] NOT NULL,
[InvoiceDetailId] [int] NULL,
[PayDetailId] [int] NULL,
[MarkedForBenchmark] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingCostDetail] ADD CONSTRAINT [PK_RatingCostDetail] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_RatingCostDetail_CostHeaderID] ON [dbo].[RatingCostDetail] ([CostHeaderID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingCostDetail] ADD CONSTRAINT [FK_RatingCostDetail_RatingCostHeader] FOREIGN KEY ([CostHeaderID]) REFERENCES [dbo].[RatingCostHeader] ([ID])
GO
GRANT DELETE ON  [dbo].[RatingCostDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[RatingCostDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RatingCostDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[RatingCostDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[RatingCostDetail] TO [public]
GO
