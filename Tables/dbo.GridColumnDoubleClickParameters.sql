CREATE TABLE [dbo].[GridColumnDoubleClickParameters]
(
[ParameterListId] [int] NOT NULL IDENTITY(1, 1),
[ColumnMappingId] [int] NOT NULL,
[Sequence] [int] NOT NULL,
[ParameterName] [varchar] (28) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[CreatedBy] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModifiedDate] [datetime] NULL,
[ModifiedBy] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GridColumnDoubleClickParameters] ADD CONSTRAINT [PK_GridColumnDoubleClickParameters] PRIMARY KEY CLUSTERED ([ParameterListId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [GridIndex] ON [dbo].[GridColumnDoubleClickParameters] ([ColumnMappingId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GridColumnDoubleClickParameters] TO [public]
GO
GRANT INSERT ON  [dbo].[GridColumnDoubleClickParameters] TO [public]
GO
GRANT REFERENCES ON  [dbo].[GridColumnDoubleClickParameters] TO [public]
GO
GRANT SELECT ON  [dbo].[GridColumnDoubleClickParameters] TO [public]
GO
GRANT UPDATE ON  [dbo].[GridColumnDoubleClickParameters] TO [public]
GO
