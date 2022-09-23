CREATE TABLE [dbo].[RMXML_DOTTestingInfo]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[VehicleOOS] [int] NULL,
[DriverOOS] [int] NULL,
[HazmatOOS] [int] NULL,
[SafetyRatingDate] [datetime] NULL,
[SafetyRating] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SafetyReviewDate] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SafetyReviewType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DriverSEA] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleSEA] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SafetyManagementSEA] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalTrucks] [int] NULL,
[TotalAccidents] [int] NULL,
[Ratio] [money] NULL,
[OperatingStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OutOfServiceDate] [datetime] NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_DOT__lastu__295EE292] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_DOT__lastu__2A5306CB] DEFAULT (suser_sname()),
[Tot_Trucks] [int] NULL,
[Tot_Pwr] [int] NULL,
[OriginalAuthorityGrantDate] [datetime] NULL,
[LatestAuthorityGrantDate] [datetime] NULL,
[LatestAuthorityReinstatedDate] [datetime] NULL,
[Safer_ActiveInactiveStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Safer_ActiveInactiveLastCheckedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_DOTTestingInfo] ADD CONSTRAINT [pk_rmxml_dottestinginfo] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_DOTTestingInfo_LastUpdateDate] ON [dbo].[RMXML_DOTTestingInfo] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_DOTTestingInfo_TmwXmlImportLog_id] ON [dbo].[RMXML_DOTTestingInfo] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_DOTTestingInfo] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_DOTTestingInfo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_DOTTestingInfo] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_DOTTestingInfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_DOTTestingInfo] TO [public]
GO
