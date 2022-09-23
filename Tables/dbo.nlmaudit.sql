CREATE TABLE [dbo].[nlmaudit]
(
[nlm_shipment_number] [int] NOT NULL,
[nlma_desc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nlma_code] [int] NULL,
[nlma_updated_dt] [datetime] NULL,
[nlma_updated_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_nlmaudit_id] ON [dbo].[nlmaudit] ([nlm_shipment_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_nlmauditcode] ON [dbo].[nlmaudit] ([nlma_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nlmaudit] TO [public]
GO
GRANT INSERT ON  [dbo].[nlmaudit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[nlmaudit] TO [public]
GO
GRANT SELECT ON  [dbo].[nlmaudit] TO [public]
GO
GRANT UPDATE ON  [dbo].[nlmaudit] TO [public]
GO
