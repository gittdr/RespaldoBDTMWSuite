CREATE TABLE [dbo].[tblMsgEmail]
(
[IdEnvio] [int] NOT NULL IDENTITY(1, 1),
[SNEnviado] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FechaEnvio] [datetime] NULL CONSTRAINT [DF_tblMsgEmail_FechaEnvio] DEFAULT (getdate())
) ON [PRIMARY]
GO
