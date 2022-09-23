CREATE TABLE [dbo].[StopSchedulesHistory]
(
[ssh_id] [int] NOT NULL IDENTITY(1, 1),
[sch_id] [int] NOT NULL,
[sch_BillToContactMade] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_LocationContactMade] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_CreatedOn] [datetime] NOT NULL,
[sch_CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sch_DriverTargetDate] [datetime] NOT NULL,
[sch_BillToContactMadeDate] [datetime] NULL,
[sch_LocationContactMadeDate] [datetime] NULL,
[sch_DriverTargetEndDate] [datetime] NOT NULL,
[ce_id] [int] NULL,
[sch_contactname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_reasoncode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_locationid] [int] NULL,
[sch_locationcontactname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_lateTractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_ontime] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_LastUpdateBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_LastUpdateOn] [datetime] NULL,
[sch_reasonlatecode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StopSchedulesHistory] ADD CONSTRAINT [pk_StopSchedHistory_id] PRIMARY KEY CLUSTERED ([ssh_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StopSchedulesHistory] ADD CONSTRAINT [fk_SSH_to_SS_id] FOREIGN KEY ([sch_id]) REFERENCES [dbo].[StopSchedules] ([sch_id])
GO
GRANT DELETE ON  [dbo].[StopSchedulesHistory] TO [public]
GO
GRANT INSERT ON  [dbo].[StopSchedulesHistory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[StopSchedulesHistory] TO [public]
GO
GRANT SELECT ON  [dbo].[StopSchedulesHistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[StopSchedulesHistory] TO [public]
GO
