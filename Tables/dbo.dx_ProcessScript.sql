CREATE TABLE [dbo].[dx_ProcessScript]
(
[dx_ident] [bigint] NOT NULL IDENTITY(1, 1),
[dx_importid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_script_seq] [int] NOT NULL,
[dx_script_command] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_script_parameter1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_script_parameter2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_script_parameter3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_script_parameter4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_script_parameter5] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_script_parameter6] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_script_comment] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_ProcessScript] ADD CONSTRAINT [pk_dx_ProcessScript] PRIMARY KEY CLUSTERED ([dx_importid], [dx_script_seq]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_ProcessScript] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_ProcessScript] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_ProcessScript] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_ProcessScript] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_ProcessScript] TO [public]
GO
