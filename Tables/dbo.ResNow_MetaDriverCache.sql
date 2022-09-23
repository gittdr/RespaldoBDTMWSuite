CREATE TABLE [dbo].[ResNow_MetaDriverCache]
(
[Column_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Computed] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Length] [float] NULL,
[Prec] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Scale] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCD_Type] [int] NULL,
[ResNow_MetaDriverCache_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNow_MetaDriverCache] ADD CONSTRAINT [prkey_ResNow_MetaDriverCache] PRIMARY KEY CLUSTERED ([ResNow_MetaDriverCache_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNow_MetaDriverCache] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNow_MetaDriverCache] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNow_MetaDriverCache] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNow_MetaDriverCache] TO [public]
GO
