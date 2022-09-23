CREATE TABLE [dbo].[FAInt]
(
[lgh_number] [int] NULL,
[fa_route] [varchar] (248) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddInfotype] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddInfo] [varchar] (248) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FAInt] TO [public]
GO
GRANT INSERT ON  [dbo].[FAInt] TO [public]
GO
GRANT REFERENCES ON  [dbo].[FAInt] TO [public]
GO
GRANT SELECT ON  [dbo].[FAInt] TO [public]
GO
GRANT UPDATE ON  [dbo].[FAInt] TO [public]
GO
