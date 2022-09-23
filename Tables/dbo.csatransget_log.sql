CREATE TABLE [dbo].[csatransget_log]
(
[log_id] [int] NOT NULL IDENTITY(1, 1),
[query_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[log_datetime] [datetime] NOT NULL,
[msgtext] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[error_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__csatransg__error__24C0EB81] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[csatransget_log] ADD CONSTRAINT [PK__csatransget_log__23CCC748] PRIMARY KEY NONCLUSTERED ([log_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[csatransget_log] TO [public]
GO
GRANT INSERT ON  [dbo].[csatransget_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[csatransget_log] TO [public]
GO
GRANT SELECT ON  [dbo].[csatransget_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[csatransget_log] TO [public]
GO
