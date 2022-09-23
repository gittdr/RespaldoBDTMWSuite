CREATE TABLE [dbo].[rating_hierarchy_header]
(
[rhh_id] [int] NOT NULL IDENTITY(1, 1),
[rhh_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rhh_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rating_hierarchy_header] ADD CONSTRAINT [pk_rating_hierarchy_header_rhh_id] PRIMARY KEY CLUSTERED ([rhh_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rating_hierarchy_header] TO [public]
GO
GRANT INSERT ON  [dbo].[rating_hierarchy_header] TO [public]
GO
GRANT SELECT ON  [dbo].[rating_hierarchy_header] TO [public]
GO
GRANT UPDATE ON  [dbo].[rating_hierarchy_header] TO [public]
GO
