CREATE TABLE [dbo].[userrestriction]
(
[usr_table] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[usr_field] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[usr_restriction] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[usr_group] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[userrestriction] TO [public]
GO
GRANT INSERT ON  [dbo].[userrestriction] TO [public]
GO
GRANT REFERENCES ON  [dbo].[userrestriction] TO [public]
GO
GRANT SELECT ON  [dbo].[userrestriction] TO [public]
GO
GRANT UPDATE ON  [dbo].[userrestriction] TO [public]
GO
