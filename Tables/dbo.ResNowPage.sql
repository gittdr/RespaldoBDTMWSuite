CREATE TABLE [dbo].[ResNowPage]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[MenuSectionSN] [int] NOT NULL,
[Active] [int] NOT NULL CONSTRAINT [DF__ResNowPag__Activ__069929B8] DEFAULT ((1)),
[Sort] [int] NOT NULL CONSTRAINT [DF__ResNowPage__Sort__078D4DF1] DEFAULT ((0)),
[ShowTime] [int] NOT NULL CONSTRAINT [DF__ResNowPag__ShowT__0881722A] DEFAULT ((4)),
[Caption] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PageURL] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaptionFull] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PagePassword] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__ResNowPag__PageP__09759663] DEFAULT (''),
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PageType] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CategoryCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MetricCategorySN] [int] NULL,
[PiePage] [int] NULL,
[SubDirectory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TruckMapLat] [int] NULL,
[TruckMapLon] [int] NULL,
[TruckMapFactor] [int] NULL,
[MetricShowcased] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DetailMetric] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DetailDate] [datetime] NULL,
[CurDetailDate] [datetime] NULL,
[ForcedGraph] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ForcedDetail] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispMode] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DetailID] [int] NULL,
[DetailFileName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeFrame] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[selTimeFrame] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[txtTimeUnitsBack] [int] NULL,
[MapType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MapWidth] [int] NULL,
[MapHeight] [int] NULL,
[JavaScriptFunctionName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BoundaryFileName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[ShowDetail] [int] NULL,
[PrimaryIDColumn] [int] NULL,
[SecondaryIDColumn] [int] NULL,
[PostDataColumns] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VariableColumns] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColorNumberColumn] [int] NULL,
[OutputFolder] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServerURL] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveDate] [datetime] NULL,
[ExpirationDate] [datetime] NULL,
[ProcessInterval] [datetime] NULL,
[Chart1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Chart2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Chart3] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Chart4] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportCardMenuSN] [int] NULL,
[GraphCompare_DateOrderLeftToRight] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNowPage] ADD CONSTRAINT [PK__ResNowPage__05A5057F] PRIMARY KEY NONCLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNowPage] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNowPage] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ResNowPage] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNowPage] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNowPage] TO [public]
GO
