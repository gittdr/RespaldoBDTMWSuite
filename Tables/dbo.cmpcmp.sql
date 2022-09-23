CREATE TABLE [dbo].[cmpcmp]
(
[billto_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ediloc_code] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cmpcmp] ADD CONSTRAINT [AutoPK_cmpcmp] PRIMARY KEY CLUSTERED ([billto_cmp_id], [cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cmpcmp] TO [public]
GO
GRANT INSERT ON  [dbo].[cmpcmp] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cmpcmp] TO [public]
GO
GRANT SELECT ON  [dbo].[cmpcmp] TO [public]
GO
GRANT UPDATE ON  [dbo].[cmpcmp] TO [public]
GO
