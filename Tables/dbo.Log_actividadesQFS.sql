CREATE TABLE [dbo].[Log_actividadesQFS]
(
[id_transaccion] [int] NOT NULL IDENTITY(1, 1),
[fecha] [datetime] NULL,
[actividad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[resultado] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[movimiento] [int] NULL,
[unidad] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Log_actividadesQFS] ADD CONSTRAINT [PK__Log_actividadesQ__0332AD28] PRIMARY KEY CLUSTERED ([id_transaccion]) ON [PRIMARY]
GO
