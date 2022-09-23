CREATE TABLE [dbo].[WatchDogCache]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[WatchName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Identifier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CacheDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WatchDogCache] ADD CONSTRAINT [PK_WatchDog_Cache] PRIMARY KEY CLUSTERED ([WatchName], [Identifier]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WatchDogCache] TO [public]
GO
GRANT INSERT ON  [dbo].[WatchDogCache] TO [public]
GO
GRANT SELECT ON  [dbo].[WatchDogCache] TO [public]
GO
GRANT UPDATE ON  [dbo].[WatchDogCache] TO [public]
GO
