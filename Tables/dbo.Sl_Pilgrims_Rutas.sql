CREATE TABLE [dbo].[Sl_Pilgrims_Rutas]
(
[IdRutas] [int] NOT NULL IDENTITY(1, 1),
[ruta] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[origen] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[destino] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clientes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cargado] [int] NULL,
[Cajas] [int] NULL,
[CargaTon] [decimal] (18, 2) NULL,
[CajasDetalle] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PesoDetalle] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FacturaDetalle] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClienteDescripcion] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cajas2] [int] NULL,
[CargaTon2] [decimal] (18, 2) NULL,
[Dolly] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sellos] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Operador] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sellos2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ValePlastico] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlejePlastico] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ValePlastico2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlejePlastico2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remolque1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remolque2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remisiones1] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remisiones2] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CajasDetalle2] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PesoDetalle2] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FacturaDetalle2] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClienteDescripcion2] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[idBitacora] [int] NULL,
[FlagInsert] [int] NULL,
[EnviadoSap] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[insertaBitacora]  
ON  [dbo].[Sl_Pilgrims_Rutas]
AFTER INSERT
AS  
update [dbo].[Sl_Pilgrims_Rutas]
set [idBitacora] = (Select max([idBitacora])+1 from [dbo].[Sl_Pilgrims_Rutas]
							where origen = (Select origen from [dbo].[Sl_Pilgrims_Rutas] where [FlagInsert] = 1)),
[FlagInsert]= null
where ruta = (Select ruta from [dbo].[Sl_Pilgrims_Rutas] where [FlagInsert] = 1)
  
GO
ALTER TABLE [dbo].[Sl_Pilgrims_Rutas] ADD CONSTRAINT [PK_Sl_Pilgrims_Rutas] PRIMARY KEY CLUSTERED ([IdRutas]) ON [PRIMARY]
GO
