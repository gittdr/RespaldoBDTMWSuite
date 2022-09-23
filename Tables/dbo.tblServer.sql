CREATE TABLE [dbo].[tblServer]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[ServerCode] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InBox] [int] NULL,
[OutBox] [int] NULL,
[Sent] [int] NULL,
[Deleted] [int] NULL,
[LastPoll] [datetime] NULL,
[PollRate] [datetime] NULL,
[Working] [int] NULL,
[Flags] [int] NULL,
[ResetRequest] [datetime] NULL,
[Reset] [datetime] NULL,
[Data] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Data2] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [bit] NULL,
[AgentID] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblServer] ADD CONSTRAINT [PK_tblServer_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Deleted] ON [dbo].[tblServer] ([Deleted]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [InBox] ON [dbo].[tblServer] ([InBox]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [OutBox] ON [dbo].[tblServer] ([OutBox]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Sent] ON [dbo].[tblServer] ([Sent]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ServerCode] ON [dbo].[tblServer] ([ServerCode]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Working] ON [dbo].[tblServer] ([Working]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblServer].[InBox]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblServer].[OutBox]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblServer].[Sent]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblServer].[Deleted]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblServer].[Working]'
GO
GRANT DELETE ON  [dbo].[tblServer] TO [public]
GO
GRANT INSERT ON  [dbo].[tblServer] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblServer] TO [public]
GO
GRANT SELECT ON  [dbo].[tblServer] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblServer] TO [public]
GO
