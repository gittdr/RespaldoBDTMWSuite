CREATE TABLE [dbo].[ResNow_MetaTrailerCache]
(
[Column_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Computed] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Length] [float] NULL,
[Prec] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Scale] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCD_Type] [int] NULL,
[ResNow_MetaTrailerCache_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNow_MetaTrailerCache] ADD CONSTRAINT [prkey_ResNow_MetaTrailerCache] PRIMARY KEY CLUSTERED ([ResNow_MetaTrailerCache_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNow_MetaTrailerCache] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNow_MetaTrailerCache] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNow_MetaTrailerCache] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNow_MetaTrailerCache] TO [public]
GO
