CREATE TABLE [dbo].[Convoy_EnviarViajeFinalizado]
(
[IdEnvioFinalizado] [int] NOT NULL IDENTITY(1, 1),
[Referencia] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EnviarViajeFinalizado_Referencia] DEFAULT (getdate()),
[fecha] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Convoy_EnviarViajeFinalizado] ADD CONSTRAINT [PK_EnviarViajeFinalizado] PRIMARY KEY CLUSTERED ([IdEnvioFinalizado]) ON [PRIMARY]
GO
