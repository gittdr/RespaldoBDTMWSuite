CREATE TABLE [dbo].[SavedScreenLayouts]
(
[LayoutID] [bigint] NOT NULL IDENTITY(1, 1),
[LayoutName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[XMLConfiguration] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SavedScreenLayouts_ModifiedDate] DEFAULT (getdate()),
[LayoutObject] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[layoutOwner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsGlobalDefault] [bit] NOT NULL CONSTRAINT [DF_SavedScreenLayout_IsGlobalDefault_1] DEFAULT ((0)),
[LockUserEdit] [bit] NOT NULL CONSTRAINT [DF_ssl_LockUserEdit] DEFAULT ((0)),
[ModuleId] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SavedScreenLayouts] ADD CONSTRAINT [PK_SavedScreenLayouts_1] PRIMARY KEY CLUSTERED ([LayoutID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SavedScreenLayouts] TO [public]
GO
GRANT INSERT ON  [dbo].[SavedScreenLayouts] TO [public]
GO
GRANT SELECT ON  [dbo].[SavedScreenLayouts] TO [public]
GO
GRANT UPDATE ON  [dbo].[SavedScreenLayouts] TO [public]
GO
