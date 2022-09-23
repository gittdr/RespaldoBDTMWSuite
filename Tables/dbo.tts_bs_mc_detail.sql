CREATE TABLE [dbo].[tts_bs_mc_detail]
(
[Proyecto] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Operador] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cliente] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orden] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fecha] [datetime] NULL,
[IndexLag] [int] NULL,
[Estatus] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Factura] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Master] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Referencias] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EstatusFactura] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MontoFactura] [float] NULL,
[Evidencias] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EvidenciasFaltan] [int] NULL,
[ReferenciasFaltan] [int] NULL,
[NoCalc] [int] NULL,
[Regresada] [int] NULL
) ON [PRIMARY]
GO
