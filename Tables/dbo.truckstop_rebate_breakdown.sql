CREATE TABLE [dbo].[truckstop_rebate_breakdown]
(
[trb_id] [int] NOT NULL IDENTITY(1, 1),
[ts_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trb_value] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trb_rebate_percentage] [decimal] (7, 4) NOT NULL,
[trb_min_max_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_trb_min_max_flag] DEFAULT ('N'),
[trb_uom_basis] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_trb_uom_basis] DEFAULT ('U'),
[trb_rebate_min] [money] NOT NULL CONSTRAINT [df_trb_rebate_min] DEFAULT ((0.00)),
[trb_rebate_max] [money] NOT NULL CONSTRAINT [df_trb_rebate_max] DEFAULT ((9999.99))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[truckstop_rebate_breakdown] ADD CONSTRAINT [fk_truckstop_rebate_breakdown_truckstop] FOREIGN KEY ([ts_code]) REFERENCES [dbo].[truckstops] ([ts_code])
GO
GRANT DELETE ON  [dbo].[truckstop_rebate_breakdown] TO [public]
GO
GRANT INSERT ON  [dbo].[truckstop_rebate_breakdown] TO [public]
GO
GRANT SELECT ON  [dbo].[truckstop_rebate_breakdown] TO [public]
GO
GRANT UPDATE ON  [dbo].[truckstop_rebate_breakdown] TO [public]
GO
