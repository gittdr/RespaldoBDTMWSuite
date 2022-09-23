CREATE TABLE [dbo].[edi_214_purge]
(
[data_col] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[doc_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_214_purge] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_214_purge] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_214_purge] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_214_purge] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_214_purge] TO [public]
GO
