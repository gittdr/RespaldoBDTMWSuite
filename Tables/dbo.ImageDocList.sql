CREATE TABLE [dbo].[ImageDocList]
(
[idl_ID] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[idl_sequence] [tinyint] NULL,
[idl_docid] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[idl_transcode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImageDocList] ADD CONSTRAINT [PK__ImageDocList__63DA6523] PRIMARY KEY CLUSTERED ([idl_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_cmpid_Docid] ON [dbo].[ImageDocList] ([cmp_id], [idl_docid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImageDocList] TO [public]
GO
GRANT INSERT ON  [dbo].[ImageDocList] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ImageDocList] TO [public]
GO
GRANT SELECT ON  [dbo].[ImageDocList] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImageDocList] TO [public]
GO
