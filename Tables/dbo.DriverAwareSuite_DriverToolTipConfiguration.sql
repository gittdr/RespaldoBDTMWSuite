CREATE TABLE [dbo].[DriverAwareSuite_DriverToolTipConfiguration]
(
[ColumnName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToolTipRowPosition] [int] NULL,
[UserID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DriverAwareSuite_DriverToolTipConfiguration] ADD CONSTRAINT [PK_DriverAwareSuite_DriverToolTipConfiguration] PRIMARY KEY CLUSTERED ([ColumnName], [UserID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DriverAwareSuite_DriverToolTipConfiguration] TO [public]
GO
GRANT INSERT ON  [dbo].[DriverAwareSuite_DriverToolTipConfiguration] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DriverAwareSuite_DriverToolTipConfiguration] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverAwareSuite_DriverToolTipConfiguration] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverAwareSuite_DriverToolTipConfiguration] TO [public]
GO
