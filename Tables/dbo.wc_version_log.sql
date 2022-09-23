CREATE TABLE [dbo].[wc_version_log]
(
[dbversion] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[begindate] [datetime] NULL,
[enddate] [datetime] NULL,
[description] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[version_activated] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[wc_version_log] TO [public]
GO
GRANT INSERT ON  [dbo].[wc_version_log] TO [public]
GO
GRANT SELECT ON  [dbo].[wc_version_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[wc_version_log] TO [public]
GO
