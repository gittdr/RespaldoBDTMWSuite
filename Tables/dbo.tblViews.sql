CREATE TABLE [dbo].[tblViews]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[ViewName] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OutBoundForm] [bit] NOT NULL,
[StoredProcSN] [int] NULL,
[TriggersReply] [bit] NOT NULL,
[ViewCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispXactLayer] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispXactViewType] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispXfcTag] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblViews] ADD CONSTRAINT [PK_tblViews_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ViewCode] ON [dbo].[tblViews] ([ViewCode]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[tblViews_ViewName_D]', N'[dbo].[tblViews].[ViewName]'
GO
EXEC sp_bindefault N'[dbo].[tblViews_Description_D]', N'[dbo].[tblViews].[Description]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblViews].[OutBoundForm]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblViews].[TriggersReply]'
GO
GRANT DELETE ON  [dbo].[tblViews] TO [public]
GO
GRANT INSERT ON  [dbo].[tblViews] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblViews] TO [public]
GO
GRANT SELECT ON  [dbo].[tblViews] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblViews] TO [public]
GO
