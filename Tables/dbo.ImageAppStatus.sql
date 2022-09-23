CREATE TABLE [dbo].[ImageAppStatus]
(
[ias_AppName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ias_Status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_appname] ON [dbo].[ImageAppStatus] ([ias_AppName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImageAppStatus] TO [public]
GO
GRANT INSERT ON  [dbo].[ImageAppStatus] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ImageAppStatus] TO [public]
GO
GRANT SELECT ON  [dbo].[ImageAppStatus] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImageAppStatus] TO [public]
GO
