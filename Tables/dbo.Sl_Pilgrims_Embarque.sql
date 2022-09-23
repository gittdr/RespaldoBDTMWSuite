CREATE TABLE [dbo].[Sl_Pilgrims_Embarque]
(
[Embarque_Id] [int] NOT NULL,
[Ruta] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Origen] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Destino] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TipoUnidad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Proveedor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlantaPago] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fecha] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comentarios] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remolque] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TipoViaje] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Peso] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnidadPiezas] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CantidadPiezas] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tractor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remolques] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RutaNombre] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Distribuidor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IdOrigen] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IdDestino] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Dolly] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sellos] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Operador] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sellos2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ValePlastico] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlejePlastico] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ValePlastico2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlejePlastico2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sl_Pilgrims_Embarque] ADD CONSTRAINT [PK_Embarque] PRIMARY KEY CLUSTERED ([Embarque_Id]) ON [PRIMARY]
GO
