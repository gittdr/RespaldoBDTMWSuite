CREATE TABLE [dbo].[rating_hierarchy_detail_audit]
(
[rhda_id] [int] NOT NULL IDENTITY(1, 1),
[rhd_id] [int] NULL,
[rhh_id] [int] NOT NULL,
[rhd_sequence] [int] NOT NULL,
[rhd_column_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rhd_column_label] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rhd_column_sort_key] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rhda_updateby] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rhda_updatedt] [datetime] NULL,
[rhda_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rating_hierarchy_detail_audit] ADD CONSTRAINT [pk_rating_hierarchy_detail_audit_rhda_id] PRIMARY KEY CLUSTERED ([rhda_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rating_hierarchy_detail_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[rating_hierarchy_detail_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[rating_hierarchy_detail_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[rating_hierarchy_detail_audit] TO [public]
GO
