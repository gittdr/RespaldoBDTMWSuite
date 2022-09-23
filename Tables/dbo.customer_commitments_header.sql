CREATE TABLE [dbo].[customer_commitments_header]
(
[cmch_sn] [int] NOT NULL IDENTITY(1, 1),
[cmch_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmch_sort] [varchar] (1012) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_customer_commitments_header_cmp_id] ON [dbo].[customer_commitments_header] ([cmch_cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[customer_commitments_header] TO [public]
GO
GRANT INSERT ON  [dbo].[customer_commitments_header] TO [public]
GO
GRANT REFERENCES ON  [dbo].[customer_commitments_header] TO [public]
GO
GRANT SELECT ON  [dbo].[customer_commitments_header] TO [public]
GO
GRANT UPDATE ON  [dbo].[customer_commitments_header] TO [public]
GO
