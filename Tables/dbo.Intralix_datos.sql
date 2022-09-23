CREATE TABLE [dbo].[Intralix_datos]
(
[unidad] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[eventos] [int] NULL,
[lts_cargados] [int] NULL,
[lts_consumidos] [int] NULL,
[kms_recorridos] [int] NULL,
[rend_intralix] [float] NULL,
[aniosemana] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Intralix_datos] ADD CONSTRAINT [PK__Intralix__6BC2DB7F3180AA1F] PRIMARY KEY CLUSTERED ([unidad], [aniosemana]) ON [PRIMARY]
GO
