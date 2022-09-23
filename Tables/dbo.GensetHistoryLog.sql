CREATE TABLE [dbo].[GensetHistoryLog]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[genset_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[create_user] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[begin_date] [datetime] NULL,
[remove_user] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[end_date] [datetime] NULL,
[change_reason] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GensetHistoryLog] TO [public]
GO
GRANT INSERT ON  [dbo].[GensetHistoryLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[GensetHistoryLog] TO [public]
GO
GRANT SELECT ON  [dbo].[GensetHistoryLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[GensetHistoryLog] TO [public]
GO
