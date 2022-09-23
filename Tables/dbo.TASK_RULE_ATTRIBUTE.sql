CREATE TABLE [dbo].[TASK_RULE_ATTRIBUTE]
(
[TASK_RULE_ATTRIBUTE_ID] [int] NOT NULL IDENTITY(1, 1),
[NAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TYPE] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DWSYNTAX] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CREATED_DATE] [datetime] NOT NULL,
[CREATED_USER] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MODIFIED_DATE] [datetime] NOT NULL,
[MODIFIED_USER] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TASK_RULE_ATTRIBUTE] ADD CONSTRAINT [PK__TASK_RULE_ATTRIB__7FCE2F09] PRIMARY KEY CLUSTERED ([TASK_RULE_ATTRIBUTE_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TASK_RULE_ATTRIBUTE] TO [public]
GO
GRANT INSERT ON  [dbo].[TASK_RULE_ATTRIBUTE] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TASK_RULE_ATTRIBUTE] TO [public]
GO
GRANT SELECT ON  [dbo].[TASK_RULE_ATTRIBUTE] TO [public]
GO
GRANT UPDATE ON  [dbo].[TASK_RULE_ATTRIBUTE] TO [public]
GO
