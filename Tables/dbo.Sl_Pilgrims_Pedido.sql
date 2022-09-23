CREATE TABLE [dbo].[Sl_Pilgrims_Pedido]
(
[Pedido_Id] [int] NOT NULL,
[Entrega] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Factura] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client_Id] [int] NULL,
[Secuencia] [int] NULL,
[LugarEntrega] [int] NULL,
[Domicilio] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ciudad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Estado] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pais] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Destino] [int] NULL,
[Caja] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sl_Pilgrims_Pedido] ADD CONSTRAINT [FK_Sl_Pilgrims_Pedido_Sl_Pilgrims_Cliente] FOREIGN KEY ([Client_Id]) REFERENCES [dbo].[Sl_Pilgrims_Cliente] ([Client_Id])
GO
