CREATE TABLE [dbo].[tblBusinessRuleTypes]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RuleDefault] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalMailType] [int] NULL,
[StandardRule] [int] NULL,
[IntendedViewCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntendedViewFieldName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblBusinessRuleTypes] ADD CONSTRAINT [PK_tblBusinessRuleTypes] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblBusinessRuleTypes] TO [public]
GO
GRANT INSERT ON  [dbo].[tblBusinessRuleTypes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblBusinessRuleTypes] TO [public]
GO
GRANT SELECT ON  [dbo].[tblBusinessRuleTypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblBusinessRuleTypes] TO [public]
GO
