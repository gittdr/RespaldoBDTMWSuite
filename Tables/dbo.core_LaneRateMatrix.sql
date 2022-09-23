CREATE TABLE [dbo].[core_LaneRateMatrix]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[LaneId] [int] NOT NULL,
[CarrierId] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Rate] [decimal] (18, 2) NOT NULL,
[OriginType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OriginValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DestinationType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DestinationValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MinType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinAmount] [decimal] (18, 2) NULL,
[RangeType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RangeMin] [decimal] (18, 2) NULL,
[RangeMax] [decimal] (18, 2) NULL,
[TariffNumber] [int] NULL,
[RateType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_LaneRateMatrix] ADD CONSTRAINT [PK_core_LaneRateMatrix] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_LaneRateMatrix] ADD CONSTRAINT [AK_core_LaneRateMatrix_NEW] UNIQUE NONCLUSTERED ([LaneId], [CarrierId], [OriginType], [OriginValue], [DestinationType], [DestinationValue], [MinType], [MinAmount], [RangeType], [RangeMin], [RangeMax], [RateType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_core_LaneRateMatrix_LocationsWithRate] ON [dbo].[core_LaneRateMatrix] ([OriginType], [OriginValue], [DestinationType], [DestinationValue], [Rate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[core_LaneRateMatrix] TO [public]
GO
GRANT INSERT ON  [dbo].[core_LaneRateMatrix] TO [public]
GO
GRANT REFERENCES ON  [dbo].[core_LaneRateMatrix] TO [public]
GO
GRANT SELECT ON  [dbo].[core_LaneRateMatrix] TO [public]
GO
GRANT UPDATE ON  [dbo].[core_LaneRateMatrix] TO [public]
GO
