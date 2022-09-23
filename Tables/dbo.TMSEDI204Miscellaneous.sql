CREATE TABLE [dbo].[TMSEDI204Miscellaneous]
(
[MiscId] [int] NOT NULL IDENTITY(1, 1),
[OrderId] [int] NULL,
[CargoId] [int] NULL,
[CompanyId] [int] NULL,
[Version] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiscDataType] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiscData] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiscNoteType] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiscData2] [varchar] (176) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEDI204Miscellaneous] ADD CONSTRAINT [pk_MiscId] PRIMARY KEY CLUSTERED ([MiscId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEDI204Miscellaneous] ADD CONSTRAINT [FK_TMSEDI204Miscellaneous_TMSEDI204Cargo] FOREIGN KEY ([CargoId]) REFERENCES [dbo].[TMSEDI204Cargo] ([CargoId])
GO
ALTER TABLE [dbo].[TMSEDI204Miscellaneous] ADD CONSTRAINT [FK_TMSEDI204Miscellaneous_TMSEDI204Companies] FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[TMSEDI204Companies] ([CompanyId])
GO
ALTER TABLE [dbo].[TMSEDI204Miscellaneous] ADD CONSTRAINT [FK_TMSEDI204Miscellaneous_TMSEDI204Orders] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSEDI204Orders] ([OrderId])
GO
GRANT DELETE ON  [dbo].[TMSEDI204Miscellaneous] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSEDI204Miscellaneous] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSEDI204Miscellaneous] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSEDI204Miscellaneous] TO [public]
GO
