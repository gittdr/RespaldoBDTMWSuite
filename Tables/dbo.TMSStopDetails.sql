CREATE TABLE [dbo].[TMSStopDetails]
(
[StopDetId] [int] NOT NULL IDENTITY(1, 1),
[StopId] [int] NOT NULL,
[OrderId] [int] NULL,
[LineItemId] [int] NULL,
[DetailType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSStopDetails] ADD CONSTRAINT [PK_TMSStopDetails] PRIMARY KEY CLUSTERED ([StopDetId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSStopDetails] ADD CONSTRAINT [FK_TMSStopDetails_TMSStop] FOREIGN KEY ([StopId]) REFERENCES [dbo].[TMSStops] ([StopId])
GO
GRANT DELETE ON  [dbo].[TMSStopDetails] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSStopDetails] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSStopDetails] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSStopDetails] TO [public]
GO
