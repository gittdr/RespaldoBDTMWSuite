CREATE TABLE [dbo].[RuleSet]
(
[ObjectName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RuleSetType] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Version] [int] NOT NULL,
[RuleSetName] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RuleSet] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssemblyPath] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModifiedDate] [datetime] NULL,
[ModifiedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RuleSet] ADD CONSTRAINT [pk_RuleSet] PRIMARY KEY CLUSTERED ([ObjectName], [RuleSetType], [Version]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_RuleSet_NameMajorMinor] ON [dbo].[RuleSet] ([ObjectName], [RuleSetType], [Version]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RuleSet] TO [public]
GO
GRANT INSERT ON  [dbo].[RuleSet] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RuleSet] TO [public]
GO
GRANT SELECT ON  [dbo].[RuleSet] TO [public]
GO
GRANT UPDATE ON  [dbo].[RuleSet] TO [public]
GO
