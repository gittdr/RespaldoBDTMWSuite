CREATE TABLE [dbo].[edi_214]
(
[data_col] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[identity_col] [int] NOT NULL IDENTITY(1, 1),
[trp_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[doc_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_source] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_user] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214_extractapp] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_data_col] ON [dbo].[edi_214] ([data_col]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [dk_doc_id] ON [dbo].[edi_214] ([doc_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_214] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_214] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_214] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_214] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_214] TO [public]
GO
