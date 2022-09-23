CREATE TABLE [dbo].[SATCommoditiesCAT]
(
[ClaveProducto] [int] NULL,
[Descripcion] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PalabrasSimilares] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaterialPeligroso] [int] NULL
) ON [PRIMARY]
GO
