CREATE TABLE [dbo].[inv_acct_status_import]
(
[iasi_tran_id] [int] NOT NULL IDENTITY(1, 1),
[iasi_creation_dt] [datetime] NOT NULL,
[iasi_cre_by_id] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[iasi_processed_dt] [datetime] NULL,
[iasi_status] [smallint] NOT NULL,
[iasi_error_msg] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iasi_invoice_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[iasi_reject_reason_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[iasi_reject_reason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[iasi_batch_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inv_acct_status_import] ADD CONSTRAINT [pk_iasi_tran_id] PRIMARY KEY CLUSTERED ([iasi_tran_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[inv_acct_status_import] TO [public]
GO
GRANT INSERT ON  [dbo].[inv_acct_status_import] TO [public]
GO
GRANT REFERENCES ON  [dbo].[inv_acct_status_import] TO [public]
GO
GRANT SELECT ON  [dbo].[inv_acct_status_import] TO [public]
GO
GRANT UPDATE ON  [dbo].[inv_acct_status_import] TO [public]
GO
