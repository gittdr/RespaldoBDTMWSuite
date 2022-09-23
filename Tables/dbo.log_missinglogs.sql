CREATE TABLE [dbo].[log_missinglogs]
(
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[missing_date] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [log_ml_empiddate] ON [dbo].[log_missinglogs] ([mpp_id], [missing_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[log_missinglogs] TO [public]
GO
GRANT INSERT ON  [dbo].[log_missinglogs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[log_missinglogs] TO [public]
GO
GRANT SELECT ON  [dbo].[log_missinglogs] TO [public]
GO
GRANT UPDATE ON  [dbo].[log_missinglogs] TO [public]
GO
