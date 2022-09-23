CREATE TABLE [dbo].[TmwXmlMapperColumnInfo]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlMapperTableInfo_Id] [int] NOT NULL,
[source_columnexpr] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[target_column] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__TmwXmlMap__lastu__7302D1E1] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TmwXmlMap__lastu__73F6F61A] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TmwXmlMapperColumnInfo] ADD CONSTRAINT [pk_TmwXmlMapperColumnInfo] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TmwXmlMapperColumnInfo_tmwxmlmappertable_id] ON [dbo].[TmwXmlMapperColumnInfo] ([TmwXmlMapperTableInfo_Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TmwXmlMapperColumnInfo] ADD CONSTRAINT [fk_TmwXmlMapperColumnInfo_tmwxmlmappertable_id] FOREIGN KEY ([TmwXmlMapperTableInfo_Id]) REFERENCES [dbo].[TmwXmlMapperTableInfo] ([id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[TmwXmlMapperColumnInfo] TO [public]
GO
GRANT INSERT ON  [dbo].[TmwXmlMapperColumnInfo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TmwXmlMapperColumnInfo] TO [public]
GO
GRANT SELECT ON  [dbo].[TmwXmlMapperColumnInfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[TmwXmlMapperColumnInfo] TO [public]
GO
