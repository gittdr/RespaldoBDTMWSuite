CREATE TABLE [dbo].[ltldockgroupasgn]
(
[group_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dock_feature] [int] NOT NULL,
[feature_order] [int] NOT NULL,
[feature_caption] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ltldockgroupasgn] ADD CONSTRAINT [PK__ltldockg__31D042A5B9EF870B] PRIMARY KEY CLUSTERED ([group_id], [dock_feature]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ltldockgroupasgn] TO [public]
GO
GRANT INSERT ON  [dbo].[ltldockgroupasgn] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ltldockgroupasgn] TO [public]
GO
GRANT SELECT ON  [dbo].[ltldockgroupasgn] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltldockgroupasgn] TO [public]
GO
