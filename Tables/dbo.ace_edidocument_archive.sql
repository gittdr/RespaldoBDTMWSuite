CREATE TABLE [dbo].[ace_edidocument_archive]
(
[aea_record_id] [int] NOT NULL IDENTITY(1, 1),
[aea_doctype] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aea_batch] [int] NULL,
[aea_batch_seq] [int] NULL,
[aea_datacol] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[aea_archivedate] [datetime] NULL,
[aea_tmwuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aea_997_flg] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aea_997_date] [datetime] NULL,
[aea_355_flg] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aea_355_date] [datetime] NULL,
[aea_355_reason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aea_context] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ace_edidocument_archive] ADD CONSTRAINT [PK__ace_edidocument___518F677B] PRIMARY KEY CLUSTERED ([aea_record_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_aea_doctype_batch] ON [dbo].[ace_edidocument_archive] ([aea_doctype], [aea_batch]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_aea_mov_number] ON [dbo].[ace_edidocument_archive] ([mov_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ace_edidocument_archive] TO [public]
GO
GRANT INSERT ON  [dbo].[ace_edidocument_archive] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ace_edidocument_archive] TO [public]
GO
GRANT SELECT ON  [dbo].[ace_edidocument_archive] TO [public]
GO
GRANT UPDATE ON  [dbo].[ace_edidocument_archive] TO [public]
GO
