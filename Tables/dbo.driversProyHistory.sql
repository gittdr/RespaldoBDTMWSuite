CREATE TABLE [dbo].[driversProyHistory]
(
[consecutivo] [int] NOT NULL IDENTITY(1, 1),
[driver] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fecha] [int] NULL,
[difdias] [int] NULL,
[dias] [int] NULL,
[licencia] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lider] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ubigps] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[patio] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[region] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driverstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rango] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[califremolque] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[proyectodriver] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nombreproyecto] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prodsietedias] [smallint] NULL,
[tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[proyecto] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fechahoy] [datetime] NULL,
[equipo_colaborativo] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID_Driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
