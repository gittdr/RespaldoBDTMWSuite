CREATE TABLE [dbo].[MobileCommFleets]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[AssetType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AssetId] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MessageGroup] [int] NOT NULL CONSTRAINT [DF__MobileCom__Messa__6ED50FB4] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommFleets] ADD CONSTRAINT [PK_MobileCommFleets] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [NonClusteredIndex-AssetType_AssetId] ON [dbo].[MobileCommFleets] ([SN]) INCLUDE ([AssetType], [AssetId]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MobileCommFleets] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommFleets] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommFleets] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommFleets] TO [public]
GO
