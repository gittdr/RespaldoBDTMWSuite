CREATE TABLE [dbo].[branch_holiday]
(
[brh_identity] [int] NOT NULL IDENTITY(1, 1),
[brh_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[brh_date] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[branch_holiday] TO [public]
GO
GRANT INSERT ON  [dbo].[branch_holiday] TO [public]
GO
GRANT REFERENCES ON  [dbo].[branch_holiday] TO [public]
GO
GRANT SELECT ON  [dbo].[branch_holiday] TO [public]
GO
GRANT UPDATE ON  [dbo].[branch_holiday] TO [public]
GO
