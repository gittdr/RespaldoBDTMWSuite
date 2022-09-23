CREATE TABLE [dbo].[core_PropertyRights]
(
[id] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[objt_objectid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[objt_propertyname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grp_groupid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[writebln] [bit] NOT NULL,
[readbln] [bit] NOT NULL,
[timestampq] [timestamp] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[core_PropertyRights] TO [public]
GO
GRANT INSERT ON  [dbo].[core_PropertyRights] TO [public]
GO
GRANT SELECT ON  [dbo].[core_PropertyRights] TO [public]
GO
GRANT UPDATE ON  [dbo].[core_PropertyRights] TO [public]
GO
