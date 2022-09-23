CREATE TABLE [dbo].[alkmvs_error]
(
[ame_id] [int] NOT NULL IDENTITY(1, 1),
[ame_win_user] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ame_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ame_machine] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ame_time] [datetime] NOT NULL CONSTRAINT [DF__alkmvs_er__ame_t__705B6F60] DEFAULT (getdate()),
[ame_version] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[alkmvs_error] TO [public]
GO
GRANT INSERT ON  [dbo].[alkmvs_error] TO [public]
GO
GRANT REFERENCES ON  [dbo].[alkmvs_error] TO [public]
GO
GRANT SELECT ON  [dbo].[alkmvs_error] TO [public]
GO
GRANT UPDATE ON  [dbo].[alkmvs_error] TO [public]
GO
