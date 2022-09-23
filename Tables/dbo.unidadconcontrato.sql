CREATE TABLE [dbo].[unidadconcontrato]
(
[renglon] [int] NOT NULL,
[noserie] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nocontrato] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[unidadconcontrato] ADD CONSTRAINT [pk_unidadcon] PRIMARY KEY NONCLUSTERED ([renglon]) ON [PRIMARY]
GO
