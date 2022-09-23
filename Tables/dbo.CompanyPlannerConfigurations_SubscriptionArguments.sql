CREATE TABLE [dbo].[CompanyPlannerConfigurations_SubscriptionArguments]
(
[cpsa_Id] [int] NOT NULL IDENTITY(1, 1),
[cps_Id] [int] NOT NULL,
[cpsa_argument] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpsa_argumentMap] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpsa_sequence] [int] NOT NULL,
[cpsa_created] [datetime] NULL,
[cpsa_created_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpsa_updated] [datetime] NULL,
[cpsa_updated_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cps_id_NonClustered_NonUnique] ON [dbo].[CompanyPlannerConfigurations_SubscriptionArguments] ([cps_Id]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [cpsa_id_Clustered_Unique] ON [dbo].[CompanyPlannerConfigurations_SubscriptionArguments] ([cpsa_Id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CompanyPlannerConfigurations_SubscriptionArguments] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyPlannerConfigurations_SubscriptionArguments] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyPlannerConfigurations_SubscriptionArguments] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyPlannerConfigurations_SubscriptionArguments] TO [public]
GO
