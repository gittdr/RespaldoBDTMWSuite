CREATE TABLE [dbo].[RowSecRowColumnValues]
(
[rsrcv_id] [int] NOT NULL IDENTITY(1, 1),
[rsrv_id] [int] NOT NULL,
[rsc_sequence] [int] NOT NULL,
[rscv_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RowSecRowColumnValues] ADD CONSTRAINT [PK_RowSecRowColumnValues] PRIMARY KEY CLUSTERED ([rsrcv_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RowSecRowColumnValues_rsrv_id_rscv_id] ON [dbo].[RowSecRowColumnValues] ([rsrv_id], [rscv_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RowSecRowColumnValues] ADD CONSTRAINT [FK_RowSecRowColumnValues_RowSecColumnValues] FOREIGN KEY ([rscv_id]) REFERENCES [dbo].[RowSecColumnValues] ([rscv_id])
GO
ALTER TABLE [dbo].[RowSecRowColumnValues] ADD CONSTRAINT [FK_RowSecRowColumnValues_RowSecRowValues] FOREIGN KEY ([rsrv_id]) REFERENCES [dbo].[RowSecRowValues] ([rsrv_id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[RowSecRowColumnValues] TO [public]
GO
GRANT INSERT ON  [dbo].[RowSecRowColumnValues] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RowSecRowColumnValues] TO [public]
GO
GRANT SELECT ON  [dbo].[RowSecRowColumnValues] TO [public]
GO
GRANT UPDATE ON  [dbo].[RowSecRowColumnValues] TO [public]
GO
