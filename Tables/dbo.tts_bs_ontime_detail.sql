CREATE TABLE [dbo].[tts_bs_ontime_detail]
(
[Cliente] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Proyecto] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Locacion] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mapa] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETA] [datetime] NULL,
[Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Dif] [int] NULL,
[StopStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Arrival] [datetime] NULL,
[Schedule] [datetime] NULL,
[Fecha] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orden] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Stops] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Secuencia] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tractor] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mov] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lider] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Operador] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Trailer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[referencia] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[causanocalc] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
