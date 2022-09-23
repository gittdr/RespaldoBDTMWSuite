CREATE TABLE [dbo].[AnalyticalAccountingSetup]
(
[AAS_id] [int] NOT NULL IDENTITY(1, 1),
[AAS_TrcId] [int] NOT NULL,
[AAS_TrlId] [int] NOT NULL,
[AAS_DrvId] [int] NOT NULL,
[AAS_TrcIdInvoicing] [int] NOT NULL,
[AAS_TrlIdInvoicing] [int] NOT NULL,
[AAS_DrvIdInvoicing] [int] NOT NULL,
[AAS_TrcIdAP] [int] NOT NULL,
[AAS_TrlIdAP] [int] NOT NULL,
[AAS_DrvIdAP] [int] NOT NULL,
[AAS_TrcIdPayroll] [int] NOT NULL,
[AAS_TrlIdPayroll] [int] NOT NULL,
[AAS_DrvIdPayroll] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AnalyticalAccountingSetup] ADD CONSTRAINT [pk_AAS_id] PRIMARY KEY CLUSTERED ([AAS_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AnalyticalAccountingSetup] TO [public]
GO
GRANT INSERT ON  [dbo].[AnalyticalAccountingSetup] TO [public]
GO
GRANT REFERENCES ON  [dbo].[AnalyticalAccountingSetup] TO [public]
GO
GRANT SELECT ON  [dbo].[AnalyticalAccountingSetup] TO [public]
GO
GRANT UPDATE ON  [dbo].[AnalyticalAccountingSetup] TO [public]
GO
