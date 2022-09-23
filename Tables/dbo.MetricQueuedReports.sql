CREATE TABLE [dbo].[MetricQueuedReports]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[UserSN] [int] NULL,
[Status] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Report_GUID] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtCreate] [datetime] NULL CONSTRAINT [DF__MetricQue__dtCre__0A34B072] DEFAULT (getdate()),
[dtReady] [datetime] NULL,
[dtRead] [datetime] NULL,
[MachineName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__MetricQue__Machi__0B28D4AB] DEFAULT (host_name()),
[Path] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtStarted] [datetime] NULL,
[RunDuration] [float] NULL,
[SQL] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricQueuedReports] ADD CONSTRAINT [AutoPK_MetricQueuedReports_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricQueuedReports] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricQueuedReports] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricQueuedReports] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricQueuedReports] TO [public]
GO
