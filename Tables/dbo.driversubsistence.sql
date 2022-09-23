CREATE TABLE [dbo].[driversubsistence]
(
[dss_id] [int] NOT NULL IDENTITY(1, 1),
[dss_date] [datetime] NULL,
[dss_eligible] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dss_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dss_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dss_created_by] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dss_created_date] [datetime] NULL,
[dss_last_checkcall_Lookup_date] [datetime] NULL,
[dss_asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dss_asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dss_lastupdated_by] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dss_lastupdated_date] [datetime] NULL,
[dss_pyh_phnumber] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[driversubsistence] ADD CONSTRAINT [pk_dssid] PRIMARY KEY CLUSTERED ([dss_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[driversubsistence] TO [public]
GO
GRANT INSERT ON  [dbo].[driversubsistence] TO [public]
GO
GRANT REFERENCES ON  [dbo].[driversubsistence] TO [public]
GO
GRANT SELECT ON  [dbo].[driversubsistence] TO [public]
GO
GRANT UPDATE ON  [dbo].[driversubsistence] TO [public]
GO
