CREATE TABLE [dbo].[mbinvformats]
(
[mbi_format] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mbi_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mbi_group] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[mbinvformats] TO [public]
GO
GRANT INSERT ON  [dbo].[mbinvformats] TO [public]
GO
GRANT REFERENCES ON  [dbo].[mbinvformats] TO [public]
GO
GRANT SELECT ON  [dbo].[mbinvformats] TO [public]
GO
GRANT UPDATE ON  [dbo].[mbinvformats] TO [public]
GO
