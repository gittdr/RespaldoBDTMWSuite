CREATE TABLE [dbo].[DriverAwareSuite_MAC17]
(
[trc_driver] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MAC17] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DriverAwareSuite_MAC17] TO [public]
GO
GRANT INSERT ON  [dbo].[DriverAwareSuite_MAC17] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DriverAwareSuite_MAC17] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverAwareSuite_MAC17] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverAwareSuite_MAC17] TO [public]
GO
