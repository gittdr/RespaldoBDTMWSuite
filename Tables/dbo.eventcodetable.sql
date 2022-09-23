CREATE TABLE [dbo].[eventcodetable]
(
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[code] [int] NULL,
[locked] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userlabelname] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edicode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mile_typ_to_stop] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mile_typ_from_stop] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drv_pay_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fuel_tax_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mfh_status_event] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_status_event] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primary_event] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[other_event] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_event] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[ect_payondepart] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_trlstart] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_trlend] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_billable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_trcdrv_event] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_cmdcty_req] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_purchase_service] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_EndDeadHead_event] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_BeginDeadHead_event] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_defaulttimefirst] [decimal] (6, 2) NULL,
[ect_defaulttimesubnotb2b] [decimal] (6, 2) NULL,
[ect_defaulttimesubb2b] [decimal] (6, 2) NULL,
[ect_bt_start] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_bt_end] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_mt_start] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_mt_end] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_ld_start] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_ld_end] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_event_like_abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_systemcode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ect_defaultdwelltime] [int] NOT NULL CONSTRAINT [df_ect_defaultdwelltime] DEFAULT ((-1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eventcodetable] ADD CONSTRAINT [pk_eventcodetable] PRIMARY KEY CLUSTERED ([abbr]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ix_eventcodetable_name] ON [dbo].[eventcodetable] ([name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_eventcodetable_timestamp] ON [dbo].[eventcodetable] ([timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[eventcodetable] TO [public]
GO
GRANT INSERT ON  [dbo].[eventcodetable] TO [public]
GO
GRANT REFERENCES ON  [dbo].[eventcodetable] TO [public]
GO
GRANT SELECT ON  [dbo].[eventcodetable] TO [public]
GO
GRANT UPDATE ON  [dbo].[eventcodetable] TO [public]
GO
