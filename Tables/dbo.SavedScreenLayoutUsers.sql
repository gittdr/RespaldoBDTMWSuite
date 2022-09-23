CREATE TABLE [dbo].[SavedScreenLayoutUsers]
(
[UserID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LayoutID] [bigint] NOT NULL,
[IsDefault] [bit] NOT NULL CONSTRAINT [DF_SavedScreenLayoutUsers_IsDefault_1] DEFAULT ((0)),
[IsGroup] [bit] NOT NULL CONSTRAINT [DF_SavedScreenLayoutUsers_IsGroup_1] DEFAULT ((0)),
[created] [datetime] NULL,
[createdby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated] [datetime] NULL,
[updatedby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SavedScreenLayoutUsers] ADD CONSTRAINT [PK_SavedScreenLayoutUsers] PRIMARY KEY CLUSTERED ([IsGroup], [UserID], [LayoutID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SavedScreenLayoutUsers] TO [public]
GO
GRANT INSERT ON  [dbo].[SavedScreenLayoutUsers] TO [public]
GO
GRANT SELECT ON  [dbo].[SavedScreenLayoutUsers] TO [public]
GO
GRANT UPDATE ON  [dbo].[SavedScreenLayoutUsers] TO [public]
GO
