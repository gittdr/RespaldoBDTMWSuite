CREATE TABLE [dbo].[edicommodity]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[edi_cmd_code] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_cmp_cmd] ON [dbo].[edicommodity] ([cmp_id], [cmd_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edicommodity] TO [public]
GO
GRANT INSERT ON  [dbo].[edicommodity] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edicommodity] TO [public]
GO
GRANT SELECT ON  [dbo].[edicommodity] TO [public]
GO
GRANT UPDATE ON  [dbo].[edicommodity] TO [public]
GO
