CREATE TABLE [dbo].[company_services]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[svc_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[stp_type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [float] NULL,
[create_userid] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_date] [datetime] NULL,
[rowchgts] [timestamp] NOT NULL,
[auto_assign] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_services] ADD CONSTRAINT [PK__company___EB04C08E5A44686A] PRIMARY KEY CLUSTERED ([cmp_id], [svc_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_services] TO [public]
GO
GRANT INSERT ON  [dbo].[company_services] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_services] TO [public]
GO
GRANT SELECT ON  [dbo].[company_services] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_services] TO [public]
GO
