CREATE TABLE [dbo].[TmwXmlMapperTableInfo]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[ImportingClassName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mapper_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[staging_table] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[target_table] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[join_clause] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[where_clause] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mapping_type] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_status_column] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TmwSynch] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TmwXmlMap__TmwSy__6E3E1CC4] DEFAULT ('Y'),
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__TmwXmlMap__lastu__6F3240FD] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TmwXmlMap__lastu__70266536] DEFAULT (suser_sname()),
[seqno] [int] NULL CONSTRAINT [DF__TmwXmlMap__seqno__23D3B32F] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TmwXmlMapperTableInfo] ADD CONSTRAINT [pk_TmwXmlMapperTableInfo] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TmwXmlMapperTable_ImportingClassName] ON [dbo].[TmwXmlMapperTableInfo] ([ImportingClassName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TmwXmlMapperTable_mapper_name] ON [dbo].[TmwXmlMapperTableInfo] ([mapper_name]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TmwXmlMapperTableInfo] TO [public]
GO
GRANT INSERT ON  [dbo].[TmwXmlMapperTableInfo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TmwXmlMapperTableInfo] TO [public]
GO
GRANT SELECT ON  [dbo].[TmwXmlMapperTableInfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[TmwXmlMapperTableInfo] TO [public]
GO
