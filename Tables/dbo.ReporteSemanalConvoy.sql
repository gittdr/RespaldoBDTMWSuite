CREATE TABLE [dbo].[ReporteSemanalConvoy]
(
[id_reporteSemanal] [int] NOT NULL IDENTITY(1, 1),
[fecha] [datetime] NULL,
[regional] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[revtype2_tmw] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[oficios_turnados] [int] NULL,
[oficios_dictaminados] [int] NULL,
[operativos_programados] [int] NULL,
[operativos_realizados] [int] NULL,
[estrategias_presentadas] [int] NULL,
[STA] [decimal] (18, 0) NULL,
[VXP] [decimal] (18, 0) NULL,
[VXR] [decimal] (18, 0) NULL
) ON [PRIMARY]
GO
