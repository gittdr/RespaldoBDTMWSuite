CREATE TABLE [dbo].[parts]
(
[part_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[part_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[part_customer] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[parts] TO [public]
GO
GRANT INSERT ON  [dbo].[parts] TO [public]
GO
GRANT REFERENCES ON  [dbo].[parts] TO [public]
GO
GRANT SELECT ON  [dbo].[parts] TO [public]
GO
GRANT UPDATE ON  [dbo].[parts] TO [public]
GO
