CREATE TABLE [dbo].[QHOSDriverLogExportData]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[DriverID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CoDriverID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartTime] [datetime] NOT NULL,
[Activity] [int] NOT NULL,
[Duration] [int] NOT NULL,
[Location] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Document] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TractorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrailerID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Confirmed] [int] NULL,
[Edit] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SensorFailure] [int] NULL,
[TimeZone] [int] NOT NULL,
[UpdatedOn] [datetime] NOT NULL,
[LocalStartTime] [datetime] NOT NULL,
[LocalTimeZone] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[QHOSDriverLogExportData] ADD CONSTRAINT [PK_QHOSDriverLogExportData] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[QHOSDriverLogExportData] TO [public]
GO
GRANT INSERT ON  [dbo].[QHOSDriverLogExportData] TO [public]
GO
GRANT REFERENCES ON  [dbo].[QHOSDriverLogExportData] TO [public]
GO
GRANT SELECT ON  [dbo].[QHOSDriverLogExportData] TO [public]
GO
GRANT UPDATE ON  [dbo].[QHOSDriverLogExportData] TO [public]
GO
