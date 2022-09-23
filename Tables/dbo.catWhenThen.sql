CREATE TABLE [dbo].[catWhenThen]
(
[iIdCatalogo] [int] NOT NULL,
[cWhen] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cThen] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[iStatus] [int] NOT NULL,
[dLastMod] [datetime] NOT NULL,
[CodigoSat] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NombreUnidad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnidadSat] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[catWhenThen] ADD CONSTRAINT [PK_catWhenThen] PRIMARY KEY CLUSTERED ([iIdCatalogo], [cWhen]) ON [PRIMARY]
GO
