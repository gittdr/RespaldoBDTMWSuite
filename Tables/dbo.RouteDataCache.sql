CREATE TABLE [dbo].[RouteDataCache]
(
[start_lat_key] [int] NOT NULL,
[start_long_key] [int] NOT NULL,
[end_lat_key] [int] NOT NULL,
[end_long_key] [int] NOT NULL,
[route_seq] [int] NOT NULL,
[latitude] [decimal] (12, 4) NOT NULL,
[longitude] [decimal] (12, 4) NOT NULL,
[hours] [decimal] (8, 1) NOT NULL,
[mileage] [decimal] (8, 1) NOT NULL,
[description] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RouteDataCache] ADD CONSTRAINT [pk_latlongs] PRIMARY KEY CLUSTERED ([start_lat_key], [start_long_key], [end_lat_key], [end_long_key], [route_seq]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RouteDataCache] TO [public]
GO
GRANT INSERT ON  [dbo].[RouteDataCache] TO [public]
GO
GRANT SELECT ON  [dbo].[RouteDataCache] TO [public]
GO
GRANT UPDATE ON  [dbo].[RouteDataCache] TO [public]
GO
