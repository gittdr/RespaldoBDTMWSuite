CREATE TABLE [dbo].[emanifest_transaction_log]
(
[etl_trans_id] [int] NOT NULL IDENTITY(1, 1),
[mov_number] [int] NULL,
[etl_trans_doctype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[etl_trans_sender] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[etl_trans_date] [datetime] NULL,
[etl_trans_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[etl_trans_user] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttm_message_id] [int] NULL,
[autoprocess_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[emanifest_transaction_log] ADD CONSTRAINT [PK__emanifest_transa__5FFE7F84] PRIMARY KEY CLUSTERED ([etl_trans_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_etl_mov_number] ON [dbo].[emanifest_transaction_log] ([mov_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[emanifest_transaction_log] TO [public]
GO
GRANT INSERT ON  [dbo].[emanifest_transaction_log] TO [public]
GO
GRANT SELECT ON  [dbo].[emanifest_transaction_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[emanifest_transaction_log] TO [public]
GO
