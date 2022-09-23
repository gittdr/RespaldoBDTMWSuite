CREATE TABLE [dbo].[dimfactor]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dim_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dim_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dim_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dim_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dim_factor] [decimal] (12, 4) NULL,
[dim_identity] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dimfactor] ADD CONSTRAINT [pk_identity] PRIMARY KEY CLUSTERED ([dim_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_dim_unique] ON [dbo].[dimfactor] ([cmp_id], [dim_revtype1], [dim_revtype2], [dim_revtype3], [dim_revtype4], [cmd_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dimfactor] TO [public]
GO
GRANT INSERT ON  [dbo].[dimfactor] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dimfactor] TO [public]
GO
GRANT SELECT ON  [dbo].[dimfactor] TO [public]
GO
GRANT UPDATE ON  [dbo].[dimfactor] TO [public]
GO
