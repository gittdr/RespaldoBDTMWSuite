CREATE TABLE [dbo].[TransferDetailEmployee]
(
[TransferHeaderId] [int] NOT NULL,
[DriverId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [bit] NULL,
[StatusMessage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferDetailEmployee] ADD CONSTRAINT [PK_TransferDetailEmployee] PRIMARY KEY CLUSTERED ([TransferHeaderId], [DriverId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TransferHeaderId_Status] ON [dbo].[TransferDetailEmployee] ([TransferHeaderId], [Status]) INCLUDE ([StatusMessage]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferDetailEmployee] ADD CONSTRAINT [FK_TransferDetailEmployee_TransferHeader] FOREIGN KEY ([TransferHeaderId]) REFERENCES [dbo].[TransferHeader] ([TransferHeaderId])
GO
GRANT DELETE ON  [dbo].[TransferDetailEmployee] TO [public]
GO
GRANT INSERT ON  [dbo].[TransferDetailEmployee] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TransferDetailEmployee] TO [public]
GO
GRANT SELECT ON  [dbo].[TransferDetailEmployee] TO [public]
GO
GRANT UPDATE ON  [dbo].[TransferDetailEmployee] TO [public]
GO
