CREATE TABLE [dbo].[CompanyDedicatedBillOutputRestriction]
(
[CompanyDedicatedBillOutputRestrictionId] [int] NOT NULL IDENTITY(1, 1),
[DedicatedBillOutputRestrictionId] [int] NOT NULL,
[CompanyId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_CompanyDedicatedBillOutputRestriction_CreatedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CompanyDedicatedBillOutputRestriction_CreatedBy] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyDedicatedBillOutputRestriction] ADD CONSTRAINT [PK_CompanyDedicatedBillOutputRestriction] PRIMARY KEY CLUSTERED ([CompanyDedicatedBillOutputRestrictionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CompanyDedicatedBillOutputRestriction_CompanyId] ON [dbo].[CompanyDedicatedBillOutputRestriction] ([CompanyId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CompanyDedicatedBillOutputRestriction_DedicatedBillOutputRestrictionId] ON [dbo].[CompanyDedicatedBillOutputRestriction] ([DedicatedBillOutputRestrictionId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyDedicatedBillOutputRestriction] ADD CONSTRAINT [FK_CompanyDedicatedBillOutputRestriction_DedicatedBillOutputRestriction_DedicatedBillOutputRestrictionId] FOREIGN KEY ([DedicatedBillOutputRestrictionId]) REFERENCES [dbo].[DedicatedBillOutputRestriction] ([DedicatedBillOutputRestrictionId])
GO
GRANT DELETE ON  [dbo].[CompanyDedicatedBillOutputRestriction] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyDedicatedBillOutputRestriction] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CompanyDedicatedBillOutputRestriction] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyDedicatedBillOutputRestriction] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyDedicatedBillOutputRestriction] TO [public]
GO
