CREATE TABLE [dbo].[expedite_audit_activities]
(
[eaa_id] [int] NOT NULL IDENTITY(1, 1),
[eaa_application] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[eaa_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[eaa_activity] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[eaa_exclude] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[expedite_audit_activities] ADD CONSTRAINT [prkey_expedite_audit_activities] PRIMARY KEY CLUSTERED ([eaa_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_expedite_audit_activities] ON [dbo].[expedite_audit_activities] ([eaa_application], [eaa_userid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[expedite_audit_activities] TO [public]
GO
GRANT INSERT ON  [dbo].[expedite_audit_activities] TO [public]
GO
GRANT SELECT ON  [dbo].[expedite_audit_activities] TO [public]
GO
GRANT UPDATE ON  [dbo].[expedite_audit_activities] TO [public]
GO
