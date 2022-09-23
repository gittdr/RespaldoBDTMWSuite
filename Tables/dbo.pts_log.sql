CREATE TABLE [dbo].[pts_log]
(
[pts_id] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pts_sql_generated_date] [datetime] NOT NULL,
[pts_sql_applied_date] [datetime] NOT NULL,
[pts_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sn] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pts_log] ADD CONSTRAINT [pk_pts_log] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_pts_id] ON [dbo].[pts_log] ([pts_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pts_log] TO [public]
GO
GRANT INSERT ON  [dbo].[pts_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[pts_log] TO [public]
GO
GRANT SELECT ON  [dbo].[pts_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[pts_log] TO [public]
GO
