CREATE TABLE [dbo].[CompanyFreightBillOutputRestriction]
(
[CompanyFreightBillOutputRestrictionId] [int] NOT NULL IDENTITY(1, 1),
[CreatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CompanyFr__Creat__6F500C53] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__CompanyFr__Creat__7044308C] DEFAULT (getdate()),
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__CompanyFr__LastU__713854C5] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CompanyFr__LastU__722C78FE] DEFAULT (suser_name()),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FreightBillOutputRestrictionId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyFreightBillOutputRestriction] ADD CONSTRAINT [PK_dbo.CompanyFreightBillOutputRestriction] PRIMARY KEY CLUSTERED ([CompanyFreightBillOutputRestrictionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_cmp_id] ON [dbo].[CompanyFreightBillOutputRestriction] ([cmp_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FreightBillOutputRestrictionId] ON [dbo].[CompanyFreightBillOutputRestriction] ([FreightBillOutputRestrictionId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyFreightBillOutputRestriction] ADD CONSTRAINT [FK_dbo.CompanyFreightBillOutputRestriction_dbo.Company_cmp_id] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[CompanyFreightBillOutputRestriction] ADD CONSTRAINT [FK_dbo.CompanyFreightBillOutputRestriction_dbo.FreightBillOutputRestriction_FreightBillOutputRestrictionId] FOREIGN KEY ([FreightBillOutputRestrictionId]) REFERENCES [dbo].[FreightBillOutputRestriction] ([FreightBillOutputRestrictionId])
GO
GRANT DELETE ON  [dbo].[CompanyFreightBillOutputRestriction] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyFreightBillOutputRestriction] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyFreightBillOutputRestriction] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyFreightBillOutputRestriction] TO [public]
GO
