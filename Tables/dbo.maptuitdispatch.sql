CREATE TABLE [dbo].[maptuitdispatch]
(
[mdisp_id] [int] NOT NULL IDENTITY(1, 1),
[mdisp_lghnumber] [int] NULL,
[mdisp_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_mdispid] ON [dbo].[maptuitdispatch] ([mdisp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[maptuitdispatch] TO [public]
GO
GRANT INSERT ON  [dbo].[maptuitdispatch] TO [public]
GO
GRANT REFERENCES ON  [dbo].[maptuitdispatch] TO [public]
GO
GRANT SELECT ON  [dbo].[maptuitdispatch] TO [public]
GO
GRANT UPDATE ON  [dbo].[maptuitdispatch] TO [public]
GO
