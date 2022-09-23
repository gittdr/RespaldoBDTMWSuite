CREATE TABLE [dbo].[tmw_external_userxref]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[tux_sourcesystem] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tux_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tux_userpassword] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tux_autologin] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tux_comment] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tmw_external_userxref] ADD CONSTRAINT [PK__tmw_external_use__1BF8CB91] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ndx_tux_usr_userid] ON [dbo].[tmw_external_userxref] ([usr_userid], [tux_sourcesystem]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tmw_external_userxref] TO [public]
GO
GRANT INSERT ON  [dbo].[tmw_external_userxref] TO [public]
GO
GRANT SELECT ON  [dbo].[tmw_external_userxref] TO [public]
GO
GRANT UPDATE ON  [dbo].[tmw_external_userxref] TO [public]
GO
