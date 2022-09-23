CREATE TABLE [dbo].[operadorKmsxDia_jr]
(
[consecutivo] [int] NOT NULL IDENTITY(1, 1),
[Id_operador] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[kms] [smallint] NULL,
[dia_hoy] [date] NULL,
[dia] [int] NULL,
[semana] [int] NULL,
[mes] [int] NULL
) ON [PRIMARY]
GO
