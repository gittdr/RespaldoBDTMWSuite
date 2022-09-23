CREATE TABLE [dbo].[DirectRouteTruckDetails]
(
[drt_id] [int] NOT NULL IDENTITY(1, 1),
[drh_id] [int] NOT NULL,
[trl_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trl_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zipcode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Estart] [datetime] NULL,
[Eday] [int] NULL,
[Lday] [int] NULL,
[LatFinish] [date] NULL,
[trl_app_eqcodes] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_gps_latitude] [int] NULL,
[trl_gps_longitude] [int] NULL,
[Updated_on] [datetime] NULL,
[companyID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DirectRouteTruckDetails] TO [public]
GO
GRANT INSERT ON  [dbo].[DirectRouteTruckDetails] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DirectRouteTruckDetails] TO [public]
GO
GRANT SELECT ON  [dbo].[DirectRouteTruckDetails] TO [public]
GO
GRANT UPDATE ON  [dbo].[DirectRouteTruckDetails] TO [public]
GO
