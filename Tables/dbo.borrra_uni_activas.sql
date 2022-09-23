CREATE TABLE [dbo].[borrra_uni_activas]
(
[id_unidad] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[marca] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tipo] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[flota] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mctnumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id_operador] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[borrra_uni_activas] ADD CONSTRAINT [borrar_mttouni] PRIMARY KEY NONCLUSTERED ([id_unidad]) ON [PRIMARY]
GO
