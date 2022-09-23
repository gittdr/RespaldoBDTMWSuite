CREATE TABLE [dbo].[tch_transaction_counter]
(
[tch_transaction_counter] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tch_transaction_counter] TO [public]
GO
GRANT INSERT ON  [dbo].[tch_transaction_counter] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tch_transaction_counter] TO [public]
GO
GRANT SELECT ON  [dbo].[tch_transaction_counter] TO [public]
GO
GRANT UPDATE ON  [dbo].[tch_transaction_counter] TO [public]
GO
