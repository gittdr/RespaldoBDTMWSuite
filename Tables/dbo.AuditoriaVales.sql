CREATE TABLE [dbo].[AuditoriaVales]
(
[vale] [int] NOT NULL,
[usuario] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fecha] [datetime] NOT NULL,
[actualizado] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
