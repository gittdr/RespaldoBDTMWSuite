CREATE TABLE [dbo].[TMSAuditLog]
(
[AuditId] [bigint] NOT NULL IDENTITY(1, 1),
[Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Field] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrigValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChangedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChangedOn] [datetime] NOT NULL,
[Comment] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMSAuditLog] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSAuditLog] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSAuditLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSAuditLog] TO [public]
GO
