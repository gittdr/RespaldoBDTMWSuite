CREATE TABLE [dbo].[tblMessages]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Type] [int] NULL,
[Status] [int] NULL,
[Priority] [int] NULL,
[FromType] [int] NULL CONSTRAINT [DF__tblMessag__FromT__57E7F8DC] DEFAULT ((0)),
[DeliverToType] [int] NULL,
[DTSent] [datetime] NULL,
[DTReceived] [datetime] NULL,
[DTRead] [datetime] NULL,
[DTAcknowledged] [datetime] NULL,
[DTTransferred] [datetime] NULL,
[Folder] [int] NULL,
[Contents] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subject] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliverTo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HistDrv] [int] NULL,
[HistDrv2] [int] NULL,
[HistTrk] [int] NULL,
[ts] [timestamp] NULL,
[OrigMsgSN] [int] NULL,
[Receipt] [int] NULL CONSTRAINT [DF__tblMessag__Recei__4D5F7D71] DEFAULT ((0)),
[DeliveryKey] [int] NULL,
[Position] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tblMessag__Posit__5E54FF49] DEFAULT ((0)),
[PositionZip] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NLCPosition] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NLCPositionZip] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleIgnition] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[DTPosition] [datetime] NULL,
[SpecialMsgSN] [int] NULL,
[ResubmitOf] [int] NULL,
[Odometer] [int] NULL,
[ReplyMsgSN] [int] NULL,
[ReplyMsgPage] [int] NULL,
[ReplyFormID] [int] NULL,
[ReplyPriority] [int] NULL,
[ToDrvSN] [int] NULL,
[ToTrcSN] [int] NULL,
[FromDrvSN] [int] NULL,
[FromTrcSN] [int] NULL,
[MaxDelayMins] [int] NULL,
[BaseSN] [int] NULL,
[McuId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Export] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMessages] ADD CONSTRAINT [aaaaatblMessages_PK] PRIMARY KEY NONCLUSTERED ([SN]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMessages] ADD CONSTRAINT [FK__Temporary__Folde__198AD3B0] FOREIGN KEY ([Folder]) REFERENCES [dbo].[tblFolders] ([SN])
GO
ALTER TABLE [dbo].[tblMessages] ADD CONSTRAINT [FK__Temporary__Prior__1896AF77] FOREIGN KEY ([Priority]) REFERENCES [dbo].[tblMsgPriority] ([SN])
GO
ALTER TABLE [dbo].[tblMessages] ADD CONSTRAINT [FK__Temporary__Statu__17A28B3E] FOREIGN KEY ([Status]) REFERENCES [dbo].[tblMsgStatus] ([SN])
GO
ALTER TABLE [dbo].[tblMessages] ADD CONSTRAINT [FK__TemporaryU__Type__16AE6705] FOREIGN KEY ([Type]) REFERENCES [dbo].[tblMsgType] ([SN])
GO
