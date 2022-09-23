CREATE TABLE [dbo].[SettlementCollectConfigType]
(
[ConfigTypeId] [tinyint] NOT NULL IDENTITY(1, 1),
[ConfigType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SettlementCollectConfigType] ADD CONSTRAINT [PK_SettlementCollectConfigType] PRIMARY KEY CLUSTERED ([ConfigTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SettlementCollectConfigType] TO [public]
GO
GRANT INSERT ON  [dbo].[SettlementCollectConfigType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SettlementCollectConfigType] TO [public]
GO
GRANT SELECT ON  [dbo].[SettlementCollectConfigType] TO [public]
GO
GRANT UPDATE ON  [dbo].[SettlementCollectConfigType] TO [public]
GO
