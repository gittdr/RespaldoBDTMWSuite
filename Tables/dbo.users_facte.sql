CREATE TABLE [dbo].[users_facte]
(
[iduser] [decimal] (18, 0) NOT NULL IDENTITY(1, 1),
[usuario] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[contrasena] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[admin] [int] NOT NULL
) ON [PRIMARY]
GO
