CREATE TABLE [dbo].[detail_check]
(
[idCheck] [int] NOT NULL,
[idOrden] [int] NULL,
[idReferencia] [int] NULL,
[Accion] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usuario] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[f_elaboracion] [datetime] NULL,
[amountSilt] [float] NULL,
[amountTmw] [float] NULL,
[idMovimiento] [int] NULL,
[operador] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
