CREATE TABLE [dbo].[masterorders_ref]
(
[ord_hdrnumber] [int] NOT NULL,
[master_refnumber] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_loadtime] [decimal] (5, 2) NULL,
[ord_unloadtime] [decimal] (5, 2) NULL,
[ord_totaltime] [decimal] (5, 2) NULL,
[productive_hrs] [decimal] (5, 2) NULL,
[payload_value] [float] NULL,
[payload_uom] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cleaning_costs] [money] NULL,
[permits_toll_costs] [money] NULL,
[loaded_miles] [int] NULL,
[unloaded_miles] [int] NULL,
[driver_pay_pct] [decimal] (5, 2) NULL,
[leasedop_pay_pct] [decimal] (5, 2) NULL,
[revenue_amt] [money] NULL,
[epm] [decimal] (10, 2) NULL,
[eph] [decimal] (10, 2) NULL,
[gvw] [decimal] (6, 0) NULL,
[comments] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [masterorders_ref_NU1] ON [dbo].[masterorders_ref] ([ord_revtype1], [master_refnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[masterorders_ref] TO [public]
GO
GRANT INSERT ON  [dbo].[masterorders_ref] TO [public]
GO
GRANT REFERENCES ON  [dbo].[masterorders_ref] TO [public]
GO
GRANT SELECT ON  [dbo].[masterorders_ref] TO [public]
GO
GRANT UPDATE ON  [dbo].[masterorders_ref] TO [public]
GO
