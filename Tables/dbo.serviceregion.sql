CREATE TABLE [dbo].[serviceregion]
(
[svc_id] [int] NOT NULL,
[svc_revtype] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[svc_revcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[svc_area] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[svc_center] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[svc_region] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_update] [datetime] NULL,
[last_updateby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[serviceregion] ADD CONSTRAINT [PK_serviceregion] PRIMARY KEY CLUSTERED ([svc_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[serviceregion] TO [public]
GO
GRANT INSERT ON  [dbo].[serviceregion] TO [public]
GO
GRANT REFERENCES ON  [dbo].[serviceregion] TO [public]
GO
GRANT SELECT ON  [dbo].[serviceregion] TO [public]
GO
GRANT UPDATE ON  [dbo].[serviceregion] TO [public]
GO
