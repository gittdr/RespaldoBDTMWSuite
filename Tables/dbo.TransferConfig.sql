CREATE TABLE [dbo].[TransferConfig]
(
[TransferConfigId] [int] NOT NULL IDENTITY(1, 1),
[Description] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TransferTypeId] [tinyint] NOT NULL,
[DestinationTypeId] [tinyint] NOT NULL,
[PackageFolder] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProjectName] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PackageName] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServerName] [sys].[sysname] NOT NULL,
[MarkXFR] [bit] NOT NULL CONSTRAINT [DF__TransferC__MarkX__3C5BA2EE] DEFAULT ((1)),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__TransferC__Creat__3D4FC727] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TransferC__Creat__3E43EB60] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OutputPath] [nvarchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferConfig] ADD CONSTRAINT [PK_TransferConfig] PRIMARY KEY CLUSTERED ([TransferConfigId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferConfig] ADD CONSTRAINT [FK_TransferConfig_TransferDestinationType] FOREIGN KEY ([DestinationTypeId]) REFERENCES [dbo].[TransferDestinationType] ([DestinationTypeId])
GO
ALTER TABLE [dbo].[TransferConfig] ADD CONSTRAINT [FK_TransferConfig_TransferType] FOREIGN KEY ([TransferTypeId]) REFERENCES [dbo].[TransferType] ([TransferTypeId])
GO
GRANT DELETE ON  [dbo].[TransferConfig] TO [public]
GO
GRANT INSERT ON  [dbo].[TransferConfig] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TransferConfig] TO [public]
GO
GRANT SELECT ON  [dbo].[TransferConfig] TO [public]
GO
GRANT UPDATE ON  [dbo].[TransferConfig] TO [public]
GO
