CREATE TABLE [dbo].[orderdatatracking]
(
[odt_id] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[odt_tablekey] [int] NULL,
[odt_tablename] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[odt_message] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[odt_columnname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[odt_oldvalue] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[odt_newvalue] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[odt_createddate] [datetime] NULL,
[odt_createdby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[odt_updateddate] [datetime] NULL,
[odt_updatedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[odt_reviewed] [bit] NULL,
[odt_revieweddate] [datetime] NULL,
[odt_reviewedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[orderdatatracking] ADD CONSTRAINT [pk_orderdatatracking] PRIMARY KEY CLUSTERED ([odt_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_orderdatatracking_lgh_number] ON [dbo].[orderdatatracking] ([lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_orderdatatracking_mov_number] ON [dbo].[orderdatatracking] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_orderdatatracking_odt_createddate] ON [dbo].[orderdatatracking] ([odt_createddate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_orderdatatracking_odt_reviewed] ON [dbo].[orderdatatracking] ([odt_reviewed]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_orderdatatracking_odt_reviewedby] ON [dbo].[orderdatatracking] ([odt_reviewedby]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_orderdatatracking_odt_revieweddate] ON [dbo].[orderdatatracking] ([odt_revieweddate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_orderdatatracking_odt_tablekey] ON [dbo].[orderdatatracking] ([odt_tablekey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_orderdatatracking_odt_tablename] ON [dbo].[orderdatatracking] ([odt_tablename]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_orderdatatracking_ord_hdrnumber] ON [dbo].[orderdatatracking] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[orderdatatracking] TO [public]
GO
GRANT INSERT ON  [dbo].[orderdatatracking] TO [public]
GO
GRANT REFERENCES ON  [dbo].[orderdatatracking] TO [public]
GO
GRANT SELECT ON  [dbo].[orderdatatracking] TO [public]
GO
GRANT UPDATE ON  [dbo].[orderdatatracking] TO [public]
GO
