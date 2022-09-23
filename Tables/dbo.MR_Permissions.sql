CREATE TABLE [dbo].[MR_Permissions]
(
[perm_grantee] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[perm_object] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[perm_objectsource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[perm_objecttype] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[perm_reportname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_Permissions] ADD CONSTRAINT [PK_MR_Permissions] PRIMARY KEY CLUSTERED ([perm_grantee], [perm_object]) ON [PRIMARY]
GO
