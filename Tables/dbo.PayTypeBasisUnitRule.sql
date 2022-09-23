CREATE TABLE [dbo].[PayTypeBasisUnitRule]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[RuleType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PayTypeBa__RuleT__41975BF7] DEFAULT ('SP'),
[BasisUnitRuleName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PhysicalName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__PayTypeBa__LastU__428B8030] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PayTypeBa__LastU__437FA469] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayTypeBasisUnitRule] ADD CONSTRAINT [pk_PayTypeBasisUnitRule] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_PayTypeBasisUnitRule_BasisUnitRuleName] ON [dbo].[PayTypeBasisUnitRule] ([BasisUnitRuleName]) INCLUDE ([Id], [RuleType], [PhysicalName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PayTypeBasisUnitRule] TO [public]
GO
GRANT INSERT ON  [dbo].[PayTypeBasisUnitRule] TO [public]
GO
GRANT SELECT ON  [dbo].[PayTypeBasisUnitRule] TO [public]
GO
GRANT UPDATE ON  [dbo].[PayTypeBasisUnitRule] TO [public]
GO
