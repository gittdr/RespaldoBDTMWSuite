CREATE TABLE [dbo].[TMSImportDataProperties]
(
[Id] [bigint] NOT NULL IDENTITY(1, 1),
[ImpDataId] [bigint] NOT NULL,
[RowSequence] [int] NULL,
[ColumnSequence] [int] NULL,
[Property] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Data] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSImportDataProperties] ADD CONSTRAINT [PK_TMSImportDataProperties] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_TMSImportDataProperties_ImpDataId] ON [dbo].[TMSImportDataProperties] ([ImpDataId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSImportDataProperties] ADD CONSTRAINT [FK_TMSImportDataProperties_ImpDataID] FOREIGN KEY ([ImpDataId]) REFERENCES [dbo].[TMSImportData] ([ImpDataId])
GO
GRANT DELETE ON  [dbo].[TMSImportDataProperties] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSImportDataProperties] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSImportDataProperties] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSImportDataProperties] TO [public]
GO
