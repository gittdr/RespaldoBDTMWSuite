CREATE TABLE [dbo].[actualiza_kms_sayer_log]
(
[id_consecutivo] [int] NOT NULL IDENTITY(1, 1),
[origen] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[destino] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[motivo] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[actualiza_kms_sayer_log] ADD CONSTRAINT [PK__actualiz__4F8754D1B0D73847] PRIMARY KEY CLUSTERED ([id_consecutivo]) ON [PRIMARY]
GO
