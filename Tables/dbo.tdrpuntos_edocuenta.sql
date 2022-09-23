CREATE TABLE [dbo].[tdrpuntos_edocuenta]
(
[IDUsuario] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fechatransac] [datetime] NULL,
[PuntajeInicial] [smallint] NULL,
[Movimiento] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Puntos] [smallint] NULL,
[Concepto] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PuntajeFinal] [smallint] NULL
) ON [PRIMARY]
GO
