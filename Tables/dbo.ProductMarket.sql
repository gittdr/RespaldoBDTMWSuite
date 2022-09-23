CREATE TABLE [dbo].[ProductMarket]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductMarket_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductMarket_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductMarket] ADD CONSTRAINT [PK_ProductMarket] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ProductMarket] TO [public]
GO
GRANT INSERT ON  [dbo].[ProductMarket] TO [public]
GO
GRANT SELECT ON  [dbo].[ProductMarket] TO [public]
GO
GRANT UPDATE ON  [dbo].[ProductMarket] TO [public]
GO
