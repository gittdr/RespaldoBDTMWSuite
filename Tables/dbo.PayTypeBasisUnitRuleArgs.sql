CREATE TABLE [dbo].[PayTypeBasisUnitRuleArgs]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[PayTypeBasisUnitRuleInputSource_Id] [int] NOT NULL,
[SeqNo] [int] NOT NULL CONSTRAINT [DF__PayTypeBa__SeqNo__4C14EA6A] DEFAULT ((0)),
[TariffInputSourceArgs_Id] [int] NOT NULL,
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__PayTypeBa__LastU__4D090EA3] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PayTypeBa__LastU__4DFD32DC] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayTypeBasisUnitRuleArgs] ADD CONSTRAINT [pk_PayTypeBasisUnitRuleArgs] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_PayTypeBasisUnitRuleArgs_PayTypeBasisUnitRuleInputSource_Id] ON [dbo].[PayTypeBasisUnitRuleArgs] ([PayTypeBasisUnitRuleInputSource_Id]) INCLUDE ([SeqNo], [TariffInputSourceArgs_Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayTypeBasisUnitRuleArgs] ADD CONSTRAINT [fk_PayTypeBasisUnitRuleArgs_PayTypeBasisUnitRuleInputSource_Id] FOREIGN KEY ([PayTypeBasisUnitRuleInputSource_Id]) REFERENCES [dbo].[PayTypeBasisUnitRuleInputSource] ([Id])
GO
ALTER TABLE [dbo].[PayTypeBasisUnitRuleArgs] ADD CONSTRAINT [fk_PayTypeBasisUnitRuleArgs_TariffInputSourceArgs_Id] FOREIGN KEY ([TariffInputSourceArgs_Id]) REFERENCES [dbo].[TariffInputSourceArgs] ([Id])
GO
GRANT DELETE ON  [dbo].[PayTypeBasisUnitRuleArgs] TO [public]
GO
GRANT INSERT ON  [dbo].[PayTypeBasisUnitRuleArgs] TO [public]
GO
GRANT SELECT ON  [dbo].[PayTypeBasisUnitRuleArgs] TO [public]
GO
GRANT UPDATE ON  [dbo].[PayTypeBasisUnitRuleArgs] TO [public]
GO
