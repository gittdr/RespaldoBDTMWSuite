CREATE TABLE [dbo].[tmwauditcolumns]
(
[tmwauditcolumns_id] [int] NOT NULL IDENTITY(1, 1),
[object] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obj_column] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obj_keycolumns] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[db_table] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[db_column] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[db_keycolumns] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[db_keycolumnsdesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[external_function_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[external_function] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tmwauditcolumns] ADD CONSTRAINT [PK__tmwauditcolumns__21DB904F] PRIMARY KEY CLUSTERED ([tmwauditcolumns_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_object] ON [dbo].[tmwauditcolumns] ([object]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_objectcolumn] ON [dbo].[tmwauditcolumns] ([object], [obj_column]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tmwauditcolumns] TO [public]
GO
GRANT INSERT ON  [dbo].[tmwauditcolumns] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tmwauditcolumns] TO [public]
GO
GRANT SELECT ON  [dbo].[tmwauditcolumns] TO [public]
GO
GRANT UPDATE ON  [dbo].[tmwauditcolumns] TO [public]
GO
