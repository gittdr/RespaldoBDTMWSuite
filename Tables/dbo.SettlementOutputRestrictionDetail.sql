CREATE TABLE [dbo].[SettlementOutputRestrictionDetail]
(
[SettlementOutputRestrictionDetailId] [int] NOT NULL IDENTITY(1, 1),
[LabelDefinition] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Settlemen__Creat__02A60545] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__Settlemen__Creat__039A297E] DEFAULT (getdate()),
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__Settlemen__LastU__048E4DB7] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Settlemen__LastU__058271F0] DEFAULT (suser_name()),
[SettlementOutputRestrictionId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SettlementOutputRestrictionDetail] ADD CONSTRAINT [PK_dbo.SettlementOutputRestrictionDetail] PRIMARY KEY CLUSTERED ([SettlementOutputRestrictionDetailId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SettlementOutputRestrictionId] ON [dbo].[SettlementOutputRestrictionDetail] ([SettlementOutputRestrictionId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SettlementOutputRestrictionDetail] ADD CONSTRAINT [FK_dbo.SettlementOutputRestrictionDetail_dbo.SettlementOutputRestriction_SettlementOutputRestrictionId] FOREIGN KEY ([SettlementOutputRestrictionId]) REFERENCES [dbo].[SettlementOutputRestriction] ([SettlementOutputRestrictionId])
GO
GRANT DELETE ON  [dbo].[SettlementOutputRestrictionDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[SettlementOutputRestrictionDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[SettlementOutputRestrictionDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[SettlementOutputRestrictionDetail] TO [public]
GO
