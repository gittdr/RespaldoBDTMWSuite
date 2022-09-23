CREATE TABLE [dbo].[services]
(
[svc_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[svc_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[svc_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_services_svc_type] DEFAULT ('A'),
[svc_chargetype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[svc_chargetype_rule] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[svc_chargetype_default_rate] [money] NULL,
[svc_paytype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[svc_paytype_rule] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[svc_paytype_default_rate] [money] NULL,
[svc_default_qty] [money] NULL,
[svc_comment] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_userid] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_services_create_userid] DEFAULT (user_name()),
[create_date] [datetime] NOT NULL CONSTRAINT [DF_services_create_date] DEFAULT (getdate()),
[applies_to] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[disp_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[svc_webdisplay] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[services] ADD CONSTRAINT [PK_services] PRIMARY KEY NONCLUSTERED ([svc_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[services] TO [public]
GO
GRANT INSERT ON  [dbo].[services] TO [public]
GO
GRANT REFERENCES ON  [dbo].[services] TO [public]
GO
GRANT SELECT ON  [dbo].[services] TO [public]
GO
GRANT UPDATE ON  [dbo].[services] TO [public]
GO
