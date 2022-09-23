CREATE TABLE [dbo].[manifestheaderaudit]
(
[audit_id] [int] NOT NULL IDENTITY(1, 1),
[audit_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[audit_user] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[audit_date] [datetime] NULL,
[stp_number_start] [int] NULL,
[stp_number_end] [int] NULL,
[mfh_number] [int] NULL,
[mov_number] [int] NULL,
[unit_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seal_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_committed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[manifest_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recommended_door] [int] NULL,
[planned_ob_door] [int] NULL,
[route_id] [int] NULL,
[status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[manifestheaderaudit] ADD CONSTRAINT [pk_manifestheaderaudit] PRIMARY KEY CLUSTERED ([audit_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [manifestheaderaudit_mfh_number] ON [dbo].[manifestheaderaudit] ([mfh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[manifestheaderaudit] TO [public]
GO
GRANT INSERT ON  [dbo].[manifestheaderaudit] TO [public]
GO
GRANT SELECT ON  [dbo].[manifestheaderaudit] TO [public]
GO
GRANT UPDATE ON  [dbo].[manifestheaderaudit] TO [public]
GO
