CREATE TABLE [dbo].[TMSEDI204Orders]
(
[OrderId] [int] NOT NULL IDENTITY(1, 1),
[BatchId] [int] NOT NULL,
[Version] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISAGSID] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Purpose] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BookDate] [datetime] NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[PaymentMethod] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalChargeCurrency] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalCharge] [decimal] (12, 2) NULL,
[TotalWeight] [decimal] (12, 2) NULL,
[TotalMiles] [decimal] (12, 2) NULL,
[TotalPieces] [decimal] (12, 2) NULL,
[EDIControlNumber] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipmentNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AlternateCurrency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MasterOrderNumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EDITransactionType] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEDI204Orders] ADD CONSTRAINT [PK_TMS_EDI204_OrderTable] PRIMARY KEY CLUSTERED ([OrderId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEDI204Orders] ADD CONSTRAINT [FK_TMSEDI204Orders_TMSEDI204Batches] FOREIGN KEY ([BatchId]) REFERENCES [dbo].[TMSEDI204Batches] ([BatchId])
GO
GRANT DELETE ON  [dbo].[TMSEDI204Orders] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSEDI204Orders] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSEDI204Orders] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSEDI204Orders] TO [public]
GO
