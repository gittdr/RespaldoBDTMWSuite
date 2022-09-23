CREATE TABLE [dbo].[ResNowMapSetup]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[sn] [int] NOT NULL,
[lat] [float] NULL,
[long] [float] NULL,
[zoom] [int] NULL,
[latlong] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNowMapSetup] ADD CONSTRAINT [AutoPK_ResNowMapSetup_id] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNowMapSetup] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNowMapSetup] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNowMapSetup] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNowMapSetup] TO [public]
GO
