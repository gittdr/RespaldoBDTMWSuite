CREATE TABLE [dbo].[nlmautoreject]
(
[nlmar_id] [int] NOT NULL IDENTITY(1, 1),
[nlmar_string] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nlmautoreject] TO [public]
GO
GRANT INSERT ON  [dbo].[nlmautoreject] TO [public]
GO
GRANT REFERENCES ON  [dbo].[nlmautoreject] TO [public]
GO
GRANT SELECT ON  [dbo].[nlmautoreject] TO [public]
GO
GRANT UPDATE ON  [dbo].[nlmautoreject] TO [public]
GO
