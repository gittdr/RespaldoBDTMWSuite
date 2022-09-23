CREATE TABLE [dbo].[casetas_mex_mty_mex]
(
[id_renglon] [int] NOT NULL,
[id_caseta] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[casetas_mex_mty_mex] ADD CONSTRAINT [pk_case_mtymex] PRIMARY KEY NONCLUSTERED ([id_renglon]) ON [PRIMARY]
GO
