CREATE TABLE [dbo].[tmw_orden_dif_litros]
(
[id_renglon] [int] NOT NULL IDENTITY(1, 1),
[no_orden] [int] NULL,
[no_movimiento] [int] NULL,
[id_usuario] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id_operador] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[diferencia] [int] NULL,
[estatus] [int] NULL,
[fecha] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tmw_orden_dif_litros] ADD CONSTRAINT [pk_ordendif_litros] PRIMARY KEY NONCLUSTERED ([id_renglon]) ON [PRIMARY]
GO
