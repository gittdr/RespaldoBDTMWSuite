CREATE TABLE [dbo].[SettlementOvertimeConfig]
(
[SettlementCollectConfigId] [int] NOT NULL,
[NumberOfDays] [decimal] (9, 4) NOT NULL,
[Threshold] [decimal] (9, 4) NOT NULL,
[BackoutTypeId] [tinyint] NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__Settlemen__Creat__674600F3] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Settlemen__Creat__683A252C] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SettlementOvertimeConfig] ADD CONSTRAINT [PK_SettlementOvertimeConfig] PRIMARY KEY CLUSTERED ([SettlementCollectConfigId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SettlementOvertimeConfig] ADD CONSTRAINT [FK_SettlementOvertimeConfig_SettlementCollectConfig] FOREIGN KEY ([SettlementCollectConfigId]) REFERENCES [dbo].[SettlementCollectConfig] ([SettlementCollectConfigId])
GO
ALTER TABLE [dbo].[SettlementOvertimeConfig] ADD CONSTRAINT [FK_SettlementOvertimeConfig_SettlementOvertimeBackoutType] FOREIGN KEY ([BackoutTypeId]) REFERENCES [dbo].[SettlementOvertimeBackoutType] ([BackoutTypeId])
GO
GRANT DELETE ON  [dbo].[SettlementOvertimeConfig] TO [public]
GO
GRANT INSERT ON  [dbo].[SettlementOvertimeConfig] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SettlementOvertimeConfig] TO [public]
GO
GRANT SELECT ON  [dbo].[SettlementOvertimeConfig] TO [public]
GO
GRANT UPDATE ON  [dbo].[SettlementOvertimeConfig] TO [public]
GO
