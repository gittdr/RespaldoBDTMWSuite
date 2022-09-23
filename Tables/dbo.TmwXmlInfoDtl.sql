CREATE TABLE [dbo].[TmwXmlInfoDtl]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[tmwxmlinfohdr_id] [int] NOT NULL,
[elementname] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[staging_table] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isEachElementARow] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__TmwXmlInf__lastu__697967A7] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TmwXmlInf__lastu__6A6D8BE0] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TmwXmlInfoDtl] ADD CONSTRAINT [pk_TmwXmlInfoDtl] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TmwXmlInfoDtl_elementname] ON [dbo].[TmwXmlInfoDtl] ([elementname]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TmwXmlInfoDtl_staging_table] ON [dbo].[TmwXmlInfoDtl] ([staging_table]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TmwXmlInfoDtl_tmwxmlinfohdr_id] ON [dbo].[TmwXmlInfoDtl] ([tmwxmlinfohdr_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TmwXmlInfoDtl] ADD CONSTRAINT [fk_tmwxmlinfodtl_tmwxmlinfohdr_id] FOREIGN KEY ([tmwxmlinfohdr_id]) REFERENCES [dbo].[TmwXmlInfoHdr] ([id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[TmwXmlInfoDtl] TO [public]
GO
GRANT INSERT ON  [dbo].[TmwXmlInfoDtl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TmwXmlInfoDtl] TO [public]
GO
GRANT SELECT ON  [dbo].[TmwXmlInfoDtl] TO [public]
GO
GRANT UPDATE ON  [dbo].[TmwXmlInfoDtl] TO [public]
GO
