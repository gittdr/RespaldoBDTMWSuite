CREATE TABLE [dbo].[notes_audit]
(
[audit_id] [int] NOT NULL IDENTITY(1, 1),
[audit_datetime] [datetime] NOT NULL,
[audit_loguser] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[audit_dbuser] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[audit_application] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[audit_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[not_number] [int] NOT NULL,
[not_text] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_urgent] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_senton] [datetime] NULL,
[not_sentby] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_expires] [datetime] NULL,
[not_forwardedfrom] [int] NULL,
[ntb_table] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nre_tablekey] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_sequence] [smallint] NULL,
[last_updatedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedatetime] [datetime] NULL,
[autonote] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_text_large] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_viewlevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ntb_table_copied_from] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nre_tablekey_copied_from] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_number_copied_from] [int] NULL,
[not_tmsend] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[notes_audit] ADD CONSTRAINT [pk_notes_audit] PRIMARY KEY CLUSTERED ([audit_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[notes_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[notes_audit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[notes_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[notes_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[notes_audit] TO [public]
GO
