CREATE TABLE [dbo].[Sl_Pilgrims_Cliente]
(
[Client_Id] [int] NOT NULL,
[IdClient] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FechaEntregaMin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FechaEntregaMax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Embarque_Id] [int] NULL,
[ClienteDescripcion] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Distancia] [decimal] (18, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sl_Pilgrims_Cliente] ADD CONSTRAINT [PK_Cliente] PRIMARY KEY CLUSTERED ([Client_Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sl_Pilgrims_Cliente] ADD CONSTRAINT [FK_Sl_Pilgrims_Cliente_Sl_Pilgrims_Embarque] FOREIGN KEY ([Embarque_Id]) REFERENCES [dbo].[Sl_Pilgrims_Embarque] ([Embarque_Id])
GO
