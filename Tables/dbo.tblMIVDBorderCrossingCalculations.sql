CREATE TABLE [dbo].[tblMIVDBorderCrossingCalculations]
(
[lgh_Number] [int] NOT NULL,
[DriverID] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ckc_number] [int] NOT NULL,
[last_airmiles_calculated] [float] NULL,
[ckc_latseconds] [int] NOT NULL,
[ckc_longseconds] [int] NOT NULL,
[border_stop_latseconds] [int] NULL,
[border_stop_longseconds] [int] NULL,
[ckc_updatedon] [datetime] NOT NULL,
[updatedon] [datetime] NOT NULL,
[CompletedDelayAfterActualizedLastStop_BeforeMeatInspection] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMIVDBorderCrossingCalculations] ADD CONSTRAINT [PK_tblMIVDBorderCrossingCalculations] PRIMARY KEY CLUSTERED ([lgh_Number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblMIVDBorderCrossingCalculations] TO [public]
GO
GRANT INSERT ON  [dbo].[tblMIVDBorderCrossingCalculations] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblMIVDBorderCrossingCalculations] TO [public]
GO
GRANT SELECT ON  [dbo].[tblMIVDBorderCrossingCalculations] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblMIVDBorderCrossingCalculations] TO [public]
GO
