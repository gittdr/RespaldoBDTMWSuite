CREATE TABLE [dbo].[MicrodeaMaps]
(
[mic_key] [int] NOT NULL IDENTITY(1, 1),
[mic_appid] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mic_server] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mic_repository] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mic_keyfield] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mic_altkeyfield] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mic_user_name] [char] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mic_password] [char] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mic_view] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mic_moduleid] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mic_Systemid] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MicrodeaMaps] TO [public]
GO
GRANT INSERT ON  [dbo].[MicrodeaMaps] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MicrodeaMaps] TO [public]
GO
GRANT SELECT ON  [dbo].[MicrodeaMaps] TO [public]
GO
GRANT UPDATE ON  [dbo].[MicrodeaMaps] TO [public]
GO
