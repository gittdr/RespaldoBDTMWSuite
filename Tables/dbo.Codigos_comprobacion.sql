CREATE TABLE [dbo].[Codigos_comprobacion]
(
[id_codigo] [int] NOT NULL,
[descripcion] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TipoAtribucion] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Codigos_comprobacion] ADD CONSTRAINT [PK__Codigos___F32CBC520D3F97A2] PRIMARY KEY CLUSTERED ([id_codigo]) ON [PRIMARY]
GO
