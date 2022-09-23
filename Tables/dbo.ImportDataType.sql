CREATE TABLE [dbo].[ImportDataType]
(
[ImportDataTypeId] [int] NOT NULL IDENTITY(1, 1),
[Value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportDataType] ADD CONSTRAINT [PK_ImportDataType] PRIMARY KEY CLUSTERED ([ImportDataTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImportDataType] TO [public]
GO
GRANT INSERT ON  [dbo].[ImportDataType] TO [public]
GO
GRANT SELECT ON  [dbo].[ImportDataType] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImportDataType] TO [public]
GO
