CREATE TABLE [dbo].[tblHWMStatusCodes]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[StatusCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatusText] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Format] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[XMITType] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Link] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Used] [bit] NOT NULL,
[Header] [bit] NOT NULL,
[FormID] [int] NULL,
[FieldLength] [int] NULL,
[Protected] [bit] NOT NULL,
[Version] [int] NULL,
[ToSend] [bit] NOT NULL,
[FieldCN] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHWMStatusCodes] ADD CONSTRAINT [PK_tblHWMStatusCodes_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FormID] ON [dbo].[tblHWMStatusCodes] ([FormID]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [StatusCode] ON [dbo].[tblHWMStatusCodes] ([StatusCode]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblHWMStatusCodes].[Used]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblHWMStatusCodes].[Header]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblHWMStatusCodes].[FormID]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblHWMStatusCodes].[FieldLength]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblHWMStatusCodes].[Protected]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblHWMStatusCodes].[Version]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblHWMStatusCodes].[ToSend]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblHWMStatusCodes].[FieldCN]'
GO
GRANT DELETE ON  [dbo].[tblHWMStatusCodes] TO [public]
GO
GRANT INSERT ON  [dbo].[tblHWMStatusCodes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblHWMStatusCodes] TO [public]
GO
GRANT SELECT ON  [dbo].[tblHWMStatusCodes] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblHWMStatusCodes] TO [public]
GO
