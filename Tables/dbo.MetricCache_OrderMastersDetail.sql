CREATE TABLE [dbo].[MetricCache_OrderMastersDetail]
(
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateStart] [datetime] NOT NULL,
[DateEnd] [datetime] NOT NULL,
[Status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateUpdated] [datetime] NULL,
[MasterOrder] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Origin] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Destination] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LineHaul] [money] NULL,
[Miles] [float] NULL,
[DrvCount] [float] NULL,
[TRCCount] [float] NULL,
[TRLCount] [float] NULL,
[Occurance] [float] NULL,
[CountStops] [float] NULL,
[STLAmount] [money] NULL,
[NumberOfDays] [float] NULL,
[MetricCache_OrderMastersDetail_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricCache_OrderMastersDetail] ADD CONSTRAINT [prkey_MetricCache_OrderMastersDetail] PRIMARY KEY CLUSTERED ([MetricCache_OrderMastersDetail_ident]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MetricCache_OrderMastersDetail] ON [dbo].[MetricCache_OrderMastersDetail] ([MetricCode], [DateStart], [DateEnd]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricCache_OrderMastersDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricCache_OrderMastersDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricCache_OrderMastersDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricCache_OrderMastersDetail] TO [public]
GO
