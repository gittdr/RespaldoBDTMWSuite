CREATE TABLE [dbo].[tts_bs_mc]
(
[Proyecto] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Operador] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cliente] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ordenes] [int] NULL,
[Monto] [float] NULL,
[Lag] [int] NULL,
[5Count] [int] NULL,
[5Monto] [float] NULL,
[5Perc] [float] NULL,
[5Lag] [int] NULL,
[regresadas5] [int] NULL,
[mas5Count] [int] NULL,
[mas5Monto] [float] NULL,
[mas5Perc] [float] NULL,
[mas5Lag] [int] NULL,
[regresadasmas5] [int] NULL,
[ord_EC] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
