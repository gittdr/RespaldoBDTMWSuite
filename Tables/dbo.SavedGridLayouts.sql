CREATE TABLE [dbo].[SavedGridLayouts]
(
[LayoutID] [bigint] NOT NULL IDENTITY(1, 1),
[LayoutName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[XMLConfiguration] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsGroup] [bit] NOT NULL CONSTRAINT [DF_SavedGridLayouts_IsGroup] DEFAULT ((0)),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SavedGridLayouts_ModifiedDate] DEFAULT (getdate()),
[LayoutObject] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[layoutOwner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[xmlColumns] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LimitColumns] [bit] NOT NULL CONSTRAINT [LimitColumnsDefaultValue] DEFAULT ((0)),
[IsGlobalDefault] [bit] NOT NULL CONSTRAINT [DF_SavedGridLayout_IsGlobalDefault_1] DEFAULT ((0)),
[pbc_id] [int] NULL,
[BoardType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ViewName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SavedGridLayouts] ADD CONSTRAINT [PK_SavedGridLayouts_1] PRIMARY KEY CLUSTERED ([LayoutID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SavedGridLayouts] TO [public]
GO
GRANT INSERT ON  [dbo].[SavedGridLayouts] TO [public]
GO
GRANT SELECT ON  [dbo].[SavedGridLayouts] TO [public]
GO
GRANT UPDATE ON  [dbo].[SavedGridLayouts] TO [public]
GO
