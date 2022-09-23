CREATE TABLE [dbo].[TMSMatrixTMWKeys]
(
[LinkID] [int] NOT NULL IDENTITY(1, 1),
[MatrixId] [int] NULL,
[OriginAreaId] [int] NOT NULL,
[DestAreaId] [int] NOT NULL,
[RegId] [int] NULL,
[RegDetId] [int] NULL,
[tar_number] [int] NULL,
[trk_number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSMatrixTMWKeys] ADD CONSTRAINT [PK_TMSMatrixTMWKeys] PRIMARY KEY CLUSTERED ([LinkID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_TMSMatrixTMWKeys_MatrixId] ON [dbo].[TMSMatrixTMWKeys] ([MatrixId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSMatrixTMWKeys] ADD CONSTRAINT [FK_TMSMatrixTMWKeys_DestAreaId] FOREIGN KEY ([DestAreaId]) REFERENCES [dbo].[TMSAreaDetail] ([AreaId])
GO
ALTER TABLE [dbo].[TMSMatrixTMWKeys] ADD CONSTRAINT [FK_TMSMatrixTMWKeys_MatrixId] FOREIGN KEY ([MatrixId]) REFERENCES [dbo].[TMSMatrix] ([MatrixId])
GO
ALTER TABLE [dbo].[TMSMatrixTMWKeys] ADD CONSTRAINT [FK_TMSMatrixTMWKeys_OriginAreaId] FOREIGN KEY ([OriginAreaId]) REFERENCES [dbo].[TMSAreaDetail] ([AreaId])
GO
ALTER TABLE [dbo].[TMSMatrixTMWKeys] ADD CONSTRAINT [FK_TMSMatrixTMWKeys_RegDetId] FOREIGN KEY ([RegDetId]) REFERENCES [dbo].[TMSRegionDetail] ([RegDetId])
GO
ALTER TABLE [dbo].[TMSMatrixTMWKeys] ADD CONSTRAINT [FK_TMSMatrixTMWKeys_RegId] FOREIGN KEY ([RegId]) REFERENCES [dbo].[TMSRegion] ([RegId])
GO
GRANT DELETE ON  [dbo].[TMSMatrixTMWKeys] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSMatrixTMWKeys] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSMatrixTMWKeys] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSMatrixTMWKeys] TO [public]
GO
