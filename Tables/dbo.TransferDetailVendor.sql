CREATE TABLE [dbo].[TransferDetailVendor]
(
[TransferHeaderId] [int] NOT NULL,
[PayToId] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [bit] NULL,
[StatusMessage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferDetailVendor] ADD CONSTRAINT [PK_TransferDetailVendor] PRIMARY KEY CLUSTERED ([TransferHeaderId], [PayToId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TransferHeaderId_Status] ON [dbo].[TransferDetailVendor] ([TransferHeaderId], [Status]) INCLUDE ([StatusMessage]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferDetailVendor] ADD CONSTRAINT [FK_TransferDetailVendor_TransferHeader] FOREIGN KEY ([TransferHeaderId]) REFERENCES [dbo].[TransferHeader] ([TransferHeaderId])
GO
GRANT DELETE ON  [dbo].[TransferDetailVendor] TO [public]
GO
GRANT INSERT ON  [dbo].[TransferDetailVendor] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TransferDetailVendor] TO [public]
GO
GRANT SELECT ON  [dbo].[TransferDetailVendor] TO [public]
GO
GRANT UPDATE ON  [dbo].[TransferDetailVendor] TO [public]
GO
