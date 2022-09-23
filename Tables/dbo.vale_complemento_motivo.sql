CREATE TABLE [dbo].[vale_complemento_motivo]
(
[id_motivo] [int] NOT NULL IDENTITY(1, 1),
[motivo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[vale_complemento_motivo] ADD CONSTRAINT [PK__vale_com__FCA2F0C8790107D0] PRIMARY KEY CLUSTERED ([id_motivo]) ON [PRIMARY]
GO
