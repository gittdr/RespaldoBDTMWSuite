CREATE TABLE [dbo].[BusinessPlan]
(
[fechaIni] [datetime] NULL,
[fechaFin] [datetime] NULL,
[anio] [int] NULL,
[semana] [int] NULL,
[proyecto] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[revenue] [float] NULL,
[kmTotales] [int] NULL,
[kmVacios] [int] NULL,
[ordenes] [int] NULL
) ON [PRIMARY]
GO
