CREATE TABLE [dbo].[CompanyMasterBillOutputRestriction]
(
[CompanyMasterBillOutputRestrictionId] [int] NOT NULL IDENTITY(1, 1),
[CreatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CompanyMa__Creat__5E258051] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__CompanyMa__Creat__5F19A48A] DEFAULT (getdate()),
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__CompanyMa__LastU__600DC8C3] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CompanyMa__LastU__6101ECFC] DEFAULT (suser_name()),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MasterBillOutputRestrictionId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyMasterBillOutputRestriction] ADD CONSTRAINT [PK_dbo.CompanyMasterBillOutputRestriction] PRIMARY KEY CLUSTERED ([CompanyMasterBillOutputRestrictionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_cmp_id] ON [dbo].[CompanyMasterBillOutputRestriction] ([cmp_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MasterBillOutputRestrictionId] ON [dbo].[CompanyMasterBillOutputRestriction] ([MasterBillOutputRestrictionId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyMasterBillOutputRestriction] ADD CONSTRAINT [FK_dbo.CompanyMasterBillOutputRestriction_dbo.Company_cmp_id] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[CompanyMasterBillOutputRestriction] ADD CONSTRAINT [FK_dbo.CompanyMasterBillOutputRestriction_dbo.MasterBillOutputRestriction_MasterBillOutputRestrictionId] FOREIGN KEY ([MasterBillOutputRestrictionId]) REFERENCES [dbo].[MasterBillOutputRestriction] ([MasterBillOutputRestrictionId])
GO
GRANT DELETE ON  [dbo].[CompanyMasterBillOutputRestriction] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyMasterBillOutputRestriction] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyMasterBillOutputRestriction] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyMasterBillOutputRestriction] TO [public]
GO
