CREATE TABLE [dbo].[gl_reset]
(
[gl_id] [int] NOT NULL,
[gl_transferto] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_chargetype] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_triggeritem] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_matchvalue] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_startposition] [int] NULL,
[gl_length] [int] NULL,
[gl_value] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_altdbpath] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_excluded_acct_codes] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_reset_id] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [gl_id] ON [dbo].[gl_reset] ([gl_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[gl_reset] TO [public]
GO
GRANT INSERT ON  [dbo].[gl_reset] TO [public]
GO
GRANT REFERENCES ON  [dbo].[gl_reset] TO [public]
GO
GRANT SELECT ON  [dbo].[gl_reset] TO [public]
GO
GRANT UPDATE ON  [dbo].[gl_reset] TO [public]
GO
