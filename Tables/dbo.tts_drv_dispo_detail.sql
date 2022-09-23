CREATE TABLE [dbo].[tts_drv_dispo_detail]
(
[Cliente] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Origen] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Destino] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remolque] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Proyecto] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Region] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tractor] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Operador] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrdStatus] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fecha] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fechaf] [datetime] NULL,
[Fechat] [datetime] NULL,
[CiudadOrigen] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CiudadDestino] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orden] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Leg] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lider] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProyDrv] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
