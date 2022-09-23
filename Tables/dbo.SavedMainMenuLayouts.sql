CREATE TABLE [dbo].[SavedMainMenuLayouts]
(
[LayoutID] [bigint] NOT NULL IDENTITY(1, 1),
[LayoutName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[XMLConfiguration] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SavedMainMenuLayouts_ModifiedDate] DEFAULT (getdate()),
[LayoutObject] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[layoutOwner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsGlobalDefault] [bit] NOT NULL CONSTRAINT [DF_SavedMainMenuLayout_IsGlobalDefault_1] DEFAULT ((0)),
[LockUserEdit] [bit] NOT NULL CONSTRAINT [DF_smml_LockUserEdit] DEFAULT ((0)),
[ModuleId] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SavedMainMenuLayouts] ADD CONSTRAINT [PK_SavedMainMenuLayouts_1] PRIMARY KEY CLUSTERED ([LayoutID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SavedMainMenuLayouts] TO [public]
GO
GRANT INSERT ON  [dbo].[SavedMainMenuLayouts] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SavedMainMenuLayouts] TO [public]
GO
GRANT SELECT ON  [dbo].[SavedMainMenuLayouts] TO [public]
GO
GRANT UPDATE ON  [dbo].[SavedMainMenuLayouts] TO [public]
GO
