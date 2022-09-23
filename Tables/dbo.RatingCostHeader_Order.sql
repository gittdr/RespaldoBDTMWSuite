CREATE TABLE [dbo].[RatingCostHeader_Order]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[CostHeaderID] [int] NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[HeaderType] [int] NOT NULL,
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime2] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingCostHeader_Order] ADD CONSTRAINT [PK_RatingCostHeaderOrder] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_RatingCostHeader_Order_CostHeaderID] ON [dbo].[RatingCostHeader_Order] ([CostHeaderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_RatingCostHeader_Order_ord_hdrnumber] ON [dbo].[RatingCostHeader_Order] ([ord_hdrnumber]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RatingCostHeader_Order] ADD CONSTRAINT [FK_RatingCostHeaderOrder_RatingCostHeader] FOREIGN KEY ([CostHeaderID]) REFERENCES [dbo].[RatingCostHeader] ([ID])
GO
GRANT DELETE ON  [dbo].[RatingCostHeader_Order] TO [public]
GO
GRANT INSERT ON  [dbo].[RatingCostHeader_Order] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RatingCostHeader_Order] TO [public]
GO
GRANT SELECT ON  [dbo].[RatingCostHeader_Order] TO [public]
GO
GRANT UPDATE ON  [dbo].[RatingCostHeader_Order] TO [public]
GO
