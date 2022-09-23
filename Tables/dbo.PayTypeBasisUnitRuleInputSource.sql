CREATE TABLE [dbo].[PayTypeBasisUnitRuleInputSource]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[PayTypeBasisUnitRule_Id] [int] NOT NULL,
[TariffInputSource_Id] [int] NOT NULL,
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__PayTypeBa__LastU__465C1114] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PayTypeBa__LastU__4750354D] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayTypeBasisUnitRuleInputSource] ADD CONSTRAINT [pk_PayTypeBasisUnitRuleInputSource] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_PayTypeBasisUnitRuleInputSource_RuleIdSourceId] ON [dbo].[PayTypeBasisUnitRuleInputSource] ([PayTypeBasisUnitRule_Id], [TariffInputSource_Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayTypeBasisUnitRuleInputSource] ADD CONSTRAINT [fk_PayTypeBasisUnitRuleInputSource_PayTypeBasisUnitRule_Id] FOREIGN KEY ([PayTypeBasisUnitRule_Id]) REFERENCES [dbo].[PayTypeBasisUnitRule] ([Id])
GO
ALTER TABLE [dbo].[PayTypeBasisUnitRuleInputSource] ADD CONSTRAINT [fk_PayTypeBasisUnitRuleInputSource_TariffInputSource_Id] FOREIGN KEY ([TariffInputSource_Id]) REFERENCES [dbo].[TariffInputSource] ([Id])
GO
GRANT DELETE ON  [dbo].[PayTypeBasisUnitRuleInputSource] TO [public]
GO
GRANT INSERT ON  [dbo].[PayTypeBasisUnitRuleInputSource] TO [public]
GO
GRANT SELECT ON  [dbo].[PayTypeBasisUnitRuleInputSource] TO [public]
GO
GRANT UPDATE ON  [dbo].[PayTypeBasisUnitRuleInputSource] TO [public]
GO
