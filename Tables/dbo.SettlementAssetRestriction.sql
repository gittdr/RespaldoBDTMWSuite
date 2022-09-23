CREATE TABLE [dbo].[SettlementAssetRestriction]
(
[SettlementAssetRestrictionId] [int] NOT NULL IDENTITY(1, 1),
[AssetType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AssetId] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Settlemen__Creat__085EDE9B] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__Settlemen__Creat__095302D4] DEFAULT (getdate()),
[LastUpdatedDate] [datetime] NOT NULL CONSTRAINT [DF__Settlemen__LastU__0A47270D] DEFAULT (getdate()),
[LastUpdatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Settlemen__LastU__0B3B4B46] DEFAULT (suser_name()),
[SettlementOutputRestrictionId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SettlementAssetRestriction] ADD CONSTRAINT [PK_dbo.SettlementAssetRestriction] PRIMARY KEY CLUSTERED ([SettlementAssetRestrictionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SettlementAssetRestrictionId] ON [dbo].[SettlementAssetRestriction] ([SettlementAssetRestrictionId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SettlementAssetRestriction] ADD CONSTRAINT [FK_dbo.SettlementAssetRestriction_dbo.SettlementOutputRestriction_SettlementOutputRestrictionId] FOREIGN KEY ([SettlementOutputRestrictionId]) REFERENCES [dbo].[SettlementOutputRestriction] ([SettlementOutputRestrictionId])
GO
GRANT DELETE ON  [dbo].[SettlementAssetRestriction] TO [public]
GO
GRANT INSERT ON  [dbo].[SettlementAssetRestriction] TO [public]
GO
GRANT SELECT ON  [dbo].[SettlementAssetRestriction] TO [public]
GO
GRANT UPDATE ON  [dbo].[SettlementAssetRestriction] TO [public]
GO
