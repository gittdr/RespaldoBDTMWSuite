CREATE TABLE [dbo].[Gainshare]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Actual] [decimal] (12, 6) NOT NULL,
[Savings] [decimal] (12, 6) NOT NULL,
[GSRunningTotal] [decimal] (12, 6) NOT NULL,
[AmountEligibleForBenchmarkSavings] [decimal] (12, 6) NOT NULL,
[Charge] [decimal] (12, 6) NOT NULL,
[ChargeRatio] [decimal] (12, 6) NOT NULL,
[EffectiveDate] [datetime] NOT NULL,
[CampaignId] [int] NULL,
[TariffNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Gainshare] ADD CONSTRAINT [PK_Gainshare] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Gainshare] ADD CONSTRAINT [FK_CompanyGainShareThreshold_GainShare] FOREIGN KEY ([CampaignId]) REFERENCES [dbo].[CompanyGainShareThreshold] ([ID])
GO
GRANT DELETE ON  [dbo].[Gainshare] TO [public]
GO
GRANT INSERT ON  [dbo].[Gainshare] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Gainshare] TO [public]
GO
GRANT SELECT ON  [dbo].[Gainshare] TO [public]
GO
GRANT UPDATE ON  [dbo].[Gainshare] TO [public]
GO
