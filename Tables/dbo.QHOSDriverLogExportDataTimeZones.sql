CREATE TABLE [dbo].[QHOSDriverLogExportDataTimeZones]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Offset] [float] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[QHOSDriverLogExportDataTimeZones] ADD CONSTRAINT [PK_QHOSDriverLogExportDataTimeZones] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[QHOSDriverLogExportDataTimeZones] TO [public]
GO
GRANT INSERT ON  [dbo].[QHOSDriverLogExportDataTimeZones] TO [public]
GO
GRANT REFERENCES ON  [dbo].[QHOSDriverLogExportDataTimeZones] TO [public]
GO
GRANT SELECT ON  [dbo].[QHOSDriverLogExportDataTimeZones] TO [public]
GO
GRANT UPDATE ON  [dbo].[QHOSDriverLogExportDataTimeZones] TO [public]
GO
