CREATE TABLE [dbo].[csatransget_msg]
(
[query_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[log_datetime] [datetime] NOT NULL,
[msgtext] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[csatransget_msg] TO [public]
GO
GRANT INSERT ON  [dbo].[csatransget_msg] TO [public]
GO
GRANT REFERENCES ON  [dbo].[csatransget_msg] TO [public]
GO
GRANT SELECT ON  [dbo].[csatransget_msg] TO [public]
GO
GRANT UPDATE ON  [dbo].[csatransget_msg] TO [public]
GO
