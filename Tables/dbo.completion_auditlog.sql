CREATE TABLE [dbo].[completion_auditlog]
(
[audit_id] [int] NOT NULL IDENTITY(1, 1),
[audit_ddtm] [datetime] NOT NULL CONSTRAINT [DF__completio__audit__767010EC] DEFAULT (getdate()),
[audit_user] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__completio__audit__77643525] DEFAULT (suser_sname()),
[audit_action] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[completion_auditlog] ADD CONSTRAINT [PK__completion_audit__757BECB3] PRIMARY KEY CLUSTERED ([audit_id]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[completion_auditlog] TO [public]
GO
GRANT SELECT ON  [dbo].[completion_auditlog] TO [public]
GO
