CREATE TABLE [dbo].[schedule_table]
(
[sch_number] [int] NOT NULL,
[sch_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[sch_dow] [int] NULL,
[sch_dispatch] [int] NULL,
[sch_specificdate] [datetime] NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_multisch] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_timeofday] [datetime] NULL,
[mov_number] [int] NULL,
[sch_scope] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copies] [int] NULL,
[sch_copy_assetassignments] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_dates] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_rates] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_accessorials] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_notes] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_delinstructions] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_paydetails] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_orderref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_otherref] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_frequency] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_expires_on] [datetime] NULL,
[sch_minutestoadd] [int] NULL,
[sch_lastrundate] [datetime] NULL,
[sch_skip_holidays] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_skip_weekends] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_firstrundate] [datetime] NULL,
[sch_hourstoadd] [float] NULL,
[sch_timestorun] [int] NULL,
[sch_copy_loadreqs] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_weeks] [smallint] NULL,
[lgh_number] [int] NULL,
[sch_masterid] [int] NULL,
[sch_rotationweek] [int] NULL,
[mr_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_lghtypes] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_extrainfo] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_permitrequirements] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_id2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_donotinvoice] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_donotsettle] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_fixed_week_count] [tinyint] NULL,
[sch_ident] [int] NOT NULL IDENTITY(1, 1),
[sch_started] [datetime] NULL,
[sch_completed] [datetime] NULL,
[sch_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_thirdpartyasgn] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_copy_thirdpartypay] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_ord_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_schedule_table_sch_ord_status] DEFAULT ('AVL'),
[sch_runschedule] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_sat_disallowedstoptype] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_sat_disallowednextday] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_sun_disallowedstoptype] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_sun_disallowednextday] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_sch_mov_number] ON [dbo].[schedule_table] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_sch_mr_name] ON [dbo].[schedule_table] ([mr_name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_sch_ord_hdrnumber] ON [dbo].[schedule_table] ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [i_schedule_pk1] ON [dbo].[schedule_table] ([sch_number], [lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[schedule_table] TO [public]
GO
GRANT INSERT ON  [dbo].[schedule_table] TO [public]
GO
GRANT REFERENCES ON  [dbo].[schedule_table] TO [public]
GO
GRANT SELECT ON  [dbo].[schedule_table] TO [public]
GO
GRANT UPDATE ON  [dbo].[schedule_table] TO [public]
GO
