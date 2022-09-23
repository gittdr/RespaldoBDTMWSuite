CREATE TABLE [dbo].[identificador_mex_mty_mex]
(
[id_renglon] [int] NOT NULL,
[identificador] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[identificador_mex_mty_mex] ADD CONSTRAINT [pk_identmmm] PRIMARY KEY NONCLUSTERED ([id_renglon]) ON [PRIMARY]
GO
