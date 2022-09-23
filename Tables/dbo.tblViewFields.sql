CREATE TABLE [dbo].[tblViewFields]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[ViewNumber] [int] NULL,
[FieldName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsRepeating] [bit] NOT NULL,
[FieldNumber] [int] NULL,
[FileNumber] [smallint] NULL,
[Required] [smallint] NULL,
[BusinessRule] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VerifyFile] [smallint] NULL,
[VerifyJoinField] [int] NULL,
[TTSFieldName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLTableName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLFieldName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultLength] [int] NULL,
[DefaultType] [int] NULL,
[DisplayedFieldName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispXfcTag] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BusinessRuleType] [int] NULL,
[Comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultPrefix] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultSuffix] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Default] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClearWhenFinished] [int] NULL CONSTRAINT [DF__tblViewFi__Clear__13697456] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblViewFields] ADD CONSTRAINT [PK_tblViewFields_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ViewGroup] ON [dbo].[tblViewFields] ([ViewNumber]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblViewFields] ADD CONSTRAINT [FK__Temporary__ViewN__5C4CBB46] FOREIGN KEY ([ViewNumber]) REFERENCES [dbo].[tblViews] ([SN])
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblViewFields].[ViewNumber]'
GO
EXEC sp_bindefault N'[dbo].[tblViewFields_FieldName_D]', N'[dbo].[tblViewFields].[FieldName]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblViewFields].[IsRepeating]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblViewFields].[FieldNumber]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblViewFields].[FileNumber]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblViewFields].[Required]'
GO
EXEC sp_bindefault N'[dbo].[tblViewFields_BusinessRule_D]', N'[dbo].[tblViewFields].[BusinessRule]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblViewFields].[VerifyFile]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblViewFields].[VerifyJoinField]'
GO
EXEC sp_bindefault N'[dbo].[tblViewFields_TTSFieldName_D]', N'[dbo].[tblViewFields].[TTSFieldName]'
GO
EXEC sp_bindefault N'[dbo].[tblViewFields_SQLTableName_D]', N'[dbo].[tblViewFields].[SQLTableName]'
GO
EXEC sp_bindefault N'[dbo].[tblViewFields_SQLFieldName_D]', N'[dbo].[tblViewFields].[SQLFieldName]'
GO
EXEC sp_bindefault N'[dbo].[tblViewFields_DefaultLength_]', N'[dbo].[tblViewFields].[DefaultLength]'
GO
EXEC sp_bindefault N'[dbo].[tblViewFields_DefaultType_D]', N'[dbo].[tblViewFields].[DefaultType]'
GO
GRANT DELETE ON  [dbo].[tblViewFields] TO [public]
GO
GRANT INSERT ON  [dbo].[tblViewFields] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblViewFields] TO [public]
GO
GRANT SELECT ON  [dbo].[tblViewFields] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblViewFields] TO [public]
GO
