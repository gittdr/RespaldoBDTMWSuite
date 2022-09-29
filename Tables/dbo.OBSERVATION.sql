CREATE TABLE [dbo].[OBSERVATION]
(
[obs_ID] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[obs_Sequence] [tinyint] NOT NULL,
[obs_OccurranceDate] [datetime] NULL,
[obs_MppOrEeID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_ObservationType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_ObservationType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_Description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_EEObserver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_ObserverName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_ObserverAddress1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_ObserverAddress2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_ObserverCity] [int] NULL,
[obs_ObserverCtynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_ObserverState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_ObserverZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_ObserverCountry] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_ObserverHomePhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_ObserverWorkPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_FollowUpRequired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_FollowUpDesc] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_FollowUpCompleted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_FollowUpCompletedDate] [datetime] NULL,
[obs_CKBox1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_CKBox2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_CKBox3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_CKBox4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_CKBox5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_string1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_string2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_string3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_string4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_string5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_number1] [money] NULL,
[obs_number2] [money] NULL,
[obs_number3] [money] NULL,
[obs_number4] [money] NULL,
[obs_number5] [money] NULL,
[obs_ObservationType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_ObservationType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_ObservationType5] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_ObservationType6] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[obs_date1] [datetime] NULL,
[obs_date2] [datetime] NULL,
[obs_date3] [datetime] NULL,
[obs_date4] [datetime] NULL,
[obs_date5] [datetime] NULL,
[dw_timestamp] [timestamp] NOT NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__OBSERVATI__INS_T__60E714DA] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_OBSERVATION_timestamp] ON [dbo].[OBSERVATION] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [OBSERVATION_INS_TIMESTAMP] ON [dbo].[OBSERVATION] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_obsID] ON [dbo].[OBSERVATION] ([obs_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_srpEEDate] ON [dbo].[OBSERVATION] ([srp_ID], [obs_Sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OBSERVATION] TO [public]
GO
GRANT INSERT ON  [dbo].[OBSERVATION] TO [public]
GO
GRANT REFERENCES ON  [dbo].[OBSERVATION] TO [public]
GO
GRANT SELECT ON  [dbo].[OBSERVATION] TO [public]
GO
GRANT UPDATE ON  [dbo].[OBSERVATION] TO [public]
GO
