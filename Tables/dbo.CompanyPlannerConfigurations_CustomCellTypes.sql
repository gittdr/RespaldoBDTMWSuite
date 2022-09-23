CREATE TABLE [dbo].[CompanyPlannerConfigurations_CustomCellTypes]
(
[cpcct_Id] [int] NOT NULL IDENTITY(1, 1),
[cpcct_Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpcct_Path] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CompanyPlannerConfigurations_CustomCellTypes] TO [public]
GO
GRANT INSERT ON  [dbo].[CompanyPlannerConfigurations_CustomCellTypes] TO [public]
GO
GRANT SELECT ON  [dbo].[CompanyPlannerConfigurations_CustomCellTypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[CompanyPlannerConfigurations_CustomCellTypes] TO [public]
GO
