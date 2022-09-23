CREATE TABLE [dbo].[Sl_Pilgrims_Bitacora_Lgh_Number]
(
[lgh_number] [int] NOT NULL,
[valeplastico1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fleje1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[valeplastico2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fleje2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[flejeSagarpa1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[flejeSagarpa2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InicialHT1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FinalHT1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrabajadasHT1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InicialLT1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FinalLT1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsumoLT1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rendimiento1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InicialHT2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FinalHT2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrabajadasHT2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InicialLT2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FinalLT2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsumoLT2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rendimiento2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramadaTemp2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalidaPlanta2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ruta2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cliente2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramadaTemp1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalidaPlanta1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ruta1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cliente1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Observaciones] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sl_Pilgrims_Bitacora_Lgh_Number] ADD CONSTRAINT [PK_Sl_Pilgrims_Bitacora_Lgh_Number] PRIMARY KEY CLUSTERED ([lgh_number]) ON [PRIMARY]
GO
