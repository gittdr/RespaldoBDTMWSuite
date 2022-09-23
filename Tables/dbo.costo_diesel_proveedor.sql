CREATE TABLE [dbo].[costo_diesel_proveedor]
(
[diesel_renglon] [int] NOT NULL,
[diesel_unidad] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[diesel_viaje] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[diesel_fecha] [datetime] NULL,
[diesel_costo] [decimal] (10, 2) NULL
) ON [PRIMARY]
GO
