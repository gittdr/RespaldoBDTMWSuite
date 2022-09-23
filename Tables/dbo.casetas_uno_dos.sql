CREATE TABLE [dbo].[casetas_uno_dos]
(
[id_renglon] [int] NOT NULL,
[id_caseta1_2] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[casetas_uno_dos] ADD CONSTRAINT [pk_kz_1_2] PRIMARY KEY NONCLUSTERED ([id_renglon]) ON [PRIMARY]
GO
