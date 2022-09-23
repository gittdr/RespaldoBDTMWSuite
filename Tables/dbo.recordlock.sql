CREATE TABLE [dbo].[recordlock]
(
[session_date] [datetime] NOT NULL,
[locked_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[rl_ident] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_rl_ord_hdrnumber] ON [dbo].[recordlock] ([ord_hdrnumber], [session_date], [locked_by]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_rl_sesdate_lockedby] ON [dbo].[recordlock] ([session_date], [locked_by]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[recordlock] TO [public]
GO
GRANT INSERT ON  [dbo].[recordlock] TO [public]
GO
GRANT REFERENCES ON  [dbo].[recordlock] TO [public]
GO
GRANT SELECT ON  [dbo].[recordlock] TO [public]
GO
GRANT UPDATE ON  [dbo].[recordlock] TO [public]
GO
