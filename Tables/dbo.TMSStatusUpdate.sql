CREATE TABLE [dbo].[TMSStatusUpdate]
(
[StatusId] [int] NOT NULL IDENTITY(1, 1),
[OrderId] [int] NULL,
[ShipId] [int] NULL,
[StatusCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TransactionBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TransactionDate] [datetime] NOT NULL,
[InsertedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InsertedDate] [datetime] NOT NULL,
[FromSystem] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Data1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Data2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Data3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Data4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateTime1] [datetime] NULL,
[DateTime2] [datetime] NULL,
[ActionCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RawData] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TMSProcessed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TMSProcessedDate] [datetime] NULL,
[ETSProcessed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ETSProcessedDate] [datetime] NULL,
[StopType] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StopArrivalOrDeparture] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSStatusUpdate] ADD CONSTRAINT [PK_TMSStatusUpdate] PRIMARY KEY CLUSTERED ([StatusId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ux_TMSStatusUpdate_ShipId_OrderId_StatusCode_TransactionDate] ON [dbo].[TMSStatusUpdate] ([ShipId], [OrderId], [StatusCode], [TransactionDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSStatusUpdate] ADD CONSTRAINT [FK_TMSStatusUpdate_TMSOrder] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSOrder] ([OrderId])
GO
ALTER TABLE [dbo].[TMSStatusUpdate] ADD CONSTRAINT [FK_TMSStatusUpdate_TMSShipment] FOREIGN KEY ([ShipId]) REFERENCES [dbo].[TMSShipment] ([ShipId])
GO
ALTER TABLE [dbo].[TMSStatusUpdate] ADD CONSTRAINT [FK_TMSStatusUpdate_TMSStatusActionList] FOREIGN KEY ([ActionCode]) REFERENCES [dbo].[TMSStatusActionList] ([ActionCode])
GO
ALTER TABLE [dbo].[TMSStatusUpdate] ADD CONSTRAINT [FK_TMSStatusUpdate_TMSStatusUpdates] FOREIGN KEY ([StatusCode]) REFERENCES [dbo].[TMSStatusList] ([StatusCode])
GO
GRANT DELETE ON  [dbo].[TMSStatusUpdate] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSStatusUpdate] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSStatusUpdate] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSStatusUpdate] TO [public]
GO
