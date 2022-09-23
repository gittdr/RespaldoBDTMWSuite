CREATE TABLE [dbo].[route_blackouts]
(
[rb_id] [int] NOT NULL IDENTITY(1, 1),
[rb_branch] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rb_route] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rb_date] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[route_blackouts] ADD CONSTRAINT [PK_route_blackouts] PRIMARY KEY NONCLUSTERED ([rb_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ix_route_blackouts] ON [dbo].[route_blackouts] ([rb_branch], [rb_route], [rb_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[route_blackouts] TO [public]
GO
GRANT INSERT ON  [dbo].[route_blackouts] TO [public]
GO
GRANT REFERENCES ON  [dbo].[route_blackouts] TO [public]
GO
GRANT SELECT ON  [dbo].[route_blackouts] TO [public]
GO
GRANT UPDATE ON  [dbo].[route_blackouts] TO [public]
GO
