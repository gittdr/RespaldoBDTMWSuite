CREATE TABLE [dbo].[comentarios_cfdi_jr]
(
[cc_consecutivo] [int] NOT NULL IDENTITY(1, 1),
[cc_ord_hdrnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_comentarios] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[comentarios_cfdi_jr] ADD CONSTRAINT [PK__comentar__E2814E4F0D4BAD88] PRIMARY KEY CLUSTERED ([cc_consecutivo]) ON [PRIMARY]
GO
