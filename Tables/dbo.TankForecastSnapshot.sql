CREATE TABLE [dbo].[TankForecastSnapshot]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[UpdatedDate] [datetime] NOT NULL,
[UpdatedBy] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[forecast_bucket] [int] NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SafeFill] [int] NULL,
[ShutDown] [int] NULL,
[PriorReadingDate] [datetime] NULL,
[PriorReading] [int] NULL,
[LastReadingDate] [datetime] NULL,
[LastReading] [int] NULL,
[LastReadingEstSales] [int] NULL,
[LastReadingDeliveries] [int] NULL,
[NowReadingDate] [datetime] NULL,
[NowReading] [int] NULL,
[NowReadingEstSales] [int] NULL,
[NowDeliveries] [int] NULL,
[NowDeliveriesExcluded] [int] NULL,
[Reading12HoursDate] [datetime] NULL,
[Reading12Hours] [int] NULL,
[Reading12HoursEstSales] [int] NULL,
[Deliveries12Hours] [int] NULL,
[Deliveries12HoursExcluded] [int] NULL,
[Questionable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RunOutDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastSnapshot] ADD CONSTRAINT [PK_TankForecastSnapshot] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastSnapshot] ADD CONSTRAINT [DX_TankForecastSnapshot_cmp_id_forecast_bucket] UNIQUE NONCLUSTERED ([cmp_id], [forecast_bucket]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TankForecastSnapshot] TO [public]
GO
GRANT INSERT ON  [dbo].[TankForecastSnapshot] TO [public]
GO
GRANT UPDATE ON  [dbo].[TankForecastSnapshot] TO [public]
GO
