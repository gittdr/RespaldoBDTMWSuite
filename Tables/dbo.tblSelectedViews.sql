CREATE TABLE [dbo].[tblSelectedViews]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[ViewNumber] [int] NULL,
[FormSN] [int] NULL,
[Sequence] [int] NULL,
[ReplyFormSN] [int] NULL,
[GroupName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSelectedViews] ADD CONSTRAINT [PK_tblSelectedViews_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblFormstblSelectedViews] ON [dbo].[tblSelectedViews] ([FormSN]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblViewstblSelectedViews1] ON [dbo].[tblSelectedViews] ([ViewNumber]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSelectedViews] ADD CONSTRAINT [FK__Temporary__FormS__587C2A62] FOREIGN KEY ([FormSN]) REFERENCES [dbo].[tblForms] ([SN])
GO
ALTER TABLE [dbo].[tblSelectedViews] ADD CONSTRAINT [FK__Temporary__ViewN__57880629] FOREIGN KEY ([ViewNumber]) REFERENCES [dbo].[tblViews] ([SN])
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblSelectedViews].[FormSN]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblSelectedViews].[Sequence]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblSelectedViews].[ReplyFormSN]'
GO
GRANT DELETE ON  [dbo].[tblSelectedViews] TO [public]
GO
GRANT INSERT ON  [dbo].[tblSelectedViews] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblSelectedViews] TO [public]
GO
GRANT SELECT ON  [dbo].[tblSelectedViews] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblSelectedViews] TO [public]
GO
