CREATE TABLE [dbo].[TrlStorageContact]
(
[TrlStorageContactId] [int] NOT NULL IDENTITY(1, 1),
[TrlStorageId] [int] NOT NULL,
[TrlStorageContactStatusId] [int] NOT NULL,
[ContactName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactEmail] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactDate] [datetime] NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrlStorageContact] ADD CONSTRAINT [PK_TrlStorageContact] PRIMARY KEY CLUSTERED ([TrlStorageContactId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TrlStorageContact_TrlStorageContactId] ON [dbo].[TrlStorageContact] ([TrlStorageContactId], [TrlStorageContactStatusId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrlStorageContact] ADD CONSTRAINT [FK_TrlStorageContact_TrlStorageContact] FOREIGN KEY ([TrlStorageId]) REFERENCES [dbo].[TrlStorage] ([tstg_id])
GO
ALTER TABLE [dbo].[TrlStorageContact] ADD CONSTRAINT [FK_TrlStorageContact_TrlStorageContactStatus] FOREIGN KEY ([TrlStorageContactStatusId]) REFERENCES [dbo].[TrlStorageContactStatus] ([TrlStorageContactStatusId])
GO
GRANT DELETE ON  [dbo].[TrlStorageContact] TO [public]
GO
GRANT INSERT ON  [dbo].[TrlStorageContact] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TrlStorageContact] TO [public]
GO
GRANT SELECT ON  [dbo].[TrlStorageContact] TO [public]
GO
GRANT UPDATE ON  [dbo].[TrlStorageContact] TO [public]
GO
