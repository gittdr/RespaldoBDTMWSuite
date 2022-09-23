CREATE TABLE [dbo].[stop_delay]
(
[stp_number] [int] NOT NULL,
[std_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[std_reason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[std_delay] [int] NULL,
[std_total_delay] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[stop_delay] TO [public]
GO
GRANT INSERT ON  [dbo].[stop_delay] TO [public]
GO
GRANT REFERENCES ON  [dbo].[stop_delay] TO [public]
GO
GRANT SELECT ON  [dbo].[stop_delay] TO [public]
GO
GRANT UPDATE ON  [dbo].[stop_delay] TO [public]
GO
