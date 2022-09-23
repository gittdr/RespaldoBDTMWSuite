CREATE TABLE [dbo].[TransferReceivableType]
(
[ReceivableTypeId] [tinyint] NOT NULL,
[ReceivableType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferReceivableType] ADD CONSTRAINT [PK_TransferReceivableType] PRIMARY KEY CLUSTERED ([ReceivableTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TransferReceivableType] TO [public]
GO
GRANT INSERT ON  [dbo].[TransferReceivableType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TransferReceivableType] TO [public]
GO
GRANT SELECT ON  [dbo].[TransferReceivableType] TO [public]
GO
GRANT UPDATE ON  [dbo].[TransferReceivableType] TO [public]
GO
