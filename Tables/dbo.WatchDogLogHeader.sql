CREATE TABLE [dbo].[WatchDogLogHeader]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[WatchName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LogDate] [datetime] NULL,
[RunDuration] [decimal] (9, 3) NULL,
[DismissedFlag] [bit] NULL,
[MessageText] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThresholdValue] [float] NULL,
[TransactionCount] [int] NULL,
[ParentWatchName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[CarrierName] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WatchDogLogHeader] ADD CONSTRAINT [PK_WatchDogLogHeader] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WatchDogLogHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[WatchDogLogHeader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[WatchDogLogHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[WatchDogLogHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[WatchDogLogHeader] TO [public]
GO
