CREATE TABLE [dbo].[tts_bs_dispo_detail]
(
[Cliente] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Origen] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Destino] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remolque] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Proyecto] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Region] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tractor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Operador] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrdStatus] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fecha] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fechaf] [datetime] NULL,
[CiudadOrigen] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CiudadDestino] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orden] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Leg] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lider] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
