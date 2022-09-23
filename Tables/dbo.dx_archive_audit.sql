CREATE TABLE [dbo].[dx_archive_audit]
(
[dxa_ident] [bigint] NOT NULL IDENTITY(1, 1),
[dxa_upd_date] [datetime] NOT NULL,
[dxa_upd_user] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dxa_upd_app] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Orignalvalue] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordValue] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evf_key] [varchar] (203) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[evf_dxarchivesequence] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ismodified] [bit] NULL,
[Evaluate] [bit] NULL,
[NotInRange] [bit] NULL,
[Revert] [bit] NULL,
[Isnew] [bit] NULL,
[IsDeleted] [bit] NULL,
[IsOverwrite] [bit] NULL,
[IsRevertable] [bit] NULL,
[IsDisplayOnly] [bit] NULL,
[MiscReferenceValue] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_ident] [bigint] NULL,
[dx_sourcename] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_seq] [int] NULL,
[dx_ordernumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_orderhdrnumber] [int] NULL,
[dx_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_trpid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_processed] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_archive_audit] ADD CONSTRAINT [pk_dx_archive_audit] PRIMARY KEY CLUSTERED ([dxa_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_archive_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_archive_audit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_archive_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_archive_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_archive_audit] TO [public]
GO
