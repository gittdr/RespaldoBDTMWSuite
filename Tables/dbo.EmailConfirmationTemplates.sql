CREATE TABLE [dbo].[EmailConfirmationTemplates]
(
[ect_id] [int] NOT NULL IDENTITY(1, 1),
[ect_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_subject] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_body] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmailConfirmationTemplates] ADD CONSTRAINT [pk_ect_id] PRIMARY KEY CLUSTERED ([ect_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EmailConfirmationTemplates] TO [public]
GO
GRANT INSERT ON  [dbo].[EmailConfirmationTemplates] TO [public]
GO
GRANT REFERENCES ON  [dbo].[EmailConfirmationTemplates] TO [public]
GO
GRANT SELECT ON  [dbo].[EmailConfirmationTemplates] TO [public]
GO
GRANT UPDATE ON  [dbo].[EmailConfirmationTemplates] TO [public]
GO
