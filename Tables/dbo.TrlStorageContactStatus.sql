CREATE TABLE [dbo].[TrlStorageContactStatus]
(
[TrlStorageContactStatusId] [int] NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Retired] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrlStorageContactStatus] ADD CONSTRAINT [PK_TrlStorageContactStatus] PRIMARY KEY CLUSTERED ([TrlStorageContactStatusId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TrlStorageContactStatus] TO [public]
GO
GRANT INSERT ON  [dbo].[TrlStorageContactStatus] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TrlStorageContactStatus] TO [public]
GO
GRANT SELECT ON  [dbo].[TrlStorageContactStatus] TO [public]
GO
GRANT UPDATE ON  [dbo].[TrlStorageContactStatus] TO [public]
GO
