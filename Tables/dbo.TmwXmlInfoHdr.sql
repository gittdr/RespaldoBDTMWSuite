CREATE TABLE [dbo].[TmwXmlInfoHdr]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[ImportingClassName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RootElementName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__TmwXmlInf__lastu__65A8D6C3] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TmwXmlInf__lastu__669CFAFC] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TmwXmlInfoHdr] ADD CONSTRAINT [pk_TmwXmlInfoHdr] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TmwXmlInfoHdr_ImportingClassName] ON [dbo].[TmwXmlInfoHdr] ([ImportingClassName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TmwXmlInfoHdr] TO [public]
GO
GRANT INSERT ON  [dbo].[TmwXmlInfoHdr] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TmwXmlInfoHdr] TO [public]
GO
GRANT SELECT ON  [dbo].[TmwXmlInfoHdr] TO [public]
GO
GRANT UPDATE ON  [dbo].[TmwXmlInfoHdr] TO [public]
GO
