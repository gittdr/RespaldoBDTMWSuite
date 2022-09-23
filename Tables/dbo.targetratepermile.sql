CREATE TABLE [dbo].[targetratepermile]
(
[trm_id] [int] NOT NULL IDENTITY(1, 1),
[trm_date] [datetime] NOT NULL,
[trm_rate] [money] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[targetratepermile] ADD CONSTRAINT [pk_targetratepermile_id] PRIMARY KEY CLUSTERED ([trm_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_trm_id] ON [dbo].[targetratepermile] ([trm_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[targetratepermile] TO [public]
GO
GRANT INSERT ON  [dbo].[targetratepermile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[targetratepermile] TO [public]
GO
GRANT SELECT ON  [dbo].[targetratepermile] TO [public]
GO
GRANT UPDATE ON  [dbo].[targetratepermile] TO [public]
GO
