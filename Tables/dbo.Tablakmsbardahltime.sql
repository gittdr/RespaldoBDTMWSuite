CREATE TABLE [dbo].[Tablakmsbardahltime]
(
[id_renglon] [int] NOT NULL IDENTITY(1, 1),
[id_ciudad_O] [int] NULL,
[id_ciudad_D] [int] NULL,
[Kms] [int] NULL,
[Hras] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Tablakmsbardahltime] ADD CONSTRAINT [PK__Tablakmsbardahlt__7EA30235] PRIMARY KEY CLUSTERED ([id_renglon]) ON [PRIMARY]
GO
