CREATE TABLE [dbo].[CompanyContractMgmt]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultRateMode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TPLBillingEligible] [bit] NOT NULL,
[TPLBenchmarkEligible] [bit] NOT NULL,
[TPLGainShareEligible] [bit] NOT NULL,
[GainShareItemCode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GainShareSavingsOnly] [bit] NOT NULL,
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime2] NULL,
[LastUpdatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDate] [datetime2] NULL,
[AllocationEligible] [bit] NULL,
[ReconcileToleranceUnit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CompanyCo__Recon__567E316C] DEFAULT ('N'),
[ReconcileToleranceValue] [money] NOT NULL CONSTRAINT [DF__CompanyCo__Recon__577255A5] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyContractMgmt] ADD CONSTRAINT [PK_CompanyContractMgmt] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyContractMgmt] ADD CONSTRAINT [UK_CompanyContractMgmt_CMPID] UNIQUE NONCLUSTERED ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CompanyContractMgmt] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyContractMgmt] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CompanyContractMgmt] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyContractMgmt] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyContractMgmt] TO [public]
GO
