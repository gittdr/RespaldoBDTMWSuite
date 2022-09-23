CREATE TABLE [dbo].[stopltlinfo]
(
[stp_number] [int] NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[option_number] [int] NULL CONSTRAINT [DF__stopltlin__optio__023BF0F1] DEFAULT ((0)),
[option_number_override] [int] NULL CONSTRAINT [DF__stopltlin__optio__0330152A] DEFAULT ((0)),
[door_number] [int] NULL CONSTRAINT [DF__stopltlin__door___04243963] DEFAULT ((0)),
[door_number_override] [int] NULL CONSTRAINT [DF__stopltlin__door___05185D9C] DEFAULT ((0)),
[route_id] [int] NULL CONSTRAINT [DF__stopltlin__route__060C81D5] DEFAULT ((0)),
[route_id_override] [int] NULL CONSTRAINT [DF__stopltlin__route__0700A60E] DEFAULT ((0)),
[unit_pos] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__stopltlin__unit___07F4CA47] DEFAULT (''),
[planned_close] [datetime] NULL,
[planned_depart] [datetime] NULL,
[rowchgts] [timestamp] NOT NULL,
[has_notes] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__stopltlin__has_n__08E8EE80] DEFAULT ('N'),
[hazmat] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__stopltlin__hazma__09DD12B9] DEFAULT ('N'),
[temperature_control] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__stopltlin__tempe__0AD136F2] DEFAULT ('N'),
[ref_stp_number] [int] NULL CONSTRAINT [DF__stopltlin__ref_s__0BC55B2B] DEFAULT ((0)),
[stp_latitude] [int] NULL CONSTRAINT [DF__stopltlin__stp_l__0CB97F64] DEFAULT ((0)),
[stp_longitude] [int] NULL CONSTRAINT [DF__stopltlin__stp_l__0DADA39D] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[stopltlinfo] ADD CONSTRAINT [PK__stopltli__245EE02368BF0E04] PRIMARY KEY CLUSTERED ([stp_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[stopltlinfo] TO [public]
GO
GRANT INSERT ON  [dbo].[stopltlinfo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[stopltlinfo] TO [public]
GO
GRANT SELECT ON  [dbo].[stopltlinfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[stopltlinfo] TO [public]
GO
