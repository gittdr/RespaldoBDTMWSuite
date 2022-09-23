CREATE TABLE [dbo].[TMSOrder]
(
[OrderId] [int] NOT NULL IDENTITY(1, 1),
[ImportBatch] [bigint] NOT NULL,
[Branch] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NotifyDate] [datetime] NULL,
[OrderNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PONumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [TMSOrder_Status1_Default] DEFAULT ('AVL'),
[Status2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type5] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type6] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type7] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type8] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type9] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type10] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillToId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Commodity] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FreightClass] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalQuantity1] [decimal] (12, 4) NULL,
[TotalQuantity2] [decimal] (12, 4) NULL,
[TotalQuantity3] [decimal] (12, 4) NULL,
[ReferenceValue1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferenceValue2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Referencevalue3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remarks1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remarks2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispatchNumber] [int] NULL,
[TransferDate] [datetime] NULL,
[Mode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Carrier] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CancelDate] [datetime] NULL,
[CancelReason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CancelUser] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PromisedDate] [datetime] NULL,
[OriginalPromisedDate] [datetime] NULL,
[ord_hdrnumber] [int] NULL,
[TransferBatch] [bigint] NULL,
[OptBatch] [bigint] NULL,
[TotalQuantity1Unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalQuantity2Unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalQuantity3Unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderBy] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TMSOrder_OrderBY] DEFAULT ('UNKNOWN')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrder] ADD CONSTRAINT [PK_TMSOrder] PRIMARY KEY CLUSTERED ([OrderId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ui_TMSOrder_Branch_OrderNumber] ON [dbo].[TMSOrder] ([Branch], [OrderNumber]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrder] WITH NOCHECK ADD CONSTRAINT [fk_TMSOrder_OptBatch] FOREIGN KEY ([OptBatch]) REFERENCES [dbo].[TMSBatch] ([BatchId])
GO
ALTER TABLE [dbo].[TMSOrder] WITH NOCHECK ADD CONSTRAINT [fk_TMSOrder_TransferBatch] FOREIGN KEY ([TransferBatch]) REFERENCES [dbo].[TMSBatch] ([BatchId])
GO
GRANT DELETE ON  [dbo].[TMSOrder] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSOrder] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSOrder] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSOrder] TO [public]
GO
