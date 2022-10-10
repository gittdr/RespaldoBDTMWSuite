CREATE TABLE [dbo].[SL_PilgrimsTMW_CatalogoClientes]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Origen] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Destino] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Compania_TMW] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Nombre_TMW] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ciudad_TMW] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DistanciaIdaVuelta] [int] NULL,
[TiempoHrs] [int] NULL,
[SalidaDePlanta] [time] NULL,
[LlegadaADestino] [time] NULL,
[TiempoDeRecorrido] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SL_PilgrimsTMW_CatalogoClientes] ADD CONSTRAINT [PK_SL_PilgrimsTMW_CatalogoClientes] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
