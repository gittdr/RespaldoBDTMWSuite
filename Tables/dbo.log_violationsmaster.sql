CREATE TABLE [dbo].[log_violationsmaster]
(
[violation_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[violation_description] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[batch_violation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmv_mapping] [tinyint] NULL,
[type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [logviolationmaster] ON [dbo].[log_violationsmaster] ([violation_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[log_violationsmaster] TO [public]
GO
GRANT INSERT ON  [dbo].[log_violationsmaster] TO [public]
GO
GRANT REFERENCES ON  [dbo].[log_violationsmaster] TO [public]
GO
GRANT SELECT ON  [dbo].[log_violationsmaster] TO [public]
GO
GRANT UPDATE ON  [dbo].[log_violationsmaster] TO [public]
GO
