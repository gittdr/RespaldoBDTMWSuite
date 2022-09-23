CREATE TABLE [dbo].[spid_tracking]
(
[spid] [int] NOT NULL,
[rdbms_login] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rdbms_user] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[usr_userid] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created] [datetime] NOT NULL,
[usr_windows_userid] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_alias] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[spid_tracking] ADD CONSTRAINT [spid_pk] PRIMARY KEY CLUSTERED ([spid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[spid_tracking] TO [public]
GO
GRANT INSERT ON  [dbo].[spid_tracking] TO [public]
GO
GRANT SELECT ON  [dbo].[spid_tracking] TO [public]
GO
GRANT UPDATE ON  [dbo].[spid_tracking] TO [public]
GO
