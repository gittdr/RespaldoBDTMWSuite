CREATE TABLE [dbo].[alias_logging]
(
[al_id] [int] NOT NULL IDENTITY(1, 1),
[al_usr_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[al_usr_userid_alias] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[al_logdatetime] [datetime] NOT NULL,
[al_spid] [int] NOT NULL,
[al_rdbms_login_user] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[al_rdbms_db_user] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[alias_logging] ADD CONSTRAINT [alias_logging_pk] PRIMARY KEY CLUSTERED ([al_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[alias_logging] TO [public]
GO
GRANT INSERT ON  [dbo].[alias_logging] TO [public]
GO
GRANT SELECT ON  [dbo].[alias_logging] TO [public]
GO
GRANT UPDATE ON  [dbo].[alias_logging] TO [public]
GO
