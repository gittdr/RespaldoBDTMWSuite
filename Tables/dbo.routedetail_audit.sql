CREATE TABLE [dbo].[routedetail_audit]
(
[audit_id] [int] NOT NULL IDENTITY(1, 1),
[rth_id] [int] NOT NULL,
[rtd_id] [int] NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cty_code] [int] NOT NULL,
[cty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rtd_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ttr_number] [int] NOT NULL,
[audit_user] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[audit_dttm] [datetime] NOT NULL,
[audit_action] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[routedetail_audit] ADD CONSTRAINT [pk_routedetail_audit] PRIMARY KEY CLUSTERED ([audit_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[routedetail_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[routedetail_audit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[routedetail_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[routedetail_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[routedetail_audit] TO [public]
GO
