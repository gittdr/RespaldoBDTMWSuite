CREATE TABLE [dbo].[consecutivo_ruta1_2]
(
[id_renglon] [int] NOT NULL,
[id_ident_ruta1_2] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[consecutivo_ruta1_2] ADD CONSTRAINT [pk_ident_ruta] PRIMARY KEY NONCLUSTERED ([id_renglon]) ON [PRIMARY]
GO
