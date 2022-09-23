CREATE TABLE [dbo].[TransferDetailCustomer]
(
[TransferHeaderId] [int] NOT NULL,
[CompanyId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [bit] NULL,
[StatusMessage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferDetailCustomer] ADD CONSTRAINT [PK_TransferDetailCustomer] PRIMARY KEY CLUSTERED ([TransferHeaderId], [CompanyId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TransferHeaderId_Status] ON [dbo].[TransferDetailCustomer] ([TransferHeaderId], [Status]) INCLUDE ([StatusMessage]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferDetailCustomer] ADD CONSTRAINT [FK_TransferDetailCustomer_TransferHeader] FOREIGN KEY ([TransferHeaderId]) REFERENCES [dbo].[TransferHeader] ([TransferHeaderId])
GO
GRANT DELETE ON  [dbo].[TransferDetailCustomer] TO [public]
GO
GRANT INSERT ON  [dbo].[TransferDetailCustomer] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TransferDetailCustomer] TO [public]
GO
GRANT SELECT ON  [dbo].[TransferDetailCustomer] TO [public]
GO
GRANT UPDATE ON  [dbo].[TransferDetailCustomer] TO [public]
GO
