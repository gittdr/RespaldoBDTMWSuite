CREATE TABLE [dbo].[SATUnidadesCat]
(
[ClaveUnidad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Nombre] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descripcion] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Nota] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FechaVigencias] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FechaFinvigencia] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Simbolo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Bandera] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
