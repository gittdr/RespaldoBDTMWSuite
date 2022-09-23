CREATE TABLE [dbo].[log_driverviolations]
(
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[violation_datetime] [datetime] NOT NULL,
[violation_code] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[violation_continued] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[process_date] [datetime] NULL,
[violation_length] [int] NULL,
[print_date] [datetime] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [log_driverviolations_idx] ON [dbo].[log_driverviolations] ([mpp_id], [violation_datetime], [violation_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[log_driverviolations] TO [public]
GO
GRANT INSERT ON  [dbo].[log_driverviolations] TO [public]
GO
GRANT REFERENCES ON  [dbo].[log_driverviolations] TO [public]
GO
GRANT SELECT ON  [dbo].[log_driverviolations] TO [public]
GO
GRANT UPDATE ON  [dbo].[log_driverviolations] TO [public]
GO
