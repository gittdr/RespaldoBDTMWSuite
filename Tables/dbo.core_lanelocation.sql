CREATE TABLE [dbo].[core_lanelocation]
(
[lanelocationid] [int] NOT NULL IDENTITY(1, 1),
[laneid] [int] NOT NULL,
[IsOrigin] [smallint] NULL,
[type] [int] NULL,
[countrycode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stateabbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[county] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cityname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[citycode] [int] NULL,
[zippart] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[companyid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[specificitycode] [int] NULL,
[timestamp] [timestamp] NOT NULL,
[updatedt] [datetime] NOT NULL CONSTRAINT [DF_core_LaneLocation_Updated] DEFAULT (getdate()),
[radius] [smallint] NULL,
[RegionId] [int] NULL,
[DestLanelocationId] [int] NULL,
[PostalCodePattern] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LaneRateMatrixId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_lanelocation] ADD CONSTRAINT [pk_core_lanelocation_lanelocationid] PRIMARY KEY CLUSTERED ([lanelocationid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_core_lanelocation_isorigin_type_stateabbr_lane] ON [dbo].[core_lanelocation] ([IsOrigin], [type], [stateabbr], [laneid]) INCLUDE ([zippart]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_core_lanelocation_laneid] ON [dbo].[core_lanelocation] ([laneid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_lanelocation] ADD CONSTRAINT [FK_core_lanelocation_core_lanelocation] FOREIGN KEY ([DestLanelocationId]) REFERENCES [dbo].[core_lanelocation] ([lanelocationid])
GO
ALTER TABLE [dbo].[core_lanelocation] ADD CONSTRAINT [FK_core_lanelocation_core_laneregion] FOREIGN KEY ([RegionId]) REFERENCES [dbo].[core_laneregion] ([RegionId]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[core_lanelocation] TO [public]
GO
GRANT INSERT ON  [dbo].[core_lanelocation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[core_lanelocation] TO [public]
GO
GRANT SELECT ON  [dbo].[core_lanelocation] TO [public]
GO
GRANT UPDATE ON  [dbo].[core_lanelocation] TO [public]
GO
