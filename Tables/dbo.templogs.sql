CREATE TABLE [dbo].[templogs]
(
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[log_date] [datetime] NOT NULL,
[total_miles] [smallint] NOT NULL,
[log] [char] (96) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[off_duty_hrs] [float] NOT NULL,
[sleeper_berth_hrs] [float] NOT NULL,
[driving_hrs] [float] NOT NULL,
[on_duty_hrs] [float] NOT NULL,
[processed_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[templogs] TO [public]
GO
GRANT INSERT ON  [dbo].[templogs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[templogs] TO [public]
GO
GRANT SELECT ON  [dbo].[templogs] TO [public]
GO
GRANT UPDATE ON  [dbo].[templogs] TO [public]
GO
