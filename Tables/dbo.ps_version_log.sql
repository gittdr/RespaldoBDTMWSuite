CREATE TABLE [dbo].[ps_version_log]
(
[dbversion] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[begindate] [datetime] NOT NULL,
[enddate] [datetime] NOT NULL,
[description] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[version_activated] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ps_version_log] TO [public]
GO
GRANT INSERT ON  [dbo].[ps_version_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ps_version_log] TO [public]
GO
GRANT SELECT ON  [dbo].[ps_version_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[ps_version_log] TO [public]
GO
