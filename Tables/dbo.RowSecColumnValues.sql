CREATE TABLE [dbo].[RowSecColumnValues]
(
[rscv_id] [int] NOT NULL IDENTITY(1, 1),
[rsc_id] [int] NOT NULL,
[rscv_value] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rscv_description] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RowSecColumnValues] ADD CONSTRAINT [PK_RowSecColumnValues] PRIMARY KEY CLUSTERED ([rscv_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_RowSecColumnValues_RSCID_Value] ON [dbo].[RowSecColumnValues] ([rsc_id], [rscv_value]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RowSecColumnValues] ADD CONSTRAINT [FK_RowSecColumnValues_RowSecColumns] FOREIGN KEY ([rsc_id]) REFERENCES [dbo].[RowSecColumns] ([rsc_id])
GO
GRANT DELETE ON  [dbo].[RowSecColumnValues] TO [public]
GO
GRANT INSERT ON  [dbo].[RowSecColumnValues] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RowSecColumnValues] TO [public]
GO
GRANT SELECT ON  [dbo].[RowSecColumnValues] TO [public]
GO
GRANT UPDATE ON  [dbo].[RowSecColumnValues] TO [public]
GO
