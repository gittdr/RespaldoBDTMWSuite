CREATE TABLE [dbo].[TransferDetailPayable]
(
[TransferHeaderId] [int] NOT NULL,
[PayHeaderId] [int] NOT NULL,
[Status] [bit] NULL,
[StatusMessage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferDetailPayable] ADD CONSTRAINT [PK_TransferDetailPayable] PRIMARY KEY CLUSTERED ([TransferHeaderId], [PayHeaderId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TransferHeaderId_Status] ON [dbo].[TransferDetailPayable] ([TransferHeaderId], [Status]) INCLUDE ([StatusMessage]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferDetailPayable] ADD CONSTRAINT [FK_TransferDetailPayable_TransferHeader] FOREIGN KEY ([TransferHeaderId]) REFERENCES [dbo].[TransferHeader] ([TransferHeaderId])
GO
GRANT DELETE ON  [dbo].[TransferDetailPayable] TO [public]
GO
GRANT INSERT ON  [dbo].[TransferDetailPayable] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TransferDetailPayable] TO [public]
GO
GRANT SELECT ON  [dbo].[TransferDetailPayable] TO [public]
GO
GRANT UPDATE ON  [dbo].[TransferDetailPayable] TO [public]
GO
