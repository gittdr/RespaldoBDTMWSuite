CREATE TABLE [dbo].[onerow]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[string1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[onerow] ADD CONSTRAINT [pk_onerow] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[onerow] TO [public]
GO
GRANT INSERT ON  [dbo].[onerow] TO [public]
GO
GRANT REFERENCES ON  [dbo].[onerow] TO [public]
GO
GRANT SELECT ON  [dbo].[onerow] TO [public]
GO
GRANT UPDATE ON  [dbo].[onerow] TO [public]
GO
