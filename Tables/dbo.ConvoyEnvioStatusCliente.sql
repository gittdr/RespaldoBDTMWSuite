CREATE TABLE [dbo].[ConvoyEnvioStatusCliente]
(
[IdEnvioStatus] [int] NOT NULL IDENTITY(1, 1),
[Billto] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Correos] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fechaDesde] [datetime] NULL CONSTRAINT [DF_ConvoyEnvioStatusCliente_fechaDesde] DEFAULT (getdate()),
[fechaHasta] [datetime] NULL,
[Activo] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Origenes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Destino] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefType] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Asunto] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AutorizoNombre] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Correo] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
