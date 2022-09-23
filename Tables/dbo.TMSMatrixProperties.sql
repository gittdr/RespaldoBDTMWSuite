CREATE TABLE [dbo].[TMSMatrixProperties]
(
[MatrixPropId] [int] NOT NULL IDENTITY(1, 1),
[MatrixId] [int] NULL,
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumericMin] [decimal] (18, 6) NOT NULL,
[NumericMax] [decimal] (18, 6) NOT NULL,
[NumericUnit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSMatrixProperties] ADD CONSTRAINT [PK_TMSMatrixProperties] PRIMARY KEY CLUSTERED ([MatrixPropId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_TMSMatrixProperties_MatrixId] ON [dbo].[TMSMatrixProperties] ([MatrixId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSMatrixProperties] ADD CONSTRAINT [FK_TMSMatrixProperties_MatrixId] FOREIGN KEY ([MatrixId]) REFERENCES [dbo].[TMSMatrix] ([MatrixId])
GO
GRANT DELETE ON  [dbo].[TMSMatrixProperties] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSMatrixProperties] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSMatrixProperties] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSMatrixProperties] TO [public]
GO
