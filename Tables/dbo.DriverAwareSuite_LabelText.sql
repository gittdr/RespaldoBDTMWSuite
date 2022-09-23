CREATE TABLE [dbo].[DriverAwareSuite_LabelText]
(
[FieldName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PresName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SortOrder] [int] NOT NULL,
[Feature] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ObjectName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ObjectType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DriverAwareSuite_LabelText] ADD CONSTRAINT [PK_DriverAwareSuite_LabelText] PRIMARY KEY CLUSTERED ([FieldName], [SortOrder], [Feature]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DriverAwareSuite_LabelText] TO [public]
GO
GRANT INSERT ON  [dbo].[DriverAwareSuite_LabelText] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DriverAwareSuite_LabelText] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverAwareSuite_LabelText] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverAwareSuite_LabelText] TO [public]
GO
