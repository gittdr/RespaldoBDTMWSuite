CREATE TABLE [dbo].[tti_gls_data]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[DeviceID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTData] [datetime] NULL,
[AssetID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventSource] [int] NULL,
[Latitude] [decimal] (11, 8) NULL,
[Longitude] [decimal] (11, 8) NULL,
[Quality] [int] NULL,
[PowerStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Landmark] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IdleStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IdleDuration] [decimal] (8, 3) NULL,
[IdleGap] [decimal] (8, 3) NULL,
[DTCreated] [datetime] NULL
) ON [PRIMARY]
GO
