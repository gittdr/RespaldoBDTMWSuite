CREATE TABLE [dbo].[SavedMainMenuLayoutUsers]
(
[UserID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LayoutID] [bigint] NOT NULL,
[IsDefault] [bit] NOT NULL CONSTRAINT [DF_SavedMainMenuLayoutUsers_IsDefault_1] DEFAULT ((0)),
[IsGroup] [bit] NOT NULL CONSTRAINT [DF_SavedMainMenuLayoutUsers_IsGroup_1] DEFAULT ((0)),
[created] [datetime] NULL,
[createdby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated] [datetime] NULL,
[updatedby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SavedMainMenuLayoutUsers] ADD CONSTRAINT [PK_SavedMainMenuLayoutUsers] PRIMARY KEY CLUSTERED ([IsGroup], [UserID], [LayoutID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SavedMainMenuLayoutUsers] TO [public]
GO
GRANT INSERT ON  [dbo].[SavedMainMenuLayoutUsers] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SavedMainMenuLayoutUsers] TO [public]
GO
GRANT SELECT ON  [dbo].[SavedMainMenuLayoutUsers] TO [public]
GO
GRANT UPDATE ON  [dbo].[SavedMainMenuLayoutUsers] TO [public]
GO
