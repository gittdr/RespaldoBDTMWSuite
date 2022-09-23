CREATE TABLE [dbo].[routeheader_audit]
(
[audit_id] [int] NOT NULL IDENTITY(1, 1),
[rth_id] [int] NOT NULL,
[rth_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[audit_user] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[audit_dttm] [datetime] NOT NULL,
[audit_action] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[routeheader_audit] ADD CONSTRAINT [pk_routeheader_audit] PRIMARY KEY CLUSTERED ([audit_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[routeheader_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[routeheader_audit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[routeheader_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[routeheader_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[routeheader_audit] TO [public]
GO
