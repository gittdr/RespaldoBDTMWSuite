CREATE TABLE [dbo].[DriverAwareSuite_DrivingHourByGPSResults]
(
[DriverID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GPSInfoStale] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsTeam] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GPSLastFullBreakEndDt] [datetime] NULL,
[HoursOnBreakCurrently] [decimal] (6, 2) NULL,
[CurrentBreakStart] [datetime] NULL,
[BreakCouldEndCurrentlyHrs] [float] NULL,
[BreakCouldEndCurrentlyDt] [datetime] NULL,
[DrivingOrNonBreakHrsSinceLastFullBreak] [float] NULL,
[MaxDrvHrsTillBreak] [float] NULL,
[DrivingMustStopByDT] [datetime] NULL,
[ContiniousDrvHrsSinceLastStop] [decimal] (6, 2) NULL,
[LastGPSFound] [datetime] NULL,
[GPSCalculatedDriverHrsForMaxGPSDt] [decimal] (10, 1) NULL,
[GPSCalculatedAirMilesForMaxGPSDt] [decimal] (10, 1) NULL,
[GPSCalculatedDriverHrsForMaxGPSDtMinus1Day] [decimal] (10, 1) NULL,
[GPSCalculatedAirMilesForMaxGPSDtMinus1Day] [decimal] (10, 1) NULL,
[GPSCalculatedDriverHrsForMaxGPSDtMinus2Day] [decimal] (10, 1) NULL,
[GPSCalculatedAirMilesForMaxGPSDtMinus2Day] [decimal] (10, 1) NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DriverAwareSuite_DrivingHourByGPSResults] TO [public]
GO
GRANT INSERT ON  [dbo].[DriverAwareSuite_DrivingHourByGPSResults] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DriverAwareSuite_DrivingHourByGPSResults] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverAwareSuite_DrivingHourByGPSResults] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverAwareSuite_DrivingHourByGPSResults] TO [public]
GO
