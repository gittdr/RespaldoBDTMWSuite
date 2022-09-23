CREATE TABLE [dbo].[CompanyPlannerConfigurations_Subscription]
(
[cps_Id] [int] NOT NULL IDENTITY(1, 1),
[cpd_Id] [int] NULL,
[cps_publisher_cpd_Id] [int] NOT NULL,
[cps_eventType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpmc_Id] [int] NULL,
[cps_actionType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cps_CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cps_CreatedOn] [datetime] NULL,
[cps_LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cps_LastUpdatedOn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyPlannerConfigurations_Subscription] ADD CONSTRAINT [pk_CompanyPlannerConfigurations_Subscription] PRIMARY KEY CLUSTERED ([cps_Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_CompanyPlannerConfigurations_Subscription_cpdId] ON [dbo].[CompanyPlannerConfigurations_Subscription] ([cpd_Id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CompanyPlannerConfigurations_Subscription] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyPlannerConfigurations_Subscription] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyPlannerConfigurations_Subscription] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyPlannerConfigurations_Subscription] TO [public]
GO
