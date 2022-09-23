CREATE TABLE [dbo].[SettlementCollectConfig]
(
[SettlementCollectConfigId] [int] NOT NULL IDENTITY(1, 1),
[SequenceNumber] [int] NOT NULL,
[ConfigTypeId] [tinyint] NOT NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__Settlemen__Creat__60990364] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Settlemen__Creat__618D279D] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SettlementCollectConfig] ADD CONSTRAINT [PK_SettlementCollectConfig] PRIMARY KEY CLUSTERED ([SettlementCollectConfigId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SettlementCollectConfig] ADD CONSTRAINT [FK_SettlementCollectConfig_SettlementCollectConfigType] FOREIGN KEY ([ConfigTypeId]) REFERENCES [dbo].[SettlementCollectConfigType] ([ConfigTypeId])
GO
GRANT DELETE ON  [dbo].[SettlementCollectConfig] TO [public]
GO
GRANT INSERT ON  [dbo].[SettlementCollectConfig] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SettlementCollectConfig] TO [public]
GO
GRANT SELECT ON  [dbo].[SettlementCollectConfig] TO [public]
GO
GRANT UPDATE ON  [dbo].[SettlementCollectConfig] TO [public]
GO
