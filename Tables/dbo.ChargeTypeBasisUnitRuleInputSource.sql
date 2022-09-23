CREATE TABLE [dbo].[ChargeTypeBasisUnitRuleInputSource]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[ChargeTypeBasisUnitRule_Id] [int] NOT NULL,
[TariffInputSource_Id] [int] NOT NULL,
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__ChargeTyp__LastU__343D60D9] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__ChargeTyp__LastU__35318512] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChargeTypeBasisUnitRuleInputSource] ADD CONSTRAINT [pk_ChargeTypeBasisUnitRuleInputSource] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_ChargeTypeBasisUnitRuleInputSource_RuleIdSourceId] ON [dbo].[ChargeTypeBasisUnitRuleInputSource] ([ChargeTypeBasisUnitRule_Id], [TariffInputSource_Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChargeTypeBasisUnitRuleInputSource] ADD CONSTRAINT [fk_ChargeTypeBasisUnitRuleInputSource_ChargeTypeBasisUnitRule_Id] FOREIGN KEY ([ChargeTypeBasisUnitRule_Id]) REFERENCES [dbo].[ChargeTypeBasisUnitRule] ([Id])
GO
ALTER TABLE [dbo].[ChargeTypeBasisUnitRuleInputSource] ADD CONSTRAINT [fk_ChargeTypeBasisUnitRuleInputSource_TariffInputSource_Id] FOREIGN KEY ([TariffInputSource_Id]) REFERENCES [dbo].[TariffInputSource] ([Id])
GO
GRANT DELETE ON  [dbo].[ChargeTypeBasisUnitRuleInputSource] TO [public]
GO
GRANT INSERT ON  [dbo].[ChargeTypeBasisUnitRuleInputSource] TO [public]
GO
GRANT SELECT ON  [dbo].[ChargeTypeBasisUnitRuleInputSource] TO [public]
GO
GRANT UPDATE ON  [dbo].[ChargeTypeBasisUnitRuleInputSource] TO [public]
GO
