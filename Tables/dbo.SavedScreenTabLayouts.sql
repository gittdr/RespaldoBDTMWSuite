CREATE TABLE [dbo].[SavedScreenTabLayouts]
(
[LayoutID] [bigint] NOT NULL,
[LayoutObject] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[XMLConfiguration] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SavedScreenTabLayouts_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SavedScreenTabLayouts] ADD CONSTRAINT [PK_SavedScreenTabLayouts] PRIMARY KEY CLUSTERED ([LayoutID], [LayoutObject]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SavedScreenTabLayouts] TO [public]
GO
GRANT INSERT ON  [dbo].[SavedScreenTabLayouts] TO [public]
GO
GRANT SELECT ON  [dbo].[SavedScreenTabLayouts] TO [public]
GO
GRANT UPDATE ON  [dbo].[SavedScreenTabLayouts] TO [public]
GO
