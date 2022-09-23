CREATE TABLE [dbo].[TransferDetailPayroll]
(
[TransferHeaderId] [int] NOT NULL,
[PayHeaderId] [int] NOT NULL,
[Status] [bit] NULL,
[StatusMessage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferDetailPayroll] ADD CONSTRAINT [PK_TransferDetailPayroll] PRIMARY KEY CLUSTERED ([TransferHeaderId], [PayHeaderId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TransferHeaderId_Status] ON [dbo].[TransferDetailPayroll] ([TransferHeaderId], [Status]) INCLUDE ([StatusMessage]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferDetailPayroll] ADD CONSTRAINT [FK_TransferDetailPayroll_TransferHeader] FOREIGN KEY ([TransferHeaderId]) REFERENCES [dbo].[TransferHeader] ([TransferHeaderId])
GO
GRANT DELETE ON  [dbo].[TransferDetailPayroll] TO [public]
GO
GRANT INSERT ON  [dbo].[TransferDetailPayroll] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TransferDetailPayroll] TO [public]
GO
GRANT SELECT ON  [dbo].[TransferDetailPayroll] TO [public]
GO
GRANT UPDATE ON  [dbo].[TransferDetailPayroll] TO [public]
GO
