CREATE TABLE [dbo].[Registro_Cambio_MB]
(
[id_renglon] [int] NOT NULL IDENTITY(1, 1),
[orden] [int] NULL,
[MBAnterior] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBNueva] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Registro_Cambio_MB] ADD CONSTRAINT [PK__Registro__2B5B86D44597AF9F] PRIMARY KEY CLUSTERED ([id_renglon]) ON [PRIMARY]
GO
