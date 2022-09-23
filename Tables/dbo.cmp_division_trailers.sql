CREATE TABLE [dbo].[cmp_division_trailers]
(
[cdt_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[division] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailerCount] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cmp_division_trailers] TO [public]
GO
GRANT INSERT ON  [dbo].[cmp_division_trailers] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cmp_division_trailers] TO [public]
GO
GRANT SELECT ON  [dbo].[cmp_division_trailers] TO [public]
GO
GRANT UPDATE ON  [dbo].[cmp_division_trailers] TO [public]
GO
