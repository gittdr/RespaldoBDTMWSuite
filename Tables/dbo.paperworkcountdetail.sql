CREATE TABLE [dbo].[paperworkcountdetail]
(
[Cliente] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orden] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FechaFin] [datetime] NULL,
[Lag] [int] NULL,
[Revenue] [float] NULL,
[Evidencias] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
