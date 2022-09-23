CREATE TABLE [dbo].[Acrual_proyecto]
(
[id_acrual] [int] NOT NULL IDENTITY(1, 1),
[id_proyecto] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nombre_proyecto] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Estructura_cont] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Acrual_proyecto] ADD CONSTRAINT [PK__Acrual_proyecto__577E481C] PRIMARY KEY CLUSTERED ([id_acrual]) ON [PRIMARY]
GO
