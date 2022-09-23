CREATE TABLE [dbo].[TrlStorageStatus]
(
[TrlStorageStatusId] [int] NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Retired] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrlStorageStatus] ADD CONSTRAINT [PK_TrlStorageStatus] PRIMARY KEY CLUSTERED ([TrlStorageStatusId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TrlStorageStatus] TO [public]
GO
GRANT INSERT ON  [dbo].[TrlStorageStatus] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TrlStorageStatus] TO [public]
GO
GRANT SELECT ON  [dbo].[TrlStorageStatus] TO [public]
GO
GRANT UPDATE ON  [dbo].[TrlStorageStatus] TO [public]
GO
