CREATE TABLE [dbo].[TipoUsuario]
(
[IIDTIPOUSUARIO] [int] NOT NULL IDENTITY(1, 1),
[NOMBRE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESCRIPCION] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BHABILITADO] [int] NULL
) ON [PRIMARY]
GO
