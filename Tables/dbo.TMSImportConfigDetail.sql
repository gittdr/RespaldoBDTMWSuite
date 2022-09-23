CREATE TABLE [dbo].[TMSImportConfigDetail]
(
[DetailId] [int] NOT NULL IDENTITY(1, 1),
[ImpId] [int] NOT NULL,
[Section] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Field] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ValueInt] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSImportConfigDetail] ADD CONSTRAINT [PK_TMSImportConfigDetail] PRIMARY KEY CLUSTERED ([DetailId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSImportConfigDetail] ADD CONSTRAINT [fk_TMSImportConfigDetail_ImpId] FOREIGN KEY ([ImpId]) REFERENCES [dbo].[TMSImportConfig] ([ImpId])
GO
GRANT DELETE ON  [dbo].[TMSImportConfigDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSImportConfigDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSImportConfigDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSImportConfigDetail] TO [public]
GO
