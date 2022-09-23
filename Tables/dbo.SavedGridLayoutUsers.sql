CREATE TABLE [dbo].[SavedGridLayoutUsers]
(
[UserID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LayoutID] [bigint] NOT NULL,
[IsDefault] [bit] NOT NULL CONSTRAINT [DF_SavedGridLayoutUsers_IsDefault_1] DEFAULT ((0)),
[IsGroup] [bit] NOT NULL CONSTRAINT [DF_SavedGridLayoutUsers_IsGroup_1] DEFAULT ((0)),
[created] [datetime] NULL,
[createdby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated] [datetime] NULL,
[updatedby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SavedGridLayoutUsers] ADD CONSTRAINT [PK_SavedGridLayoutUsers] UNIQUE NONCLUSTERED ([UserID], [IsGroup], [LayoutID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SavedGridLayoutUsers] TO [public]
GO
GRANT INSERT ON  [dbo].[SavedGridLayoutUsers] TO [public]
GO
GRANT SELECT ON  [dbo].[SavedGridLayoutUsers] TO [public]
GO
GRANT UPDATE ON  [dbo].[SavedGridLayoutUsers] TO [public]
GO
