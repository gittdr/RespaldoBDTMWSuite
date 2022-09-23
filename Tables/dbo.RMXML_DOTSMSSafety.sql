CREATE TABLE [dbo].[RMXML_DOTSMSSafety]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[dotSmsSafety_USDotNumber] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_InspTotal] [int] NULL,
[dotSmsSafety_DriverInspTotal] [int] NULL,
[dotSmsSafety_DriverOosInspTotal] [int] NULL,
[dotSmsSafety_VehicleInspTotal] [int] NULL,
[dotSmsSafety_VehicleOosInspTotal] [int] NULL,
[dotSmsSafety_UnsafeDrivingPercentile] [decimal] (8, 4) NULL,
[dotSmsSafety_UnsafeDrivingRoadsideAlert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_UnsafeDrivingSeriousViolation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_UnsafeDrivingBasicAlert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_FatiguedDrivingPercentile] [decimal] (8, 4) NULL,
[dotSmsSafety_FatiguedUnsafeDrivingRoadsideAlert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_FatiguedDrivingSeriousViolation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_FatiguedDrivingBasicAlert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_DriverFitnessPercentile] [decimal] (8, 4) NULL,
[dotSmsSafety_DriverFitnessDrivingRoadsideAlert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_DriverFitnessSeriousViolation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_DriverFitnessBasicAlert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_ControlledSubstancePercentile] [decimal] (8, 4) NULL,
[dotSmsSafety_ControlledSubstanceRoadsideAlert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_ControlledSubstanceSeriousViolation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_ControlledSubstanceBasicAlert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_VehicleMaintPercentile] [decimal] (8, 4) NULL,
[dotSmsSafety_VehicleMaintRoadsideAlert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_VehicleMaintSeriousViolation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_VehicleMaintBasicAlert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotSmsSafety_UpdateDate] [datetime] NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_DOT__lastu__2D2F7376] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_DOT__lastu__2E2397AF] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_DOTSMSSafety] ADD CONSTRAINT [pk_rmxml_dotsmssafety] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_DOTSMSSafety_LastUpdateDate] ON [dbo].[RMXML_DOTSMSSafety] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_DOTSMSSafety_TmwXmlImportLog_id] ON [dbo].[RMXML_DOTSMSSafety] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_DOTSMSSafety] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_DOTSMSSafety] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_DOTSMSSafety] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_DOTSMSSafety] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_DOTSMSSafety] TO [public]
GO
