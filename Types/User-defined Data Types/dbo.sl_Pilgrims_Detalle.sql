CREATE TYPE [dbo].[sl_Pilgrims_Detalle] AS TABLE
(
[Descripcion] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Peso] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cantidad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unidad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pedido_Id] [int] NOT NULL,
[Material] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
