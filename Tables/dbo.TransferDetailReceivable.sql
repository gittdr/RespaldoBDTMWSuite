CREATE TABLE [dbo].[TransferDetailReceivable]
(
[TransferHeaderId] [int] NOT NULL,
[ReceivableId] [int] NOT NULL,
[ReceivableTypeId] [tinyint] NOT NULL,
[Status] [bit] NULL,
[StatusMessage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferDetailReceivable] ADD CONSTRAINT [PK_TransferDetailReceivable] PRIMARY KEY CLUSTERED ([TransferHeaderId], [ReceivableTypeId], [ReceivableId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TransferHeaderId_Status] ON [dbo].[TransferDetailReceivable] ([TransferHeaderId], [Status]) INCLUDE ([StatusMessage]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferDetailReceivable] ADD CONSTRAINT [FK_TransferDetailReceivable_TransferHeader] FOREIGN KEY ([TransferHeaderId]) REFERENCES [dbo].[TransferHeader] ([TransferHeaderId])
GO
ALTER TABLE [dbo].[TransferDetailReceivable] ADD CONSTRAINT [FK_TransferDetailReceivable_TransferReceivableType] FOREIGN KEY ([ReceivableTypeId]) REFERENCES [dbo].[TransferReceivableType] ([ReceivableTypeId])
GO
GRANT DELETE ON  [dbo].[TransferDetailReceivable] TO [public]
GO
GRANT INSERT ON  [dbo].[TransferDetailReceivable] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TransferDetailReceivable] TO [public]
GO
GRANT SELECT ON  [dbo].[TransferDetailReceivable] TO [public]
GO
GRANT UPDATE ON  [dbo].[TransferDetailReceivable] TO [public]
GO
