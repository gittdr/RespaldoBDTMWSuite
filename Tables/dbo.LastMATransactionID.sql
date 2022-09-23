CREATE TABLE [dbo].[LastMATransactionID]
(
[transaction_id] [bigint] NOT NULL,
[inserted_date] [datetime] NOT NULL CONSTRAINT [DF_LastMATransactionID_InsertedDate] DEFAULT (getdate()),
[company_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LastMATransactionID_company_id] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LastMATransactionID] ADD CONSTRAINT [PK_LastMATransactionID] PRIMARY KEY CLUSTERED ([transaction_id], [company_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_LastMATransactionID_InsertedDate] ON [dbo].[LastMATransactionID] ([inserted_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LastMATransactionID] TO [public]
GO
GRANT INSERT ON  [dbo].[LastMATransactionID] TO [public]
GO
GRANT REFERENCES ON  [dbo].[LastMATransactionID] TO [public]
GO
GRANT SELECT ON  [dbo].[LastMATransactionID] TO [public]
GO
GRANT UPDATE ON  [dbo].[LastMATransactionID] TO [public]
GO
