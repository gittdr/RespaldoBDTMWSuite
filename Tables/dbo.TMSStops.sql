CREATE TABLE [dbo].[TMSStops]
(
[StopId] [int] NOT NULL IDENTITY(1, 1),
[StopType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderId] [int] NULL,
[LocationId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationAltId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationCityCode] [int] NULL,
[LocationCityState] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationLat] [decimal] (12, 5) NULL,
[LocationLong] [decimal] (12, 5) NULL,
[WindowDateEarliest] [datetime] NOT NULL,
[WindowDateLatest] [datetime] NOT NULL,
[Distance] [decimal] (12, 5) NULL,
[TravelTime] [decimal] (12, 5) NULL,
[Sequence] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSStops] ADD CONSTRAINT [PK_TMSStops] PRIMARY KEY CLUSTERED ([StopId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DX_TMSStops_OrderId] ON [dbo].[TMSStops] ([OrderId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSStops] ADD CONSTRAINT [FK_TMSStops_TMSOrder] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSOrder] ([OrderId])
GO
GRANT DELETE ON  [dbo].[TMSStops] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSStops] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSStops] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSStops] TO [public]
GO
