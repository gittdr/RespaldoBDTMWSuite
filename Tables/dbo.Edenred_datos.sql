CREATE TABLE [dbo].[Edenred_datos]
(
[unidad] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[comprobante] [int] NULL,
[fecha] [datetime] NOT NULL,
[kms_anteriores] [int] NULL,
[kms_transaccion] [int] NULL,
[kms_recorridos] [int] NULL,
[rend_edenred] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Edenred_datos] ADD CONSTRAINT [PK__Edenred___77C6D708D7B4DAD9] PRIMARY KEY CLUSTERED ([unidad], [fecha]) ON [PRIMARY]
GO
