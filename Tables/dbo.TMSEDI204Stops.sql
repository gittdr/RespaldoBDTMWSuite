CREATE TABLE [dbo].[TMSEDI204Stops]
(
[Version] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Event] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScheduledDateTime] [datetime] NULL,
[EarliestDateTime] [datetime] NULL,
[LatestDateTime] [datetime] NULL,
[BillOfLading] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderId] [int] NOT NULL,
[StopId] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEDI204Stops] ADD CONSTRAINT [PK_TMSEDI204Stops] PRIMARY KEY CLUSTERED ([StopId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEDI204Stops] ADD CONSTRAINT [FK_TMSEDI204Stops_TMSEDI204Orders] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSEDI204Orders] ([OrderId])
GO
GRANT DELETE ON  [dbo].[TMSEDI204Stops] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSEDI204Stops] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSEDI204Stops] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSEDI204Stops] TO [public]
GO
