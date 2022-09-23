CREATE TABLE [dbo].[tblForms]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[FormID] [int] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Forward] [bit] NOT NULL,
[DTCreated] [datetime] NULL,
[DTActivated] [datetime] NULL,
[DataSource] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Direction] [int] NULL,
[AllowUpdate] [int] NULL,
[Activate] [bit] NOT NULL,
[Status] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Version] [int] NULL,
[Rows] [int] NULL,
[Columns] [int] NULL,
[DateModified] [datetime] NULL,
[DefaultPriority] [int] NULL CONSTRAINT [DF__tblForms__Defaul__489AC854] DEFAULT (2),
[DefaultReceipt] [int] NULL CONSTRAINT [DF__tblForms__Defaul__4E53A1AA] DEFAULT (0),
[XactUpdateBack] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tblForms__XactUp__46584E5A] DEFAULT ('Y'),
[Comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormLocked] [int] NULL,
[ReplyFormID] [int] NULL,
[HideFromDisp] [int] NULL,
[BiDirectional] [int] NULL,
[ForcePriority] [int] NULL,
[MaxDelayMins] [int] NULL,
[UpdateMCommBack] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SendTO] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SendTODisabled] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSubForm] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblForms] ADD CONSTRAINT [PK_tblForms_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblForms].[FormID]'
GO
EXEC sp_bindefault N'[dbo].[tblForms_Name_D]', N'[dbo].[tblForms].[Name]'
GO
EXEC sp_bindefault N'[dbo].[tblForms_Description_D]', N'[dbo].[tblForms].[Description]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblForms].[Forward]'
GO
EXEC sp_bindefault N'[dbo].[tblForms_DTCreated_D]', N'[dbo].[tblForms].[DTCreated]'
GO
EXEC sp_bindefault N'[dbo].[tblForms_DataSource_D]', N'[dbo].[tblForms].[DataSource]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblForms].[Direction]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblForms].[AllowUpdate]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblForms].[Activate]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblForms].[Version]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblForms].[Rows]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblForms].[Columns]'
GO
GRANT DELETE ON  [dbo].[tblForms] TO [public]
GO
GRANT INSERT ON  [dbo].[tblForms] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblForms] TO [public]
GO
GRANT SELECT ON  [dbo].[tblForms] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblForms] TO [public]
GO
