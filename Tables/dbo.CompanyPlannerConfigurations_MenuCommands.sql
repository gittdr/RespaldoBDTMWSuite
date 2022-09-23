CREATE TABLE [dbo].[CompanyPlannerConfigurations_MenuCommands]
(
[cpmc_Id] [int] NOT NULL IDENTITY(1, 1),
[cpd_Id] [int] NULL,
[cpmc_menuName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpmc_isButton] [bit] NULL,
[cpmc_CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpmc_CreatedOn] [datetime] NULL,
[cpmc_LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpmc_LastUpdatedOn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyPlannerConfigurations_MenuCommands] ADD CONSTRAINT [pk_CompanyPlannerConfigurations_MenuCommands] PRIMARY KEY CLUSTERED ([cpmc_Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_CompanyPlannerConfigurations_MenuCommands_cpdId] ON [dbo].[CompanyPlannerConfigurations_MenuCommands] ([cpd_Id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CompanyPlannerConfigurations_MenuCommands] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyPlannerConfigurations_MenuCommands] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyPlannerConfigurations_MenuCommands] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyPlannerConfigurations_MenuCommands] TO [public]
GO
