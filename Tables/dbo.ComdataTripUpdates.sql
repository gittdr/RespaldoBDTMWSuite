CREATE TABLE [dbo].[ComdataTripUpdates]
(
[cdtu_id] [int] NOT NULL IDENTITY(1, 1),
[cdtu_asgn_type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cdtu_asgn_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cdtu_updatedon] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ComdataTripUpdates] TO [public]
GO
GRANT INSERT ON  [dbo].[ComdataTripUpdates] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ComdataTripUpdates] TO [public]
GO
GRANT SELECT ON  [dbo].[ComdataTripUpdates] TO [public]
GO
GRANT UPDATE ON  [dbo].[ComdataTripUpdates] TO [public]
GO
