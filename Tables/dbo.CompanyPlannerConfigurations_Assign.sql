CREATE TABLE [dbo].[CompanyPlannerConfigurations_Assign]
(
[cph_id] [int] NULL,
[AssignType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssignValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpa_id] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyPlannerConfigurations_Assign] ADD CONSTRAINT [pk_CompanyPlannerConfigurations_Assign] PRIMARY KEY CLUSTERED ([cpa_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CompanyPlannerConfigurations_Assign] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyPlannerConfigurations_Assign] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyPlannerConfigurations_Assign] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyPlannerConfigurations_Assign] TO [public]
GO
