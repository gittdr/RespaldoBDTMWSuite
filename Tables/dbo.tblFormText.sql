CREATE TABLE [dbo].[tblFormText]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[ControlNumber] [smallint] NULL,
[FormSN] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Row] [smallint] NULL,
[Col] [smallint] NULL,
[Len] [smallint] NULL,
[Text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Caption] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Visible] [bit] NOT NULL,
[DispatcherOnly] [int] NULL,
[NoPreview] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tblFormText_ITrig] ON [dbo].[tblFormText] FOR INSERT AS
				/*
					* PREVENT NULL VALUES IN 'FormSN'
					*/
				IF (SELECT Count(*) FROM inserted WHERE FormSN IS NULL) > 0
					BEGIN
						RAISERROR('Field ''FormSN'' cannot contain a null value.', 16,1)  -- PTS 64044
						ROLLBACK TRANSACTION
					END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tblFormText_UTrig] ON [dbo].[tblFormText] FOR UPDATE AS
				/*
				 * PREVENT NULL VALUES IN 'FormSN'
				 */
				IF (SELECT Count(*) FROM inserted WHERE FormSN IS NULL) > 0
					BEGIN
						RAISERROR ('Field ''FormSN'' cannot contain a null value.', 16,1)  -- PTS 64044
						ROLLBACK TRANSACTION
					END
GO
ALTER TABLE [dbo].[tblFormText] ADD CONSTRAINT [PK_tblFormText_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblFormTextFormID] ON [dbo].[tblFormText] ([FormSN]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblFormText] ADD CONSTRAINT [FK__Temporary__FormS__55D4C7E1] FOREIGN KEY ([FormSN]) REFERENCES [dbo].[tblForms] ([SN])
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblFormText].[ControlNumber]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblFormText].[FormSN]'
GO
EXEC sp_bindefault N'[dbo].[tblFormText_Name_D]', N'[dbo].[tblFormText].[Name]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblFormText].[Row]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblFormText].[Col]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblFormText].[Len]'
GO
EXEC sp_bindefault N'[dbo].[tblFormText_Text_D]', N'[dbo].[tblFormText].[Text]'
GO
EXEC sp_bindefault N'[dbo].[tblFormText_Caption_D]', N'[dbo].[tblFormText].[Caption]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblFormText].[Visible]'
GO
GRANT DELETE ON  [dbo].[tblFormText] TO [public]
GO
GRANT INSERT ON  [dbo].[tblFormText] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblFormText] TO [public]
GO
GRANT SELECT ON  [dbo].[tblFormText] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblFormText] TO [public]
GO
