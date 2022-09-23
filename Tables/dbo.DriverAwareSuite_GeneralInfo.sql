CREATE TABLE [dbo].[DriverAwareSuite_GeneralInfo]
(
[dsat_key] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dsat_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dsat_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DriverAwareSuite_GeneralInfo] ADD CONSTRAINT [PK_DriverAwareSuite_GeneralInfo] PRIMARY KEY CLUSTERED ([dsat_key]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DriverAwareSuite_GeneralInfo] TO [public]
GO
GRANT INSERT ON  [dbo].[DriverAwareSuite_GeneralInfo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DriverAwareSuite_GeneralInfo] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverAwareSuite_GeneralInfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverAwareSuite_GeneralInfo] TO [public]
GO
