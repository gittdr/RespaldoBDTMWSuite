CREATE TABLE [dbo].[MR_SysTablePermissions]
(
[sysperm_loginorrole] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sysperm_object] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sysperm_protecttype] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sysperm_actiontype] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_SysTablePermissions] ADD CONSTRAINT [PK_MR_SysTablePermissions] PRIMARY KEY CLUSTERED ([sysperm_loginorrole], [sysperm_object], [sysperm_protecttype], [sysperm_actiontype]) ON [PRIMARY]
GO
