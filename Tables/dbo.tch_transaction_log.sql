CREATE TABLE [dbo].[tch_transaction_log]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[tchtl_transaction_data] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tchtl_log_data] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tchtl_max_transactiondate] [datetime] NOT NULL,
[tchtl_updatedon] [datetime] NOT NULL,
[transaction_number] [int] NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[error_message] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[processed_datetime] [datetime] NULL,
[created_datetime] [datetime] NULL,
[location_info] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[policy_number] [int] NULL,
[tchtl_carrierid] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tch_transaction_log_status] ON [dbo].[tch_transaction_log] ([status]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tch_transaction_log_tansdate] ON [dbo].[tch_transaction_log] ([tchtl_max_transactiondate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tch_transaction_log_tansnumber] ON [dbo].[tch_transaction_log] ([transaction_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tch_transaction_log] TO [public]
GO
GRANT INSERT ON  [dbo].[tch_transaction_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tch_transaction_log] TO [public]
GO
GRANT SELECT ON  [dbo].[tch_transaction_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[tch_transaction_log] TO [public]
GO
