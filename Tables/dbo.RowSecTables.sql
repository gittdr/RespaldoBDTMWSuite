CREATE TABLE [dbo].[RowSecTables]
(
[rst_id] [int] NOT NULL IDENTITY(1, 1),
[rst_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rst_table_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rst_primary_key] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rst_belongsto_column] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rst_max_columns] [smallint] NOT NULL,
[rst_enabled] [bit] NOT NULL CONSTRAINT [DF_RowSecTables_rst_enabled] DEFAULT ((0)),
[rst_applied] [bit] NOT NULL CONSTRAINT [DF_RowSecTables_rst_applied] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RowSecTables] ADD CONSTRAINT [PK_RowSecTables] PRIMARY KEY CLUSTERED ([rst_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_RowSecTables_TableName_PrimaryKey] ON [dbo].[RowSecTables] ([rst_table_name], [rst_primary_key]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RowSecTables] TO [public]
GO
GRANT INSERT ON  [dbo].[RowSecTables] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RowSecTables] TO [public]
GO
GRANT SELECT ON  [dbo].[RowSecTables] TO [public]
GO
GRANT UPDATE ON  [dbo].[RowSecTables] TO [public]
GO
