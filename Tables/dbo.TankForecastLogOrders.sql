CREATE TABLE [dbo].[TankForecastLogOrders]
(
[LogId] [int] NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[Delivery1] [int] NOT NULL,
[Delivery2] [int] NOT NULL,
[Delivery3] [int] NOT NULL,
[Delivery4] [int] NOT NULL,
[Delivery5] [int] NOT NULL,
[Delivery6] [int] NOT NULL,
[Delivery7] [int] NOT NULL,
[Delivery8] [int] NOT NULL,
[Delivery9] [int] NOT NULL,
[Delivery10] [int] NOT NULL,
[ord_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Earliest] [datetime] NOT NULL,
[Latest] [datetime] NOT NULL,
[Arrival] [datetime] NOT NULL,
[Departure] [datetime] NOT NULL,
[PlacedHour] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastLogOrders] ADD CONSTRAINT [pk_TankForecastLogOrders] PRIMARY KEY CLUSTERED ([LogId], [ord_hdrnumber]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastLogOrders] ADD CONSTRAINT [FK_TankForecastLogOrders_LogId] FOREIGN KEY ([LogId]) REFERENCES [dbo].[TankForecastLog] ([LogId])
GO
GRANT DELETE ON  [dbo].[TankForecastLogOrders] TO [public]
GO
GRANT INSERT ON  [dbo].[TankForecastLogOrders] TO [public]
GO
GRANT SELECT ON  [dbo].[TankForecastLogOrders] TO [public]
GO
GRANT UPDATE ON  [dbo].[TankForecastLogOrders] TO [public]
GO
