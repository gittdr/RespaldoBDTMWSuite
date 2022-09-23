CREATE TABLE [dbo].[userperfmonitor_def]
(
[upm_type] [int] NULL,
[upm_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upm_comment] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[userperfmonitor_def] TO [public]
GO
GRANT INSERT ON  [dbo].[userperfmonitor_def] TO [public]
GO
GRANT REFERENCES ON  [dbo].[userperfmonitor_def] TO [public]
GO
GRANT SELECT ON  [dbo].[userperfmonitor_def] TO [public]
GO
GRANT UPDATE ON  [dbo].[userperfmonitor_def] TO [public]
GO
