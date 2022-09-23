CREATE TABLE [dbo].[Sl_Pilgrims_Detalle]
(
[IdMaterial] [int] NOT NULL IDENTITY(1, 1),
[Descripcion] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Peso] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cantidad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unidad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pedido_Id] [int] NOT NULL,
[Material] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Unidad_Peso] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sl_Pilgrims_Detalle] ADD CONSTRAINT [PK_Sl_Pilgrims_Detalle] PRIMARY KEY CLUSTERED ([IdMaterial]) ON [PRIMARY]
GO
