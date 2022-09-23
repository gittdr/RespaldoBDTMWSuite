CREATE TABLE [dbo].[liverReportUbicacion]
(
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fecha] [date] NULL,
[hora] [int] NULL,
[trc_gps_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lat] [decimal] (16, 4) NULL,
[long] [decimal] (16, 4) NULL
) ON [PRIMARY]
GO
