CREATE TABLE [dbo].[DriverAwareSuite_ColumnConfiguration]
(
[ColumnName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnOrder] [int] NOT NULL,
[UserID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GroupID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DriverAwareSuite_ColumnConfiguration] ADD CONSTRAINT [PK_DriverAwareSuite_ColumnConfiguration] PRIMARY KEY CLUSTERED ([ColumnName], [UserID], [GroupID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DriverAwareSuite_ColumnConfiguration] TO [public]
GO
GRANT INSERT ON  [dbo].[DriverAwareSuite_ColumnConfiguration] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DriverAwareSuite_ColumnConfiguration] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverAwareSuite_ColumnConfiguration] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverAwareSuite_ColumnConfiguration] TO [public]
GO
