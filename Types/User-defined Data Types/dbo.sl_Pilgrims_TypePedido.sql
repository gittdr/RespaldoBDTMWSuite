CREATE TYPE [dbo].[sl_Pilgrims_TypePedido] AS TABLE
(
[Pedido_Id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Entrega] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Factura] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client_Id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
