CREATE TABLE [dbo].[ttsprograms]
(
[programid] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[programname] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[windowname] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[helptext] [char] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[rebuildmenulist] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [key0] ON [dbo].[ttsprograms] ([programid], [programname]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttsprograms] TO [public]
GO
GRANT INSERT ON  [dbo].[ttsprograms] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttsprograms] TO [public]
GO
GRANT SELECT ON  [dbo].[ttsprograms] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttsprograms] TO [public]
GO
