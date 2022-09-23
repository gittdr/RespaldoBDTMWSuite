CREATE TABLE [dbo].[company_ltl_info]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[route_id] [int] NULL CONSTRAINT [DF__company_l__route__3E85E522] DEFAULT ((0)),
[unit_pos] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company_l__unit___3F7A095B] DEFAULT (''),
[carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stop_sun] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company_l__stop___406E2D94] DEFAULT ('N'),
[stop_mon] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company_l__stop___416251CD] DEFAULT ('N'),
[stop_tue] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company_l__stop___42567606] DEFAULT ('N'),
[stop_wed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company_l__stop___434A9A3F] DEFAULT ('N'),
[stop_thr] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company_l__stop___443EBE78] DEFAULT ('N'),
[stop_fri] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company_l__stop___4532E2B1] DEFAULT ('N'),
[stop_sat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__company_l__stop___462706EA] DEFAULT ('N'),
[last_stop_date] [datetime] NULL,
[rowchgts] [timestamp] NOT NULL,
[service_level] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_auditor] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales_rep] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_intermodal] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_master_order] [int] NULL CONSTRAINT [DF__company_l__defau__123D4E90] DEFAULT ((0)),
[ord_auto_prepare] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stop_reasoncode_required] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schedule_reasoncode_required] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_ltl_info] ADD CONSTRAINT [PK__company___CD425FDDED19748A] PRIMARY KEY CLUSTERED ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_ltl_info] TO [public]
GO
GRANT INSERT ON  [dbo].[company_ltl_info] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_ltl_info] TO [public]
GO
GRANT SELECT ON  [dbo].[company_ltl_info] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_ltl_info] TO [public]
GO
