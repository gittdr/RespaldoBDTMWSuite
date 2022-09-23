CREATE TYPE [dbo].[sl_Pilgrims_Mercancia] AS TABLE
(
[BienesTransp] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cantidad_Tipo] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CantidadItem] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaveUnidad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CveMaterialPeligroso] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descripcion] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DescripcionEmbalaje] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaterialPeligroso] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PesoEnKg] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Traslado_Id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
