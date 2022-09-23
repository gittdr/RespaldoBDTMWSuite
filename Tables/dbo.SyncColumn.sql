CREATE TABLE [dbo].[SyncColumn]
(
[PSTable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PSColumn] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherColumn] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSOwner] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SyncSet] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SyncColumn] TO [public]
GO
GRANT INSERT ON  [dbo].[SyncColumn] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SyncColumn] TO [public]
GO
GRANT SELECT ON  [dbo].[SyncColumn] TO [public]
GO
GRANT UPDATE ON  [dbo].[SyncColumn] TO [public]
GO
