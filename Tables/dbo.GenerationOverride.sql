CREATE TABLE [dbo].[GenerationOverride]
(
[go_ident] [int] NOT NULL IDENTITY(1, 1),
[go_type] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[go_key] [int] NOT NULL,
[go_date] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GenerationOverride] ADD CONSTRAINT [PK_GenerationOverride] PRIMARY KEY CLUSTERED ([go_ident]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_GenerationOverride_Type_Date] ON [dbo].[GenerationOverride] ([go_date], [go_type]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_AK_GenerationOverride] ON [dbo].[GenerationOverride] ([go_key], [go_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GenerationOverride] TO [public]
GO
GRANT INSERT ON  [dbo].[GenerationOverride] TO [public]
GO
GRANT SELECT ON  [dbo].[GenerationOverride] TO [public]
GO
GRANT UPDATE ON  [dbo].[GenerationOverride] TO [public]
GO
