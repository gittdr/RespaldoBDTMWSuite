CREATE TABLE [dbo].[CSA_DriverBasics]
(
[drv_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UnsafeDriving_Factor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UnsafeDriving_Rank] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ControlledSubstances_Factor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ControlledSubstances_Rank] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FatiguedDriving_Factor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FatiguedDriving_Rank] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DriverFitness_Factor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DriverFitness_Rank] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VehicleMaintenance_Factor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VehicleMaintenance_Rank] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CargoRelated_Factor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CargoRelated_Rank] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AsOfDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[CSA_DriverBasics] TO [public]
GO
GRANT SELECT ON  [dbo].[CSA_DriverBasics] TO [public]
GO
GRANT UPDATE ON  [dbo].[CSA_DriverBasics] TO [public]
GO
