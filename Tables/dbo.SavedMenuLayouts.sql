CREATE TABLE [dbo].[SavedMenuLayouts]
(
[LayoutID] [bigint] NOT NULL,
[XMLConfiguration] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SavedMenuLayouts_ModifiedDate] DEFAULT (getdate()),
[SheetXMLConfiguration] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DialogXMLConfiguration] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SavedMenuLayouts] ADD CONSTRAINT [PK_SavedMenuLayouts] PRIMARY KEY CLUSTERED ([LayoutID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SavedMenuLayouts] TO [public]
GO
GRANT INSERT ON  [dbo].[SavedMenuLayouts] TO [public]
GO
GRANT SELECT ON  [dbo].[SavedMenuLayouts] TO [public]
GO
GRANT UPDATE ON  [dbo].[SavedMenuLayouts] TO [public]
GO
