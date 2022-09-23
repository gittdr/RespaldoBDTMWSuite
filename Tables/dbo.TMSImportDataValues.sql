CREATE TABLE [dbo].[TMSImportDataValues]
(
[ImpValueId] [bigint] NOT NULL IDENTITY(1, 1),
[ImpDataId] [bigint] NOT NULL,
[RowSequence] [int] NOT NULL,
[ColumnSequence] [int] NOT NULL,
[Data] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CleanData] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSImportDataValues] ADD CONSTRAINT [PK_TMSImportDataValues] PRIMARY KEY CLUSTERED ([ImpValueId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_TMSImportDataValues_ImpDataId] ON [dbo].[TMSImportDataValues] ([ImpDataId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSImportDataValues] ADD CONSTRAINT [FK_TMSImportDataValues_ImpDataID] FOREIGN KEY ([ImpDataId]) REFERENCES [dbo].[TMSImportData] ([ImpDataId])
GO
GRANT DELETE ON  [dbo].[TMSImportDataValues] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSImportDataValues] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSImportDataValues] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSImportDataValues] TO [public]
GO
