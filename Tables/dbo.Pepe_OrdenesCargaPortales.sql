CREATE TABLE [dbo].[Pepe_OrdenesCargaPortales]
(
[IdOrdenCargaPepe] [int] NOT NULL IDENTITY(1, 1),
[Orden] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billto] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Estado] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FechaCarga] [datetime] NULL CONSTRAINT [DF_Pepe_OrdenesCargaPortales_FechaCarga] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Pepe_OrdenesCargaPortales] ADD CONSTRAINT [PK_Pepe_OrdenesCargaPortales] PRIMARY KEY CLUSTERED ([IdOrdenCargaPepe]) ON [PRIMARY]
GO
