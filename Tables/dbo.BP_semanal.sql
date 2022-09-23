CREATE TABLE [dbo].[BP_semanal]
(
[Renglon] [int] NOT NULL,
[Dedicadosem] [decimal] (10, 2) NULL,
[Especialsem] [decimal] (10, 2) NULL,
[Abiertosem] [decimal] (10, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BP_semanal] ADD CONSTRAINT [pk_bpseman] PRIMARY KEY CLUSTERED ([Renglon]) ON [PRIMARY]
GO
