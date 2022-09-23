CREATE TABLE [dbo].[ChargeTypeBasisUnitRuleArgs]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[ChargeTypeBasisUnitRuleInputSource_Id] [int] NOT NULL,
[SeqNo] [int] NOT NULL CONSTRAINT [DF__ChargeTyp__SeqNo__39F63A2F] DEFAULT ((0)),
[TariffInputSourceArgs_Id] [int] NOT NULL,
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__ChargeTyp__LastU__3AEA5E68] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__ChargeTyp__LastU__3BDE82A1] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChargeTypeBasisUnitRuleArgs] ADD CONSTRAINT [pk_ChargeTypeBasisUnitRuleArgs] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ChargeTypeBasisUnitRuleArgs_ChargeTypeBasisUnitRuleInputSource_Id] ON [dbo].[ChargeTypeBasisUnitRuleArgs] ([ChargeTypeBasisUnitRuleInputSource_Id]) INCLUDE ([SeqNo], [TariffInputSourceArgs_Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChargeTypeBasisUnitRuleArgs] ADD CONSTRAINT [fk_ChargeTypeBasisUnitRuleArgs_ChargeTypeBasisUnitRuleInputSource_Id] FOREIGN KEY ([ChargeTypeBasisUnitRuleInputSource_Id]) REFERENCES [dbo].[ChargeTypeBasisUnitRuleInputSource] ([Id])
GO
ALTER TABLE [dbo].[ChargeTypeBasisUnitRuleArgs] ADD CONSTRAINT [fk_ChargeTypeBasisUnitRuleArgs_TariffInputSourceArgs_Id] FOREIGN KEY ([TariffInputSourceArgs_Id]) REFERENCES [dbo].[TariffInputSourceArgs] ([Id])
GO
GRANT DELETE ON  [dbo].[ChargeTypeBasisUnitRuleArgs] TO [public]
GO
GRANT INSERT ON  [dbo].[ChargeTypeBasisUnitRuleArgs] TO [public]
GO
GRANT SELECT ON  [dbo].[ChargeTypeBasisUnitRuleArgs] TO [public]
GO
GRANT UPDATE ON  [dbo].[ChargeTypeBasisUnitRuleArgs] TO [public]
GO
