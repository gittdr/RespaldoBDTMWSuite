CREATE TABLE [dbo].[TTSUserDatabases]
(
[tud_id] [int] NOT NULL IDENTITY(1, 1),
[tud_user_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tud_concat] [varchar] (121) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tud_Server] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tud_DB] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TTSUserDatabases] ADD CONSTRAINT [pk_tud_id] PRIMARY KEY CLUSTERED ([tud_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TTSUserDatabases] TO [public]
GO
GRANT INSERT ON  [dbo].[TTSUserDatabases] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TTSUserDatabases] TO [public]
GO
GRANT SELECT ON  [dbo].[TTSUserDatabases] TO [public]
GO
GRANT UPDATE ON  [dbo].[TTSUserDatabases] TO [public]
GO
