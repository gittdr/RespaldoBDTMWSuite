CREATE TABLE [dbo].[ShiftSchedules]
(
[ss_id] [int] NOT NULL IDENTITY(1, 1),
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ss_shift] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ss_shiftstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ss_date] [datetime] NOT NULL,
[ss_starttime] [datetime] NOT NULL,
[ss_endtime] [datetime] NOT NULL,
[ss_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ss_fleet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ss_comment] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_lastupdatedate] [datetime] NULL,
[trl2_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_logindate] [datetime] NULL,
[ss_logoutdate] [datetime] NULL,
[trl_id_2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_hometerminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_startcompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_shiftpriority] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ss_timestamp] [timestamp] NULL,
[ss_skiptrigger] [bit] NULL,
[ss_ReturnEMTMode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_shiftschedules_ss_ReturnEMTMode] DEFAULT ('UNK'),
[ss_hoursplannedatlogin] [float] NOT NULL CONSTRAINT [DF__ShiftSche__ss_ho__427738BF] DEFAULT ((0)),
[ss_hoursutilized] [float] NOT NULL CONSTRAINT [DF__ShiftSche__ss_ho__436B5CF8] DEFAULT ((0)),
[ss_ivr_status] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__ShiftSche__ss_iv__445F8131] DEFAULT ('N'),
[ss_tripsumrpt_last_rundate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ShiftSchedules] ADD CONSTRAINT [pk_shiftschedules] PRIMARY KEY CLUSTERED ([ss_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_shiftschedules_mpp_id_ss_date] ON [dbo].[ShiftSchedules] ([mpp_id], [ss_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [shiftschedules_terminal] ON [dbo].[ShiftSchedules] ([ss_terminal], [ss_starttime], [ss_endtime]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ShiftSchedules_timestamp] ON [dbo].[ShiftSchedules] ([ss_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uk_shiftschedules_trc_number_ss_date] ON [dbo].[ShiftSchedules] ([trc_number], [ss_date]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ShiftSchedules] TO [public]
GO
GRANT INSERT ON  [dbo].[ShiftSchedules] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ShiftSchedules] TO [public]
GO
GRANT SELECT ON  [dbo].[ShiftSchedules] TO [public]
GO
GRANT UPDATE ON  [dbo].[ShiftSchedules] TO [public]
GO
