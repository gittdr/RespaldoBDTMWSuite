CREATE TABLE [dbo].[fixedroute]
(
[fr_id] [int] NOT NULL IDENTITY(1, 1),
[fr_route] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fr_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fr_routename] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_startdt] [datetime] NULL,
[fr_enddt] [datetime] NULL,
[fr_triptype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_typemiles] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_origin] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_destination] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_override_stp_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_time_promised] [datetime] NULL,
[fr_routes_per_day] [smallint] NULL,
[fr_frequency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_dom1] [smallint] NULL,
[fr_dom2] [smallint] NULL,
[fr_dom3] [smallint] NULL,
[fr_dow1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_dow2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_dow3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_dow4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_dow5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_dow6] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_dow7] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_dolly] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fr_totaldistance] [decimal] (8, 1) NULL,
[fr_lastroutedate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fixedroute] ADD CONSTRAINT [pk_fixedroute_fr_id] PRIMARY KEY CLUSTERED ([fr_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_fixedroute_billtocomposite] ON [dbo].[fixedroute] ([fr_billto]) INCLUDE ([fr_route], [fr_branch], [fr_startdt], [fr_enddt]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_fixedroute_branchcomposite] ON [dbo].[fixedroute] ([fr_branch]) INCLUDE ([fr_route], [fr_billto], [fr_startdt], [fr_enddt]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fixedroute] ADD CONSTRAINT [uk_RouteBranchBillTo] UNIQUE NONCLUSTERED ([fr_route], [fr_branch], [fr_billto]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fixedroute] TO [public]
GO
GRANT INSERT ON  [dbo].[fixedroute] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fixedroute] TO [public]
GO
GRANT SELECT ON  [dbo].[fixedroute] TO [public]
GO
GRANT UPDATE ON  [dbo].[fixedroute] TO [public]
GO
