CREATE TABLE [dbo].[ProductMarketAssign]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ProductMarketID] [int] NOT NULL,
[AssignType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductMarketAssign_Value1] DEFAULT ('UNKNOWN'),
[Value2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductMarketAssign_Value2] DEFAULT ('UNKNOWN'),
[Value3] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductMarketAssign_Value3] DEFAULT ('UNKNOWN'),
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductMarketAssign_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductMarketAssign_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductMarketAssign] ADD CONSTRAINT [PK_ProductMarketAssign] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductMarketAssign] ADD CONSTRAINT [IX_ProductMarketAssign] UNIQUE NONCLUSTERED ([ProductMarketID], [AssignType], [Value1], [Value2], [Value3]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ProductMarketAssign] TO [public]
GO
GRANT INSERT ON  [dbo].[ProductMarketAssign] TO [public]
GO
GRANT SELECT ON  [dbo].[ProductMarketAssign] TO [public]
GO
GRANT UPDATE ON  [dbo].[ProductMarketAssign] TO [public]
GO
