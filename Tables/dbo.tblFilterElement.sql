CREATE TABLE [dbo].[tblFilterElement]
(
[flt_SN] [int] NOT NULL,
[fel_SN] [int] NOT NULL IDENTITY(1, 1),
[fel_Seq] [int] NULL,
[fel_Type] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fel_Value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fel_NoView] [int] NOT NULL,
[fel_NoRead] [int] NOT NULL,
[fel_NoSend] [int] NOT NULL,
[fel_PosOnly] [int] NOT NULL,
[fel_noOwner] [int] NOT NULL CONSTRAINT [DF__tblFilter__fel_n__0672D36F] DEFAULT (0),
[fel_noContent] [int] NOT NULL CONSTRAINT [DF__tblFilter__fel_n__0766F7A8] DEFAULT (0)
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_tblFilterElement] ON [dbo].[tblFilterElement] ([flt_SN], [fel_Seq]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblFilterElement] TO [public]
GO
GRANT INSERT ON  [dbo].[tblFilterElement] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblFilterElement] TO [public]
GO
GRANT SELECT ON  [dbo].[tblFilterElement] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblFilterElement] TO [public]
GO
