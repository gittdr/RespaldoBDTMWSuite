CREATE TABLE [dbo].[precio_Diesel_proyecto]
(
[id_proyecto] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[precio] [decimal] (5, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[precio_Diesel_proyecto] ADD CONSTRAINT [PK__precio_D__F38AD81D93F30962] PRIMARY KEY CLUSTERED ([id_proyecto]) ON [PRIMARY]
GO
