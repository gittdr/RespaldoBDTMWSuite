CREATE TABLE [dbo].[TMSMatrixLinks]
(
[LinkId] [int] NOT NULL IDENTITY(1, 1),
[PrimaryMatrixId] [int] NOT NULL,
[LinkedMatrixId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSMatrixLinks] ADD CONSTRAINT [PK_TMSMatrixLinks] PRIMARY KEY CLUSTERED ([LinkId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_TMSMatrixLinks_LinkedMatrixId] ON [dbo].[TMSMatrixLinks] ([LinkedMatrixId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_TMSMatrixLinks_PrimaryMatrixId] ON [dbo].[TMSMatrixLinks] ([PrimaryMatrixId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSMatrixLinks] ADD CONSTRAINT [FK_TMSMatrixLinks_LinkedMatrixId] FOREIGN KEY ([LinkedMatrixId]) REFERENCES [dbo].[TMSMatrix] ([MatrixId])
GO
ALTER TABLE [dbo].[TMSMatrixLinks] ADD CONSTRAINT [FK_TMSMatrixLinks_PrimaryMatrixId] FOREIGN KEY ([PrimaryMatrixId]) REFERENCES [dbo].[TMSMatrix] ([MatrixId])
GO
