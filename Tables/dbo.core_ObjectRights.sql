CREATE TABLE [dbo].[core_ObjectRights]
(
[objt_objectid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[objt_propertyname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grp_groupid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestampq] [timestamp] NULL,
[id] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[core_ObjectRights] TO [public]
GO
GRANT INSERT ON  [dbo].[core_ObjectRights] TO [public]
GO
GRANT SELECT ON  [dbo].[core_ObjectRights] TO [public]
GO
GRANT UPDATE ON  [dbo].[core_ObjectRights] TO [public]
GO
