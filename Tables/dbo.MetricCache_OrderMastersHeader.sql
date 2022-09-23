CREATE TABLE [dbo].[MetricCache_OrderMastersHeader]
(
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateStart] [datetime] NOT NULL,
[DateEnd] [datetime] NOT NULL,
[Status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateUpdated] [datetime] NULL,
[MasterOrder] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Origin] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Destination] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StopsPerOccurance] [float] NULL,
[LineHaul] [money] NULL,
[AssessorialAllocation] [money] NULL,
[Revenue] [money] NULL,
[MilesPerOccurance] [float] NULL,
[STLAmount] [money] NULL,
[RevPerMile] [money] NULL,
[TractorsUsed] [float] NULL,
[TrailersUsed] [float] NULL,
[DriversUsed] [float] NULL,
[NumberOfDays] [float] NULL,
[Occurance] [float] NULL,
[GrossProfit] [money] NULL,
[DriverCost] [money] NULL,
[PowerCost] [money] NULL,
[TrailerCost] [money] NULL,
[MaintCost] [money] NULL,
[FuelCost] [money] NULL,
[Overhead] [money] NULL,
[Margin] [money] NULL,
[MarginTotal] [money] NULL,
[MetricCache_OrderMastersHeader_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricCache_OrderMastersHeader] ADD CONSTRAINT [prkey_MetricCache_OrderMastersHeader] PRIMARY KEY CLUSTERED ([MetricCache_OrderMastersHeader_ident]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MetricCache_OrderMastersHeader] ON [dbo].[MetricCache_OrderMastersHeader] ([MetricCode], [DateStart], [DateEnd]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricCache_OrderMastersHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricCache_OrderMastersHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricCache_OrderMastersHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricCache_OrderMastersHeader] TO [public]
GO
