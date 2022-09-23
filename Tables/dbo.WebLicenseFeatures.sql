CREATE TABLE [dbo].[WebLicenseFeatures]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[WebLicenseKeyId] [int] NOT NULL,
[CreatedOn] [datetime] NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedOn] [datetime] NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Feature] [image] NOT NULL,
[FeatureModules] [image] NULL,
[FeatureLog] [image] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebLicenseFeatures] ADD CONSTRAINT [PK__WebLicen__3214EC07C1A77A55] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebLicenseFeatures] ADD CONSTRAINT [FK_dbo.WebLicenseFeatures_dbo.WebLicenseKeys_WebLicenseKeyId] FOREIGN KEY ([WebLicenseKeyId]) REFERENCES [dbo].[WebLicenseKeys] ([Id])
GO
GRANT DELETE ON  [dbo].[WebLicenseFeatures] TO [public]
GO
GRANT INSERT ON  [dbo].[WebLicenseFeatures] TO [public]
GO
GRANT REFERENCES ON  [dbo].[WebLicenseFeatures] TO [public]
GO
GRANT SELECT ON  [dbo].[WebLicenseFeatures] TO [public]
GO
GRANT UPDATE ON  [dbo].[WebLicenseFeatures] TO [public]
GO
