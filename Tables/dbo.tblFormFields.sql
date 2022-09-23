CREATE TABLE [dbo].[tblFormFields]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[ControlNumber] [smallint] NULL,
[FormSN] [int] NULL,
[Row] [smallint] NULL,
[Col] [smallint] NULL,
[Len] [smallint] NULL,
[Type] [int] NULL,
[Mandatory] [bit] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultValue] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Visible] [bit] NOT NULL,
[Comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsComment] [int] NULL,
[MaxChars] [int] NULL,
[Height] [int] NULL,
[HeaderFlag] [int] NULL CONSTRAINT [DF__tblformfi__Heade__5A5F4707] DEFAULT (0),
[SubjectFlag] [int] NULL,
[Prompt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinValue] [float] NULL,
[MaxValue] [float] NULL,
[FormatStr] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BranchTo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayOnly] [int] NULL,
[Editability] [int] NULL,
[DefaultPrefix] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultSuffix] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispatcherOnly] [int] NULL,
[NoPreview] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tblFormFields_ITrig] ON [dbo].[tblFormFields] FOR INSERT AS
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
CREATE TRIGGER [dbo].[tblFormFields_UTrig] ON [dbo].[tblFormFields] FOR UPDATE AS
				/*
				 * PREVENT NULL VALUES IN 'FormSN'
				 */
				IF (SELECT Count(*) FROM inserted WHERE FormSN IS NULL) > 0
					BEGIN
						RAISERROR('Field ''FormSN'' cannot contain a null value.', 16,1)  -- PTS 64044
						ROLLBACK TRANSACTION
					END
GO
ALTER TABLE [dbo].[tblFormFields] ADD CONSTRAINT [PK_tblFormFields_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblFormstblFormFields] ON [dbo].[tblFormFields] ([FormSN]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FormSN_Row_Col] ON [dbo].[tblFormFields] ([FormSN], [Row], [Col]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblFormFields] ADD CONSTRAINT [FK__Temporary__FormS__4F27CA52] FOREIGN KEY ([FormSN]) REFERENCES [dbo].[tblForms] ([SN])
GO
GRANT DELETE ON  [dbo].[tblFormFields] TO [public]
GO
GRANT INSERT ON  [dbo].[tblFormFields] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblFormFields] TO [public]
GO
GRANT SELECT ON  [dbo].[tblFormFields] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblFormFields] TO [public]
GO
