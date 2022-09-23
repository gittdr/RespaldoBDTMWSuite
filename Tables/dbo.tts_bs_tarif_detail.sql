CREATE TABLE [dbo].[tts_bs_tarif_detail]
(
[Cliente] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Origen] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CiudadOrigen] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Destino] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CiudadDestino] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orden] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TarifLag] [int] NULL,
[Fecha] [datetime] NULL,
[Error] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorDesc] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorNote] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorNoteType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
