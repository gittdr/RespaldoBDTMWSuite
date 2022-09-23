CREATE TABLE [dbo].[dwell_by_branch_company]
(
[dbbc_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evt_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dbbc_time] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dwell_by_branch_company] ADD CONSTRAINT [pk_dwell_by_branch_company_dbbc_id] PRIMARY KEY CLUSTERED ([dbbc_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dwell_by_branch_company] TO [public]
GO
GRANT INSERT ON  [dbo].[dwell_by_branch_company] TO [public]
GO
GRANT SELECT ON  [dbo].[dwell_by_branch_company] TO [public]
GO
GRANT UPDATE ON  [dbo].[dwell_by_branch_company] TO [public]
GO
