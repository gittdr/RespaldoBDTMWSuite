CREATE TABLE [dbo].[Tablakmsbardahl]
(
[id_renglon] [int] NOT NULL IDENTITY(1, 1),
[Compania_O] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id_ciudad_O] [int] NULL,
[nom_cd_O] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Edo_O] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Compania_D] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id_ciudad_D] [int] NULL,
[nom_cd_D] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Edo_D] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Tablakmsbardahl] ADD CONSTRAINT [PK__Tablakmsbardahl__7BC6958A] PRIMARY KEY CLUSTERED ([id_renglon]) ON [PRIMARY]
GO
