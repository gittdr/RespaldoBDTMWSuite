CREATE TABLE [dbo].[ttsmappings]
(
[userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[moduleid] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[programid] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[map_insert] [tinyint] NULL,
[map_update] [tinyint] NULL,
[map_select] [tinyint] NULL,
[map_delete] [tinyint] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [module] ON [dbo].[ttsmappings] ([moduleid]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [usermodprog] ON [dbo].[ttsmappings] ([userid], [moduleid], [programid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttsmappings] TO [public]
GO
GRANT INSERT ON  [dbo].[ttsmappings] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttsmappings] TO [public]
GO
GRANT SELECT ON  [dbo].[ttsmappings] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttsmappings] TO [public]
GO
