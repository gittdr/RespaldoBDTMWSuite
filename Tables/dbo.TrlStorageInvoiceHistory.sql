CREATE TABLE [dbo].[TrlStorageInvoiceHistory]
(
[TrailerStorageId] [int] NOT NULL,
[ivh_hdrnumber] [int] NOT NULL,
[LastBillDate] [datetime] NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDate] [datetime] NOT NULL,
[FreeDays] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrlStorageInvoiceHistory] ADD CONSTRAINT [PK_TrlStorageInvoiceHistory] PRIMARY KEY CLUSTERED ([TrailerStorageId], [ivh_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TrlStorageInvoiceHistory_LastBillDate] ON [dbo].[TrlStorageInvoiceHistory] ([LastBillDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrlStorageInvoiceHistory] ADD CONSTRAINT [FK_TrlStorageInvoiceHistory_TrlStorage] FOREIGN KEY ([TrailerStorageId]) REFERENCES [dbo].[TrlStorage] ([tstg_id])
GO
GRANT DELETE ON  [dbo].[TrlStorageInvoiceHistory] TO [public]
GO
GRANT INSERT ON  [dbo].[TrlStorageInvoiceHistory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TrlStorageInvoiceHistory] TO [public]
GO
GRANT SELECT ON  [dbo].[TrlStorageInvoiceHistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[TrlStorageInvoiceHistory] TO [public]
GO
