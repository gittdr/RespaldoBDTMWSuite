CREATE TABLE [dbo].[KaneBatch]
(
[KaneId] [int] NOT NULL IDENTITY(1, 1),
[OrderFile] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShipFile] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DistributorFile] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DistZipFile] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllocationFile] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatusFile] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KaneBatch] ADD CONSTRAINT [PK_KaneBatch] PRIMARY KEY CLUSTERED ([KaneId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[KaneBatch] TO [public]
GO
GRANT INSERT ON  [dbo].[KaneBatch] TO [public]
GO
GRANT SELECT ON  [dbo].[KaneBatch] TO [public]
GO
GRANT UPDATE ON  [dbo].[KaneBatch] TO [public]
GO
