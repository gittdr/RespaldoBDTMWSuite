CREATE TABLE [dbo].[ini_audit]
(
[audit_id] [int] NOT NULL IDENTITY(1, 1),
[audit_created] [datetime] NULL,
[audit_createdby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audit_user_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audit_file] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audit_section] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audit_item] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audit_oldvalue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audit_newvalue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audit_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ini_audit] ADD CONSTRAINT [audit_id_pk] PRIMARY KEY CLUSTERED ([audit_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ini_audit_N1] ON [dbo].[ini_audit] ([audit_user_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ini_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[ini_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[ini_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[ini_audit] TO [public]
GO
