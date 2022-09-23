CREATE TABLE [dbo].[ChargeTypeBasisUnitRule]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[RuleType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__ChargeTyp__RuleT__2F78ABBC] DEFAULT ('SP'),
[BasisUnitRuleName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PhysicalName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__ChargeTyp__LastU__306CCFF5] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__ChargeTyp__LastU__3160F42E] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChargeTypeBasisUnitRule] ADD CONSTRAINT [pk_ChargeTypeBasisUnitRule] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_ChargeTypeBasisUnitRule_BasisUnitRuleName] ON [dbo].[ChargeTypeBasisUnitRule] ([BasisUnitRuleName]) INCLUDE ([Id], [RuleType], [PhysicalName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ChargeTypeBasisUnitRule] TO [public]
GO
GRANT INSERT ON  [dbo].[ChargeTypeBasisUnitRule] TO [public]
GO
GRANT SELECT ON  [dbo].[ChargeTypeBasisUnitRule] TO [public]
GO
GRANT UPDATE ON  [dbo].[ChargeTypeBasisUnitRule] TO [public]
GO
