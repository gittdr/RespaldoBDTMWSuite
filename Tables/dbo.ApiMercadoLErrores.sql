CREATE TABLE [dbo].[ApiMercadoLErrores]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Shipment_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fecha] [datetime] NULL CONSTRAINT [DF__ApiMercad__fecha__4AC2C991] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ApiMercadoLErrores] ADD CONSTRAINT [PK__ApiMerca__3213E83F6DBD1CB9] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
