CREATE TABLE [dbo].[WebLicenseKeys]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[PackageName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EnvironmentType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Valid] [bit] NULL,
[CreatedOn] [datetime] NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedOn] [datetime] NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LicenseKey] [image] NULL,
[LicensedModules] [image] NULL,
[AcceptedModules] [image] NULL,
[DeclinedModules] [image] NULL,
[LicenseLog] [image] NULL,
[LicenseData] [image] NULL,
[ModuleName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebLicenseKeys] ADD CONSTRAINT [PK__WebLicen__3214EC07293BCC4B] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebLicenseKeys] ADD CONSTRAINT [AK_PackageName_ModuleName] UNIQUE NONCLUSTERED ([PackageName], [ModuleName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WebLicenseKeys] TO [public]
GO
GRANT INSERT ON  [dbo].[WebLicenseKeys] TO [public]
GO
GRANT REFERENCES ON  [dbo].[WebLicenseKeys] TO [public]
GO
GRANT SELECT ON  [dbo].[WebLicenseKeys] TO [public]
GO
GRANT UPDATE ON  [dbo].[WebLicenseKeys] TO [public]
GO
