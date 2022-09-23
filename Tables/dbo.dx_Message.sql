CREATE TABLE [dbo].[dx_Message]
(
[dx_ident] [bigint] NOT NULL IDENTITY(1, 1),
[dx_command] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_returncode] [int] NOT NULL,
[dx_errormsg] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_Message] ADD CONSTRAINT [pk_dx_Message] PRIMARY KEY CLUSTERED ([dx_command], [dx_returncode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_Message] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_Message] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_Message] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_Message] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_Message] TO [public]
GO
