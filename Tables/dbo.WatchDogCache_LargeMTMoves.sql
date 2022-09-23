CREATE TABLE [dbo].[WatchDogCache_LargeMTMoves]
(
[Move Number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Empty Miles] [int] NULL,
[CacheDate] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WatchDogCache_LargeMTMoves] TO [public]
GO
GRANT INSERT ON  [dbo].[WatchDogCache_LargeMTMoves] TO [public]
GO
GRANT SELECT ON  [dbo].[WatchDogCache_LargeMTMoves] TO [public]
GO
GRANT UPDATE ON  [dbo].[WatchDogCache_LargeMTMoves] TO [public]
GO
