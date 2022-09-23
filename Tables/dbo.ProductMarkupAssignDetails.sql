CREATE TABLE [dbo].[ProductMarkupAssignDetails]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ProductMarkupAssignID] [int] NOT NULL,
[MarkupType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CommodityCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductMarkupAssignDetails_CommodityCode] DEFAULT ('UNKNOWN'),
[CommodityClass1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductMarkupAssignDetails_CommodityClass1] DEFAULT ('UNKNOWN'),
[CommodityClass2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductMarkupAssignDetails_CommodityClass2] DEFAULT ('UNKNOWN'),
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductMarkupAssignDetails_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductMarkupAssignDetails_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductMarkupAssignDetails] ADD CONSTRAINT [PK_ProductMarkupAssignDetails] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductMarkupAssignDetails] ADD CONSTRAINT [IX_ProductMarkupAssignDetails] UNIQUE NONCLUSTERED ([ProductMarkupAssignID], [CommodityCode], [CommodityClass1], [CommodityClass2], [MarkupType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductMarkupAssignDetails] ADD CONSTRAINT [FK_ProductMarkupAssignDetails_ProductMarkupAssign] FOREIGN KEY ([ProductMarkupAssignID]) REFERENCES [dbo].[ProductMarkupAssign] ([ID])
GO
ALTER TABLE [dbo].[ProductMarkupAssignDetails] ADD CONSTRAINT [FK_ProductMarkupAssignDetails_ProductMarkupProfile] FOREIGN KEY ([MarkupType]) REFERENCES [dbo].[ProductMarkupProfile] ([MarkupType])
GO
GRANT DELETE ON  [dbo].[ProductMarkupAssignDetails] TO [public]
GO
GRANT INSERT ON  [dbo].[ProductMarkupAssignDetails] TO [public]
GO
GRANT SELECT ON  [dbo].[ProductMarkupAssignDetails] TO [public]
GO
GRANT UPDATE ON  [dbo].[ProductMarkupAssignDetails] TO [public]
GO
