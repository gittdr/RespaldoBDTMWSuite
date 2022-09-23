CREATE TABLE [dbo].[tmwhelpindexes]
(
[index_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[index_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[index_keys] [nvarchar] (2126) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tmwhelpindexes] ADD CONSTRAINT [PK__tmwhelpindexes__6313BD42] PRIMARY KEY CLUSTERED ([index_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tmwhelpindexes] TO [public]
GO
GRANT INSERT ON  [dbo].[tmwhelpindexes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tmwhelpindexes] TO [public]
GO
GRANT SELECT ON  [dbo].[tmwhelpindexes] TO [public]
GO
GRANT UPDATE ON  [dbo].[tmwhelpindexes] TO [public]
GO
