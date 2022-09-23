CREATE TABLE [dbo].[SyncSet]
(
[SyncSet] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OtherServer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherOwner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherDB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OtherUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherPW] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SyncSet] TO [public]
GO
GRANT INSERT ON  [dbo].[SyncSet] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SyncSet] TO [public]
GO
GRANT SELECT ON  [dbo].[SyncSet] TO [public]
GO
GRANT UPDATE ON  [dbo].[SyncSet] TO [public]
GO
