CREATE TABLE [dbo].[maptuitdirections]
(
[md_id] [int] NOT NULL IDENTITY(1, 1),
[md_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[md_lghnumber] [int] NULL,
[md_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[md_lat] [decimal] (7, 4) NULL,
[md_long] [decimal] (7, 4) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_mdid] ON [dbo].[maptuitdirections] ([md_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[maptuitdirections] TO [public]
GO
GRANT INSERT ON  [dbo].[maptuitdirections] TO [public]
GO
GRANT REFERENCES ON  [dbo].[maptuitdirections] TO [public]
GO
GRANT SELECT ON  [dbo].[maptuitdirections] TO [public]
GO
GRANT UPDATE ON  [dbo].[maptuitdirections] TO [public]
GO
