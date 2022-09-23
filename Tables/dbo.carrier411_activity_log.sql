CREATE TABLE [dbo].[carrier411_activity_log]
(
[cal_activity_id] [int] NOT NULL IDENTITY(1, 1),
[cal_activity_type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cal_activity_datetime] [datetime] NULL,
[cab_batch_number] [int] NULL,
[cal_activity_userID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cal_carrier411_safety_date] [datetime] NULL,
[cal_carrier411_safestat_date] [datetime] NULL,
[cal_carrier411_insauth_date] [datetime] NULL,
[cal_system_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cal_activity_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cal_carrier411_SMS_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrier411_activity_log] ADD CONSTRAINT [PK__carrier411_activ__22014D0B] PRIMARY KEY CLUSTERED ([cal_activity_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrier411_activity_log] TO [public]
GO
GRANT INSERT ON  [dbo].[carrier411_activity_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrier411_activity_log] TO [public]
GO
GRANT SELECT ON  [dbo].[carrier411_activity_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrier411_activity_log] TO [public]
GO
