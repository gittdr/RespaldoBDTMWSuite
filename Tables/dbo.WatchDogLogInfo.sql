CREATE TABLE [dbo].[WatchDogLogInfo]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[dateandtime] [datetime] NULL CONSTRAINT [DF__WatchDogL__datea__239F7CBA] DEFAULT (getdate()),
[Event] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MachineName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WatchName] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fired_YN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Results_YN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorOnRun_YN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorOnEmail_YN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorDescription] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunDuration] [decimal] (9, 3) NULL,
[MoreInfo] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_WatchDogLogInfo_dateandtime] ON [dbo].[WatchDogLogInfo] ([dateandtime]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_WatchDogLogInfo_WatchName] ON [dbo].[WatchDogLogInfo] ([WatchName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WatchDogLogInfo] TO [public]
GO
GRANT INSERT ON  [dbo].[WatchDogLogInfo] TO [public]
GO
GRANT SELECT ON  [dbo].[WatchDogLogInfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[WatchDogLogInfo] TO [public]
GO
