CREATE TABLE [dbo].[KaneDistZip]
(
[ImpId] [int] NOT NULL IDENTITY(1, 1),
[KaneId] [int] NOT NULL,
[AllAuthors] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HigherZip] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ID] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LowerZip] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerID] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PrimarySecondary] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C7TSTP] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateCreated] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KaneDistZip] ADD CONSTRAINT [PK_KaneDistZip] PRIMARY KEY CLUSTERED ([ImpId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KaneDistZip] ADD CONSTRAINT [FK_KaneDistZip_KaneBatch] FOREIGN KEY ([KaneId]) REFERENCES [dbo].[KaneBatch] ([KaneId])
GO
GRANT DELETE ON  [dbo].[KaneDistZip] TO [public]
GO
GRANT INSERT ON  [dbo].[KaneDistZip] TO [public]
GO
GRANT SELECT ON  [dbo].[KaneDistZip] TO [public]
GO
GRANT UPDATE ON  [dbo].[KaneDistZip] TO [public]
GO
