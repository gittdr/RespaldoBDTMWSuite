CREATE TABLE [dbo].[TMSMatrixDetail]
(
[MatrixDetailId] [int] NOT NULL IDENTITY(1, 1),
[MatrixId] [int] NOT NULL,
[OriginAreaId] [int] NOT NULL,
[DestAreaId] [int] NOT NULL,
[Rate] [decimal] (18, 6) NOT NULL,
[MinQuantity] [decimal] (18, 6) NOT NULL,
[MinRate] [decimal] (18, 6) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSMatrixDetail] ADD CONSTRAINT [PK_TMSMatrixDetail] PRIMARY KEY CLUSTERED ([MatrixDetailId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_TMSMatrixDetail_MatrixId] ON [dbo].[TMSMatrixDetail] ([MatrixId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSMatrixDetail] ADD CONSTRAINT [FK_TMSMatrixDetail_DestAreaId] FOREIGN KEY ([DestAreaId]) REFERENCES [dbo].[TMSAreaDetail] ([AreaId])
GO
ALTER TABLE [dbo].[TMSMatrixDetail] ADD CONSTRAINT [FK_TMSMatrixDetail_MatrixId] FOREIGN KEY ([MatrixId]) REFERENCES [dbo].[TMSMatrix] ([MatrixId])
GO
ALTER TABLE [dbo].[TMSMatrixDetail] ADD CONSTRAINT [FK_TMSMatrixDetail_OriginAreaId] FOREIGN KEY ([OriginAreaId]) REFERENCES [dbo].[TMSAreaDetail] ([AreaId])
GO
GRANT DELETE ON  [dbo].[TMSMatrixDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSMatrixDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSMatrixDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSMatrixDetail] TO [public]
GO
