CREATE TABLE [dbo].[TransferType]
(
[TransferTypeId] [tinyint] NOT NULL,
[TransferType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferType] ADD CONSTRAINT [PK_TransferType] PRIMARY KEY CLUSTERED ([TransferTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TransferType] TO [public]
GO
GRANT INSERT ON  [dbo].[TransferType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TransferType] TO [public]
GO
GRANT SELECT ON  [dbo].[TransferType] TO [public]
GO
GRANT UPDATE ON  [dbo].[TransferType] TO [public]
GO
