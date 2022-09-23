CREATE TABLE [dbo].[invoiceprintqueue]
(
[ivq_batch_number] [int] NOT NULL,
[ivh_hdrnumber] [int] NOT NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[invoiceprintqueue] TO [public]
GO
GRANT INSERT ON  [dbo].[invoiceprintqueue] TO [public]
GO
GRANT REFERENCES ON  [dbo].[invoiceprintqueue] TO [public]
GO
GRANT SELECT ON  [dbo].[invoiceprintqueue] TO [public]
GO
GRANT UPDATE ON  [dbo].[invoiceprintqueue] TO [public]
GO
