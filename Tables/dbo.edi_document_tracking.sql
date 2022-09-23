CREATE TABLE [dbo].[edi_document_tracking]
(
[edt_doctype] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edt_batch_datetime_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trp_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edt_batch_image_seq] [int] NULL,
[edt_docID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edt_extract_dttm] [datetime] NULL,
[edt_extract_count] [smallint] NULL,
[edt_ack_dttm] [datetime] NULL,
[edt_ack_flag] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_number] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edt_image] [varchar] (900) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edt_id] [int] NOT NULL IDENTITY(1, 1),
[ivh_invoicenumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edt_batch_control] [int] NULL,
[edt_batch_doc_seq] [int] NULL,
[edt_selected] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edt_997_flag] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edt_997_dttm] [datetime] NULL,
[edt_GS_control_number] [int] NULL,
[edt_ISA_control_number] [int] NULL,
[edt_ISA_receiver_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edt_ST_control_number] [int] NULL,
[edt_processed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edt_source] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edt_user] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edt_extractapp] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[edi_document_tracking] ADD CONSTRAINT [PK__edi_document_tra__6EA3A307] PRIMARY KEY CLUSTERED ([edt_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_edt_docID] ON [dbo].[edi_document_tracking] ([edt_docID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [k_docdatetrpidack] ON [dbo].[edi_document_tracking] ([edt_doctype], [edt_batch_datetime_id], [trp_id], [edt_docID], [edt_ack_flag]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [k_docord] ON [dbo].[edi_document_tracking] ([edt_doctype], [ord_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_edi_document_tracking_doctype_trpid_docid_batch_docseq] ON [dbo].[edi_document_tracking] ([edt_doctype], [trp_id], [edt_docID], [edt_batch_control], [edt_batch_doc_seq]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_edt_gs_control_number] ON [dbo].[edi_document_tracking] ([edt_GS_control_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_edt_ISA_receiver_id] ON [dbo].[edi_document_tracking] ([edt_ISA_receiver_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_edt_selected] ON [dbo].[edi_document_tracking] ([edt_selected]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_edt_ST_control_number] ON [dbo].[edi_document_tracking] ([edt_ST_control_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_edt_ivhnum_ctrl_docsk_imgsk_doctyp] ON [dbo].[edi_document_tracking] ([ivh_invoicenumber], [edt_batch_control], [edt_batch_doc_seq], [edt_batch_image_seq], [edt_doctype]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_document_tracking] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_document_tracking] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_document_tracking] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_document_tracking] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_document_tracking] TO [public]
GO
