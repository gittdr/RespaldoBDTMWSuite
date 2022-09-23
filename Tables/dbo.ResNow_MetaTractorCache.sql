CREATE TABLE [dbo].[ResNow_MetaTractorCache]
(
[Column_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Computed] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Length] [float] NULL,
[Prec] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Scale] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCD_Type] [int] NULL,
[ResNow_MetaTractorCache_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNow_MetaTractorCache] ADD CONSTRAINT [prkey_ResNow_MetaTractorCache] PRIMARY KEY CLUSTERED ([ResNow_MetaTractorCache_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNow_MetaTractorCache] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNow_MetaTractorCache] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNow_MetaTractorCache] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNow_MetaTractorCache] TO [public]
GO
