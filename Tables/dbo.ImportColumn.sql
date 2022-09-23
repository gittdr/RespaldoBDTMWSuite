CREATE TABLE [dbo].[ImportColumn]
(
[ImportColumnId] [int] NOT NULL IDENTITY(1, 1),
[ImportDefinitionId] [int] NOT NULL,
[Name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ImportDataTypeId] [int] NOT NULL,
[IsActive] [bit] NOT NULL CONSTRAINT [dk_ImportColumn_IsActive] DEFAULT ((1)),
[Sequence] [int] NULL,
[ExtraInfoColumnId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportColumn] ADD CONSTRAINT [PK_ImportColumn] PRIMARY KEY CLUSTERED ([ImportColumnId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ImportColumn_ImportDefinitionId] ON [dbo].[ImportColumn] ([ImportDefinitionId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportColumn] ADD CONSTRAINT [FK_ImportColumns_ImportDataTypeId] FOREIGN KEY ([ImportDataTypeId]) REFERENCES [dbo].[ImportDataType] ([ImportDataTypeId])
GO
ALTER TABLE [dbo].[ImportColumn] ADD CONSTRAINT [FK_ImportColumns_ImportDefinitionId] FOREIGN KEY ([ImportDefinitionId]) REFERENCES [dbo].[ImportDefinition] ([ImportDefinitionId])
GO
GRANT DELETE ON  [dbo].[ImportColumn] TO [public]
GO
GRANT INSERT ON  [dbo].[ImportColumn] TO [public]
GO
GRANT SELECT ON  [dbo].[ImportColumn] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImportColumn] TO [public]
GO
