CREATE TABLE [dbo].[tblFldType]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[TypeName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileCommType] [int] NULL,
[Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalMailType] [int] NULL,
[DefaultWidth] [smallint] NULL,
[MinWidth] [smallint] NULL,
[MaxWidth] [smallint] NULL,
[IsDefault] [bit] NOT NULL,
[IsMCSystemDefault] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblFldType] ADD CONSTRAINT [PK_tblFldType_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Code] ON [dbo].[tblFldType] ([MobileCommType], [Code]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblFldType] TO [public]
GO
GRANT INSERT ON  [dbo].[tblFldType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblFldType] TO [public]
GO
GRANT SELECT ON  [dbo].[tblFldType] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblFldType] TO [public]
GO
